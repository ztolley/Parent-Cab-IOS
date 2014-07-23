//
//  TripRecorderService.m
//  Parentcab_iOS
//
//  Created by Zac Tolley on 10/10/2012.
//  Copyright (c) 2012 Exsite Consultants. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "TripRecorderService.h"
#import "Model.h"
#import "JourneyRepository.h"

@interface TripRecorderService ()
{
	CLLocation *previousLocation;
    Boolean recording;
	JourneyRepository *journeyRepository;
}
@end

@implementation TripRecorderService
- (id)init {
	self = [super init];
	
	if (self) {
		_locationManager = [[CLLocationManager alloc] init];
        _locationManager.activityType =  CLActivityTypeAutomotiveNavigation;
		_locationManager.delegate = self;
		_locationManager.distanceFilter = 50; // Maybe make this 100m later, that way it ties in with the 100m accuracy
		_locationManager.pausesLocationUpdatesAutomatically = YES;

		UIDevice *device = UIDevice.currentDevice;
		// Get notifications about power state (charging or using battery)
		[device setBatteryMonitoringEnabled:YES];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(batteryChanged:)
													 name:@"UIDeviceBatteryStateDidChangeNotification"
												   object:device];
		[self setAccuracyForPower:[device batteryState]];
		previousLocation = nil;
		recording = NO;
		
		_geocoder = [[CLGeocoder alloc] init];
	
		journeyRepository = [JourneyRepository sharedRepository];
	}

	return self;
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"%@", error);
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
 	
	// Get the last location in the array
	CLLocation *newLocation = [locations lastObject];
	
	// If the fix is inaccurate or it's not really a fix.
	if ([newLocation horizontalAccuracy] == -1 || [newLocation horizontalAccuracy] > 100) {
		return;
	}
	
	// Is there a current location? if so then figure out the distance between the two
	if (previousLocation != nil) {
		CLLocationDistance distanceFromLastPoint = [previousLocation distanceFromLocation:newLocation];
		self.currentJourney.distance += distanceFromLastPoint;
		self.currentJourney.fare = [self fareForDistance:self.currentJourney.distance];
	} else {
		

		
		Location *startLocation = [journeyRepository getNewLocation];
		startLocation.latitude = newLocation.coordinate.latitude;
		startLocation.longitude = newLocation.coordinate.longitude;
	
		[_geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
			if (error){
				NSLog(@"Geocode failed with error: %@", error);
				return;
			}
			
			CLPlacemark *placement = placemarks.lastObject;
			startLocation.postcode = placement.postalCode;
			startLocation.thoroughfare = placement.thoroughfare;
		}];
		
		
		self.currentJourney.startLocation = startLocation;
	
	}

	Step *newStep = [journeyRepository getNewStep];
	Location *stepLocation = [journeyRepository getNewLocation];
	newStep.location = stepLocation;
	newStep.location.latitude = newLocation.coordinate.latitude;
	newStep.location.longitude = newLocation.coordinate.longitude;

	[self.currentJourney addStepsObject:newStep];

	previousLocation = newLocation;
	
	[_delegate tripRecorder:self updatedDistance: self.currentJourney.distance];
	[_delegate tripRecorder:self updatedFare: self.currentJourney.fare];

}
- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	[notification setAlertAction:@"Resume"];
	[notification setAlertBody:@"Pause Tracking Updates"];
	[notification setSoundName:UILocalNotificationDefaultSoundName];
	[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
	
}
- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {

}


#pragma mark Start/Stop tracking
- (void)startRecording {
	if (recording == NO) {
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
		self.currentJourney = [journeyRepository getNewJourney];
		self.currentJourney.startTime = [[NSDate date] timeIntervalSince1970];
		recording = YES;
		[self.locationManager startUpdatingLocation];
	}
}
- (void)pause {
	
	if (recording == YES) {
		recording = NO;
		[self.locationManager stopUpdatingLocation];
		[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	}
	
	if (self.currentJourney) {
		Location *endLocation = [journeyRepository getNewLocation];
		endLocation.latitude = previousLocation.coordinate.latitude;
		endLocation.longitude = previousLocation.coordinate.longitude;
		
		self.currentJourney.endTime = [[NSDate date] timeIntervalSince1970];
		self.currentJourney.endLocation = endLocation;
	}
	
}
- (void)resume {
	if (recording == NO && self.currentJourney) {
		previousLocation = nil;
		[self.locationManager startUpdatingLocation];
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
		recording = YES;
	}
}
- (void)finish:(JourneyBlock)journeyBlock {
	
	// When a journey is 'Done' there's a little bit of cleanup post processing, like looking up the geo data
	// also its a handy thing that we have a block callback to say the journey is now done when its actually done.
	if (recording == YES) {
		[self pause];
	}
	
	[_geocoder reverseGeocodeLocation:previousLocation completionHandler:^(NSArray *placemarks, NSError *error) {
		
		Journey *journey = self.currentJourney;
		
		if (error){
			NSLog(@"Geocode failed with error: %@", error);
		} else {
			CLPlacemark *placement = placemarks.lastObject;
			journey.endLocation.postcode = placement.postalCode;
			journey.endLocation.thoroughfare = placement.thoroughfare;
		}
		
		if (journeyBlock) {
			journeyBlock(journey);
		}
	}];

}
- (void)reset {
	
	if (recording == YES) {
		[self.locationManager stopUpdatingLocation];
		recording = NO;
	}

	previousLocation = nil;
	self.currentJourney = nil;
	[_delegate tripRecorder:self updatedDistance:0.00];
	[_delegate tripRecorder:self updatedFare:0.00];

}

- (void)clearCurrent {
	
	if (recording == YES) {
		[self.locationManager stopUpdatingLocation];
		recording = NO;
	}
		
	previousLocation = nil;
	self.currentJourney = nil;
	[_delegate tripRecorder:self updatedDistance:0.00];
	[_delegate tripRecorder:self updatedFare:0.00];
}



#pragma mark PowerModeChange
- (void)batteryChanged:(NSNotification *)notification {
    UIDevice *device = [UIDevice currentDevice];
    [self setAccuracyForPower:[device batteryState]];
    NSLog(@"State: %li Charge: %f", device.batteryState, device.batteryLevel);
}
- (void)setAccuracyForPower:(UIDeviceBatteryState)state {
	if (state == UIDeviceBatteryStateCharging || state == UIDeviceBatteryStateFull) {
		[self.locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
	} else {
		[self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	}
}


#pragma mark -
- (double)fareForDistance:(double)distance {
	double pricePerMeter = .000625; // put this in the model soon.
	return distance * pricePerMeter;
}



@end



