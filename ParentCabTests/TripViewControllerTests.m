//
//  TripViewControllerTests.m
//  ParentCab
//
//  Created by Zac Tolley on 14/08/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TripViewController.h"
#import "Settings.h"

@interface TripViewControllerTests : XCTestCase

@property (strong, atomic) NSLocale *originalLocale;

@end

@implementation TripViewControllerTests
{

}
- (void)setUp {
    [super setUp];


}

- (void)tearDown {
	Settings *settings = [Settings defaultSettings];
	[settings reset];
	[super tearDown];
}

- (void)testDistanceChangesAreShownInMilesByDefaultInUK {
	Settings *settings = [Settings new];
	settings.locale = [NSLocale localeWithLocaleIdentifier:@"en-GB"];
	
	UILabel *distanceLabel = [[UILabel alloc] init];
	UILabel *fareLabel = [[UILabel alloc] init];
	
	TripViewController *tvc = [[TripViewController alloc] initWithSettings:settings];
	tvc.distanceLabel = distanceLabel;
	tvc.fareLabel = fareLabel;
	
	[tvc tripRecorder:nil updatedDistance:1600];
	NSString *actual = tvc.distanceLabel.text;
	XCTAssert([actual isEqualToString:@"0.99 miles"]);
}
- (void)testDistanceChangesAreShownInMilesByDefaultInUS {
	Settings *settings = [Settings new];
	settings.locale = [NSLocale localeWithLocaleIdentifier:@"en-US"];
	
	UILabel *distanceLabel = [[UILabel alloc] init];
	UILabel *fareLabel = [[UILabel alloc] init];
	
	TripViewController *tvc = [[TripViewController alloc] initWithSettings:settings];
	tvc.distanceLabel = distanceLabel;
	tvc.fareLabel = fareLabel;
	
	[tvc tripRecorder:nil updatedDistance:1600];
	NSString *actual = tvc.distanceLabel.text;
	XCTAssert([actual isEqualToString:@"0.99 miles"]);
}
- (void)testDistanceChangesAreShownInKmByDefaultInFrance {
	Settings *settings = [Settings new];
	settings.locale = [NSLocale localeWithLocaleIdentifier:@"en-FR"];
	
	UILabel *distanceLabel = [[UILabel alloc] init];
	UILabel *fareLabel = [[UILabel alloc] init];
	
	TripViewController *tvc = [[TripViewController alloc] initWithSettings:settings];
	tvc.distanceLabel = distanceLabel;
	tvc.fareLabel = fareLabel;
	
	[tvc tripRecorder:nil updatedDistance:1200];
	NSString *actual = tvc.distanceLabel.text;
	XCTAssert([actual isEqualToString:@"1.20 km"]);
}

- (void)testShowCorrectCurrencyForGBUser {
	
	Settings *settings = [Settings new];
	settings.locale = [NSLocale localeWithLocaleIdentifier:@"en-GB"];
	
	UILabel *fareLabel = [[UILabel alloc] init];
	
	TripViewController *controller = [[TripViewController alloc] initWithSettings:settings];
	[controller viewDidLoad];
	controller.fareLabel = fareLabel;
	
	[controller tripRecorder:nil updatedFare:12.50];
	
	NSString *actual = controller.fareLabel.text;
	XCTAssert([actual isEqualToString:@"£12.50"]);

}
- (void)testShowCorrectCurrencyForUSUser {
	Settings *settings = [Settings new];
	settings.locale = [NSLocale localeWithLocaleIdentifier:@"en-US"];
	UILabel *fareLabel = [[UILabel alloc] init];
	TripViewController *controller = [[TripViewController alloc] initWithSettings:settings];
	[controller viewDidLoad];
	controller.fareLabel = fareLabel;
	
	[controller tripRecorder:nil updatedFare:12.50];
	
	NSString *actual = controller.fareLabel.text;
	XCTAssert([actual isEqualToString:@"$12.50"]);

}


@end
