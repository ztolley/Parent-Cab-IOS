//
//  TripRecordViewController.m
//  Parentcab_iOS
//
//  Created by Zac Tolley on 10/11/2012.
//  Copyright (c) 2012 Exsite Consultants. All rights reserved.
//

#import "TripRecordViewController.h"
#import "Model.h"
#import "RouteOverlay.h"
#import "JourneyRouteDataSource.h"
#import "GoogleMapsImage.h"
#import "Settings.h"

@interface TripRecordViewController ()
{
	RouteOverlay *overlay;
	Settings *settings;
}
@end

@implementation TripRecordViewController

- (instancetype)initWithSettings:(Settings *)initSettings
{
	self = [super init];
	if (self) {
		settings = initSettings;
	}
	return self;
}

- (NSNumberFormatter *)setupFormatter {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setLocale:settings.locale];
	[numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
	return numberFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setupFormatter];
	overlay = [[RouteOverlay alloc] initWithMap:self.mapView];
	if (settings == nil) {
		settings = [Settings defaultSettings];
	}
}

- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = NO;
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"d MMMM yyyy"];

	NSDateFormatter *shortTimeFormatter = [[NSDateFormatter alloc] init];
	[shortTimeFormatter setDateStyle: NSDateFormatterNoStyle];
	[shortTimeFormatter setTimeStyle:NSDateFormatterShortStyle];

	NSString *distanceString;
	if ([[settings getDistanceUnit] isEqualToString:SETTINGSMILES]) {
		distanceString = [NSString stringWithFormat:@"%.2lf miles", (self.journey.distance * 0.000621371192)];
	} else {
		distanceString= [NSString stringWithFormat:@"%.2lf km", (self.journey.distance/1000)];
	}

	self.fairLabel.text = [[self setupFormatter] stringFromNumber:[NSNumber numberWithDouble:self.journey.fare]];
	self.distanceLabel.text = distanceString;
	self.startTimeLabel.text = [shortTimeFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.journey.startTime]];
	self.startDateLabel.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.journey.startTime]];
	self.startStreetLabel.text = self.journey.startLocation.thoroughfare;
	self.startPostCodeLabel.text = self.journey.startLocation.postcode;
	
	self.endTimeLabel.text = [shortTimeFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.journey.endTime]];
	self.endDateLabel.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.journey.endTime]];
	self.endStreetLabel.text = self.journey.endLocation.thoroughfare;
	self.endPostCodeLabel.text = self.journey.endLocation.postcode;
	
	[overlay setDelegate:[[JourneyRouteDataSource alloc] initWithJourney:self.journey]];

}

- (IBAction)shareJourney:(id)sender {

	NSString *textToShare = [self generateEmailBodyForJourney:self.journey];

    NSData *mapData = [GoogleMapsImage getRouteMapForJourney:self.journey];
	UIImage *myImage = [UIImage imageWithData:mapData];
	
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[textToShare, myImage]
																			 applicationActivities:nil];

	activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact]; 
	[self presentViewController:activityVC animated:YES completion:nil];

}
- (NSString *)generateEmailBodyForJourney:(Journey *)journey {
	NSString *fare = [[self setupFormatter] stringFromNumber:[NSNumber numberWithDouble:journey.fare]];
	
	NSString *result = [NSString stringWithFormat:@"Fare: %@\nStart: %@,%@\nEnd: %@,%@",
						fare,
						journey.startLocation.thoroughfare,
						journey.startLocation.postcode,
						journey.endLocation.thoroughfare,
						journey.endLocation.postcode];
	return result;
}

@end
