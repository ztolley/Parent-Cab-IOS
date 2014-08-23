//
//  FareService.m
//  ParentCab
//
//  Created by Zac Tolley on 14/08/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import "FareService.h"
#import <CoreLocation/CoreLocation.h>
#import "Settings.h"



@implementation FareService


- (struct Fare)fareForMoveFromLocation:(CLLocation *)startLocation toLocation:(CLLocation *)endLocation
{
	CLLocationDistance distanceBetweenPoints = [startLocation distanceFromLocation:endLocation];
	double fareForDistance = [self fareForDistance:distanceBetweenPoints];

	struct Fare fare;
	fare.distance = [self rounded:distanceBetweenPoints];
	fare.money = [self rounded:fareForDistance];
	
	return fare;
}

- (double)fareForDistance:(double)distance {
	Settings *settings = [Settings defaultSettings];
	
	
	float pricePerkm = [settings getRate];
	
	return [self rounded:(distance/1000)] * pricePerkm;
}

- (double)rounded:(double)amount {
	NSString *string = [NSString stringWithFormat:@"%.2f", amount];
	return [string doubleValue];
}


@end
