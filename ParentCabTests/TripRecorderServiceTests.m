//
//  TripRecorderServiceTests.m
//  ParentCab
//
//  Created by Zac Tolley on 13/08/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <CoreData/CoreData.h>
#import "PCabCoreDataHelper.h"
#import "TripRecorderService.h"
#import "AppDelegate.h"
#import "model.h"

@interface TripRecorderServiceTests : XCTestCase

@end

@implementation TripRecorderServiceTests
{
	TripRecorderService *tripRecorderService;
	PCabCoreDataHelper *cdh;
}

- (void)setUp {
	[super setUp];
	
	cdh = [PCabCoreDataHelper new];
	[cdh setupCoreData];
	
	// switch the core data helper for one that we created that has an in memory context for testing
	tripRecorderService = [[TripRecorderService alloc] init];
	tripRecorderService.cdh = cdh;

}

- (void)tearDown {
	[super tearDown];
	NSManagedObjectContext *context = cdh.context;
	
	NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:@"Journey" inManagedObjectContext:context]];
	
	NSArray * result = [context executeFetchRequest:fetch error:nil];
	
	for (id journey in result) {
		[context deleteObject:journey];
	}

	tripRecorderService = nil;
	cdh = nil;
	
}


- (void)testRecordStartTimeWhenJourneyStarts {
	[tripRecorderService startRecording];
	XCTAssertNotNil(tripRecorderService.currentJourney,					@"Test there is a journey object to hold the time");
	XCTAssertTrue(tripRecorderService.currentJourney.startTime != 0,	@"Make sure the time object has been set");
}


@end
