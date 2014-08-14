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

@interface TripViewControllerTests : XCTestCase


@end

@implementation TripViewControllerTests
{
	TripViewController *tvc;
}
- (void)setUp {
    [super setUp];
	tvc = [[TripViewController alloc] init];
	UILabel *distanceLabel = [[UILabel alloc]init];
	tvc.distanceLabel = distanceLabel;
	[tvc viewDidLoad];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDistanceChangesAreShownInKm {
	[tvc tripRecorder:nil updatedDistance:1200];

	XCTAssert([tvc.distanceLabel.text isEqualToString:@"1.20 km"]);
}


@end
