//
//  FareServiceTests.m
//  ParentCab
//
//  Created by Zac Tolley on 14/08/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <CoreLocation/CoreLocation.h>
#import "FareService.h"
#import "Settings.h"
@interface FareServiceTests : XCTestCase

@end

@implementation FareServiceTests

- (void)setUp {
    [super setUp];
	Settings *settings = [Settings defaultSettings];
	[settings setRate:0.20];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
	Settings *settings = [Settings defaultSettings];
	[settings reset];
}
- (void)testCalculateDistance {
	
	FareService *fareService = [[FareService alloc] init];
	
	// create 2 locations exactly 100km from each other
	CLLocation *startPoint = [[CLLocation alloc] initWithLatitude:51.450000 longitude:-0.704726];
	CLLocation *endPoint = [[CLLocation alloc] initWithLatitude:  51.458988205 longitude:-0.704726];
	
	
	// set the rate at 0.20p per km
	struct Fare fare = [fareService fareForMoveFromLocation:startPoint toLocation:endPoint];
	
	XCTAssertEqual(fare.distance, 1000);

	
}
- (void)testCalculateFare {

	FareService *fareService = [[FareService alloc] init];
	
	// create 2 locations exactly 100km from each other
	CLLocation *startPoint = [[CLLocation alloc] initWithLatitude:51.450000 longitude:-0.704726];
	CLLocation *endPoint = [[CLLocation alloc] initWithLatitude:  51.458988205 longitude:-0.704726];
	
	struct Fare fare = [fareService fareForMoveFromLocation:startPoint toLocation:endPoint];
	
	XCTAssertEqual(fare.money, 0.20);

	
}


@end
