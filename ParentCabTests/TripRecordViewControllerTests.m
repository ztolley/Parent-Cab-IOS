
//
//  TripRecordViewControllerTests.m
//  ParentCab
//
//  Created by Zac Tolley on 22/08/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Settings.h"
#import "Journey.h"
#import "PCabCoreDataHelper.h"
#import "TripRecordViewController.h"

@interface TripRecordViewControllerTests : XCTestCase

@end

@implementation TripRecordViewControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
	Settings *settings = [Settings defaultSettings];
	[settings reset];
	[super tearDown];
}

- (void)testFareInPounds {
	
	Settings *settings = [Settings new];
	settings.locale = [NSLocale localeWithLocaleIdentifier:@"en-GB"];
	
	PCabCoreDataHelper *cdh = [[PCabCoreDataHelper alloc] init];
	Journey *journey = [cdh getNewJourney];
	journey.fare = 123.50;
	
	TripRecordViewController *tvc = [[TripRecordViewController alloc] initWithSettings:settings];
	tvc.journey = journey;

	UILabel *fareLabel = [[UILabel alloc] init];
	tvc.fairLabel = fareLabel;
	
	[tvc viewWillAppear:NO];
	
	NSString *fareText = tvc.fairLabel.text;
	
	XCTAssert([fareText isEqualToString:@"£123.50"]);
}

- (void)testFareInDollars {
	Settings *settings = [Settings new];
	settings.locale = [NSLocale localeWithLocaleIdentifier:@"en-US"];
	
	PCabCoreDataHelper *cdh = [[PCabCoreDataHelper alloc] init];
	Journey *journey = [cdh getNewJourney];
	journey.fare = 123.50;
	
	TripRecordViewController *tvc = [[TripRecordViewController alloc] initWithSettings:settings];
	tvc.journey = journey;
	
	UILabel *fareLabel = [[UILabel alloc] init];
	tvc.fairLabel = fareLabel;
	
	[tvc viewWillAppear:NO];
	
	NSString *fareText = tvc.fairLabel.text;
	
	XCTAssert([fareText isEqualToString:@"$123.50"]);

}

- (void)testSharedFareInPounds {
	Settings *settings = [Settings new];
	settings.locale = [NSLocale localeWithLocaleIdentifier:@"en-GB"];
	
	PCabCoreDataHelper *cdh = [[PCabCoreDataHelper alloc] init];
	Journey *journey = [cdh getNewJourney];
	journey.fare = 123.50;
	
	TripRecordViewController *tvc = [[TripRecordViewController alloc] initWithSettings:settings];
	
	
	NSString *shareText = [tvc generateEmailBodyForJourney:journey];
	
	
	XCTAssert([shareText hasPrefix:@"Fare: £123.50"]);
	
}

- (void)testSharedFareInDollars {
	Settings *settings = [Settings new];
	settings.locale = [NSLocale localeWithLocaleIdentifier:@"en-US"];
	
	PCabCoreDataHelper *cdh = [[PCabCoreDataHelper alloc] init];
	Journey *journey = [cdh getNewJourney];
	journey.fare = 123.50;
	
	TripRecordViewController *tvc = [[TripRecordViewController alloc] initWithSettings:settings];

	
	NSString *shareText = [tvc generateEmailBodyForJourney:journey];
	
	
	XCTAssert([shareText hasPrefix:@"Fare: $123.50"]);
	
}

@end
