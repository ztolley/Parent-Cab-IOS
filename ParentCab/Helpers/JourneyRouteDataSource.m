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


@implementation JourneyRouteDataSource

- (id)initWithJourney:(Journey *)journey
{
	self = [super init];
	if (self) {
		self.journey = journey;
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

	Step *step = (Step *)[self.journey.steps objectAtIndex:index];
	
	location.latitude = step.location.latitude;
	location.longitude = step.location.longitude;
	
	return location;
}


@end
