//
//  Journey.m
//  ParentCab
//
//  Created by Zac Tolley on 01/09/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import "Journey.h"
#import "EndLocation.h"
#import "StartLocation.h"
#import "Step.h"


@implementation Journey

@dynamic distance;
@dynamic endTime;
@dynamic fare;
@dynamic startTime;
@dynamic endLocation;
@dynamic startLocation;
@dynamic steps;

- (void)addStepsObject:(Step *)value {
	NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.steps];
	[tempSet addObject:value];
	self.steps = tempSet;
}

@end
