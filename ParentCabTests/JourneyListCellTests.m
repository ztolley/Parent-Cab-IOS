//
//  JourneyListCellTests.m
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
#import "JourneyListCell.h"

@interface JourneyListCellTests : XCTestCase
@end

@implementation JourneyListCellTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testFareInPounds {

	Settings *settings = [Settings new];
	settings.locale = [NSLocale localeWithLocaleIdentifier:@"en-GB"];
	
	PCabCoreDataHelper *cdh = [[PCabCoreDataHelper alloc] init];
	Journey *journey = [cdh getNewJourney];
	journey.fare = 123.50;
	
	JourneyListCell *cell = [[JourneyListCell alloc] initWithSettings:settings];
	[cell awakeFromNib];
	
	UILabel *fareLabel = [[UILabel alloc] init];
	cell.fare = fareLabel;
	
	[cell setJourney:journey];
	
	NSString *fareText = cell.fare.text;

	XCTAssert([fareText isEqualToString:@"£123.50"]);
}

- (void)testFareInDollars {

	Settings *settings = [Settings new];
	settings.locale = [NSLocale localeWithLocaleIdentifier:@"en-US"];
	
	PCabCoreDataHelper *cdh = [[PCabCoreDataHelper alloc] init];
	
	Journey *journey = [cdh getNewJourney];
	journey.fare = 123.50;
	
	JourneyListCell *cell = [[JourneyListCell alloc] initWithSettings:settings];
	[cell awakeFromNib];
	
	UILabel *fareLabel = [[UILabel alloc] init];
	cell.fare = fareLabel;
	
	[cell setJourney:journey];
	
	NSString *fareText = cell.fare.text;
	
	XCTAssert([fareText isEqualToString:@"$123.50"]);
}


@end
