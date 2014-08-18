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

@interface TripRecordViewController ()
{
	RouteOverlay *overlay;
}
@end

@implementation TripRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	overlay = [[RouteOverlay alloc] initWithMap:self.mapView];
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = NO;
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"d MMMM yyyy"];
	NSDateFormatter *shortTimeFormatter = [[NSDateFormatter alloc] init];
	[shortTimeFormatter setDateStyle: NSDateFormatterNoStyle];
	[shortTimeFormatter setTimeStyle:NSDateFormatterShortStyle];

	double miles = self.journey.distance * 0.000621371192;
	
	self.fairLabel.text = [NSString stringWithFormat:@"£%.02f", self.journey.fare];
	self.distanceLabel.text = [NSString stringWithFormat:@"%.02f miles", miles];
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
	
	NSString *result = [NSString stringWithFormat:@"Fare: £%.02f\nStart: %@,%@\nEnd: %@,%@",
						journey.fare,
						journey.startLocation.thoroughfare,
						journey.startLocation.postcode,
						journey.endLocation.thoroughfare,
						journey.endLocation.postcode];
	return result;
}

@end
