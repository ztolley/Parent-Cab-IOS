//
//  JourneyRouteDataSource.m
//  Parentcab_iOS
//
//  Created by Zac Tolley on 14/11/2012.
//  Copyright (c) 2012 Exsite Consultants. All rights reserved.
//

#import "JourneyRouteDataSource.h"
#import "Journey.h"
#import "Step.h"
#import "Location.h"
#import "StepLocation.h"

@interface JourneyRouteDataSource ()
{
	NSArray *steps;
}
@end


@implementation JourneyRouteDataSource

- (id)initWithJourney:(Journey *)journey
{
	self = [super init];
	if (self) {
		self.journey = journey;
		
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
		steps = [journey.steps sortedArrayUsingDescriptors:@[sortDescriptor]];
	}
	return self;
	
}

#pragma mark - RouteOverlayDataSource
- (NSUInteger)numberOfCoordinatesInRouteOverlay:(RouteOverlay *)overlay
{
	return [self.journey.steps count];
}
- (CLLocationCoordinate2D)locationForRouteOverlay:(RouteOverlay *)overlay AtIndex:(NSUInteger)index
{
	CLLocationCoordinate2D location;
	
	Step *step = steps[index];
	
	location.latitude = step.location.latitude;
	location.longitude = step.location.longitude;
	
	return location;
}


@end
