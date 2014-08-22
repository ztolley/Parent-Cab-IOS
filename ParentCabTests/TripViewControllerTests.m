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
	TripViewController *tvc;
	UILabel *distanceLabel;
	UILabel *fareLabel;
}
- (void)setUp {
    [super setUp];
	tvc = [[TripViewController alloc] init];
	[tvc viewDidLoad];
	distanceLabel = [[UILabel alloc] init];
	fareLabel = [[UILabel alloc] init];
	tvc.distanceLabel = distanceLabel;
	tvc.fareLabel = fareLabel;
	
	self.originalLocale = tvc.settings.locale;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
	tvc.settings.locale = self.originalLocale;
	[super tearDown];

}

- (void)testDistanceChangesAreShownInKm {
	[tvc tripRecorder:nil updatedDistance:1200];

	NSString *actual = tvc.distanceLabel.text;
	
	XCTAssert([actual isEqualToString:@"1.20 km"]);
}

- (void)testShowCorrectCurrencyForGBUser {
	
	NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en-GB"];
	tvc.settings.locale = locale;
	
	[tvc tripRecorder:nil updatedFare:12.50];
	
	NSString *actual = tvc.fareLabel.text;
	XCTAssert([actual isEqualToString:@"£12.50"]);

}
- (void)testShowCorrectCurrencyForUSUser {
	
	NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en-US"];
	tvc.settings.locale = locale;
	
	[tvc tripRecorder:nil updatedFare:12.50];
	
	NSString *actual = tvc.fareLabel.text;
	XCTAssert([actual isEqualToString:@"$12.50"]);

}


@end
