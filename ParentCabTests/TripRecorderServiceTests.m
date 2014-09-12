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
#import "MockCLGeocoder.h"
#import <OCMock/OCMock.h>

@interface TripRecorderServiceTests : XCTestCase
<TripRecorderServiceDelegate>
@end

@implementation TripRecorderServiceTests
{
	TripRecorderService *tripRecorderService;
	PCabCoreDataHelper *cdh;
	double delegateDistance;
	double delegateFare;
}

- (void)setUp {
	[super setUp];
	
	cdh = [PCabCoreDataHelper new];
	[cdh setupCoreData];
	
	// switch the core data helper for one that we created that has an in memory context for testing
	tripRecorderService = [[TripRecorderService alloc] init];
	tripRecorderService.cdh = cdh;
	tripRecorderService.delegate = self;
	
	MockCLGeocoder *mockGeocoder = [[MockCLGeocoder alloc] init];
	tripRecorderService.geocoder = mockGeocoder;
	
	// Plus in a face reverse geocoder ...
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
	delegateFare = 0;
	delegateDistance = 0;
	
}

- (void)tripRecorder:(TripRecorderService *)tripRecorder updatedDistance:(double)distance {
	delegateDistance = distance;
}
- (void)tripRecorder:(TripRecorderService *)tripRecorder updatedFare:(double)fare {
	delegateFare = fare;
}


// Journey Starts
- (void)testRecordStartTimeWhenJourneyStarts {
	[tripRecorderService startRecording];
	XCTAssertNotNil(tripRecorderService.currentJourney,					@"Test there is a journey object to hold the time");
	XCTAssertTrue(tripRecorderService.currentJourney.startTime != 0,	@"Make sure the time object has been set");
}
- (void)testStartInitiatesLocationTracking {
	id locationManagerMock = [OCMockObject mockForClass:[CLLocationManager class]];
	[[locationManagerMock expect] startUpdatingLocation];
	tripRecorderService.locationManager = locationManagerMock;
	
	[tripRecorderService startRecording];
	[locationManagerMock verify];
	
}
- (void)testStartCreatesNewJourney {
	[tripRecorderService startRecording];
	
	XCTAssertNotNil(tripRecorderService.currentJourney, @"Journey should be added to service when you start a new journey");
}
- (void)testStartSetsCurrentTime {
	[tripRecorderService startRecording];
	XCTAssertNotEqual(tripRecorderService.currentJourney.startTime, 0, @"The journey has been populated with a time");
}


// Location changes
- (void)testRecordFirstPositionInJourney {
	[tripRecorderService startRecording];
	
	[self informDelegate:tripRecorderService locationChangedToLatitude:41.44994138650804 Longitude:-1.1874988592864875];
	
	XCTAssertTrue(tripRecorderService.currentJourney.startLocation.latitude  == 41.44994138650804,	@"Correct start latitude");
	XCTAssertTrue(tripRecorderService.currentJourney.startLocation.longitude == -1.1874988592864875, @"Correct start longitude");
	
}
- (void)testRecordFirstPositionInStepInJourney {
	
	[tripRecorderService startRecording];
	
	[self informDelegate:tripRecorderService locationChangedToLatitude:41.44994138650804 Longitude:-1.1874988592864875];
	
	NSArray *steps = [tripRecorderService.currentJourney.steps allObjects];
	Step *firstStep = [steps objectAtIndex:0];
	
	XCTAssertTrue(firstStep.location.latitude  == 41.44994138650804,		@"Correct latitude");
	XCTAssertTrue(firstStep.location.longitude == -1.1874988592864875,		@"Correct longitude");
	
}
- (void)testRecordSecondLocationChange {
	
	[tripRecorderService startRecording];
	
	[self informDelegate:tripRecorderService locationChangedToLatitude:41.44994138650804 Longitude:-1.187498859286487];
	[self informDelegate:tripRecorderService locationChangedToLatitude:42.44994138650804 Longitude:-2.187498859286487];
	
	
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
	NSArray *steps = [tripRecorderService.currentJourney.steps sortedArrayUsingDescriptors:@[sortDescriptor]];
	
	XCTAssertTrue(steps.count == 2, @"There are 2 steps recorded");
	
	Step *secondStep = [steps objectAtIndex:1];
	
	NSTimeInterval timestamp = secondStep.timestamp;
	double latitude = secondStep.location.latitude;
	double longitude = secondStep.location.longitude;
	
	XCTAssertNotEqual(timestamp,	0,				@"Make sure there is a timestap");
	XCTAssertTrue(latitude  == 42.44994138650804,	@"Correct latitude");
	XCTAssertTrue(longitude == -2.187498859286487,	@"Correct longitude");
	
}


// Reset deletes the current journey object
- (void)testResetDeletesObjectInContext {

	XCTAssertTrue([[self allJourneys] count] == 0);
	
	[tripRecorderService startRecording];
	[self informDelegate:tripRecorderService locationChangedToLatitude:41.44994138650804 Longitude:-1.1874988592864875];
	[tripRecorderService reset];
	
	// Check that the journey is no longer in the managed object context and the trip service has a nil current journey
	XCTAssertNil(tripRecorderService.currentJourney,@"Make sure we have a journey in the service still");
	
	XCTAssertTrue([[self allJourneys] count] == 0,	@"Check that there are no journeys in the moc");
	XCTAssertTrue([[self allSteps] count] == 0,		@"Check that there are no steps in the context");
}
- (void)testResetStopsLocationTracking {
	[tripRecorderService startRecording];
	
	id locationManagerMock = [OCMockObject mockForClass:[CLLocationManager class]];
	[[locationManagerMock expect] stopUpdatingLocation];
	tripRecorderService.locationManager = locationManagerMock;
	
	[tripRecorderService reset];
	[locationManagerMock verify];
}

- (void)testResetIssuesFareZeroNotification {

	[tripRecorderService startRecording];
	[self informDelegate:tripRecorderService locationChangedToLatitude:41.44994138650804 Longitude:-1.187498859286487];
	[self informDelegate:tripRecorderService locationChangedToLatitude:42.44994138650804 Longitude:-2.187498859286487];
	
	XCTAssertEqual(delegateDistance, 138607.60);
	
	[tripRecorderService reset];
	
	XCTAssert(delegateFare == 0);

}
- (void)testResetIssuesDistanceZeroNotification {
	[tripRecorderService startRecording];
	[self informDelegate:tripRecorderService locationChangedToLatitude:41.44994138650804 Longitude:-1.187498859286487];
	[self informDelegate:tripRecorderService locationChangedToLatitude:42.44994138650804 Longitude:-2.187498859286487];
	
	XCTAssert(delegateFare > 0);
	
	[tripRecorderService reset];
	
	XCTAssert(delegateFare == 0);
}
- (void)testResetDeletesTheJourneyObjectThatWasUsed {
	[tripRecorderService startRecording];
	[self informDelegate:tripRecorderService locationChangedToLatitude:41.44994138650804 Longitude:-1.187498859286487];
	[self informDelegate:tripRecorderService locationChangedToLatitude:42.44994138650804 Longitude:-2.187498859286487];
	[tripRecorderService reset];

	XCTAssertNil(tripRecorderService.currentJourney);
}


// Stop
- (void)testStopStopsLocationTracking {
	[tripRecorderService startRecording];
	
	id locationManagerMock = [OCMockObject mockForClass:[CLLocationManager class]];
	[[locationManagerMock expect] stopUpdatingLocation];
	tripRecorderService.locationManager = locationManagerMock;
	
	[tripRecorderService finish:nil];
	[locationManagerMock verify];
}

- (void)testStopRecordsFinalPositionAndTime {
	
	XCTestExpectation *endJourneyExpectation = [self expectationWithDescription:@"finish journey"];
	
	[tripRecorderService startRecording];
	[self informDelegate:tripRecorderService locationChangedToLatitude:41.44994138650804 Longitude:-1.187498859286487];
	[self informDelegate:tripRecorderService locationChangedToLatitude:42.44994138650804 Longitude:-2.187498859286487];
	[tripRecorderService finish:^(Journey *journey) {
		XCTAssertNotEqual(journey.endTime, 0, @"Make sure there is an end time");
		XCTAssertTrue(journey.endLocation.latitude  == 42.44994138650804,	@"Correct latitude");
		XCTAssertTrue(journey.endLocation.longitude == -2.187498859286487,	@"Correct longitude");
		[endJourneyExpectation fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

// Finish
// Test that ending a journey saves it in the context
- (void)testFinishJourneyStillInContextAfterFinish {
	XCTestExpectation *endJourneyExpectation = [self expectationWithDescription:@"finish journey"];

	
	[tripRecorderService startRecording];
	[self informDelegate:tripRecorderService locationChangedToLatitude:41.44994138650804 Longitude:-1.187498859286487];
	[self informDelegate:tripRecorderService locationChangedToLatitude:42.44994138650804 Longitude:-2.187498859286487];
	[tripRecorderService finish:^(Journey *journey) {
		NSArray *allJourneys = [self allJourneys];
		XCTAssertEqual(allJourneys.count, 1);
		[endJourneyExpectation fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

// Test that ending a journey saves that journey but sets the current journey to nil
- (void)testJourneyEndResetsJourney {
	
	XCTestExpectation *endJourneyExpectation = [self expectationWithDescription:@"finish journey"];

	
	[tripRecorderService startRecording];
	[self informDelegate:tripRecorderService locationChangedToLatitude:41.44994138650804 Longitude:-1.187498859286487];
	[self informDelegate:tripRecorderService locationChangedToLatitude:42.44994138650804 Longitude:-2.187498859286487];
	[tripRecorderService finish:^(Journey *journey) {
		XCTAssertNil(tripRecorderService.currentJourney);
		[endJourneyExpectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}


// Test that ending a journey resets the screen.
- (void)testJourneyEndResetsValues {

	XCTestExpectation *endJourneyExpectation = [self expectationWithDescription:@"finish journey"];

	
	[tripRecorderService startRecording];
	[self informDelegate:tripRecorderService locationChangedToLatitude:41.44994138650804 Longitude:-1.187498859286487];
	[self informDelegate:tripRecorderService locationChangedToLatitude:42.44994138650804 Longitude:-2.187498859286487];
	[tripRecorderService finish:^(Journey *journey) {
		XCTAssertEqual(delegateDistance, 0);
		XCTAssertEqual(delegateFare, 0);
		
		[endJourneyExpectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];

}

- (void)informDelegate:(TripRecorderService *)service locationChangedToLatitude:(double)latitude Longitude:(double)longitude {
	
	CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)
															altitude:0
												  horizontalAccuracy:0
													verticalAccuracy:0
														   timestamp:[NSDate date]];
	
	NSArray *locations = [NSArray arrayWithObject:newLocation];
	[service locationManager:nil didUpdateLocations:locations];
	
}
- (NSArray *)allSteps {
	NSManagedObjectContext *context = cdh.context;
	
	NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:@"Step" inManagedObjectContext:context]];
	
	NSArray * result = [context executeFetchRequest:fetch error:nil];

	return result;
}
- (NSArray *)allJourneys {
	NSManagedObjectContext *context = cdh.context;
	
	NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:@"Journey" inManagedObjectContext:context]];
	
	NSArray * result = [context executeFetchRequest:fetch error:nil];
	
	return result;
}


// Delegate Protocol
// Inform delegate of change in fare when position changes
- (void)testSendFareToDelegate {
	
	[tripRecorderService startRecording];
	[self informDelegate:tripRecorderService locationChangedToLatitude:41.44994138650804 Longitude:-1.187498859286487];
	[self informDelegate:tripRecorderService locationChangedToLatitude:42.44994138650804 Longitude:-2.187498859286487];
	
	XCTAssert(delegateFare > 0);

}

// Doesn't tell delegate of fare change on first location
- (void)testDondSendFareToDelegateForSingleMove {
	
	[tripRecorderService startRecording];
	[self informDelegate:tripRecorderService locationChangedToLatitude:41.44994138650804 Longitude:-1.187498859286487];
	
	XCTAssert(delegateFare == 0);
	
}

// Inform delegate of change in distance when position changes
- (void)testSendDistanceToDelegate {
	
	[tripRecorderService startRecording];
	[self informDelegate:tripRecorderService locationChangedToLatitude:41.44994138650804 Longitude:-1.187498859286487];
	[self informDelegate:tripRecorderService locationChangedToLatitude:42.44994138650804 Longitude:-2.187498859286487];
	
	XCTAssertEqual(delegateDistance, 138607.60);
	
}
// Doesn't tell delegate of distamce change on first location
- (void)testDontSendDistanceToDelegateForSingleMove {
	
	[tripRecorderService startRecording];
	[self informDelegate:tripRecorderService locationChangedToLatitude:41.44994138650804 Longitude:-1.187498859286487];

	XCTAssertEqual(delegateDistance,0);
	
}
@end
