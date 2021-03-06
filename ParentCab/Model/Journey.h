//
//  Journey.h
//  ParentCab
//
//  Created by Zac Tolley on 05/09/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EndLocation, StartLocation, Step;

@interface Journey : NSManagedObject

@property (nonatomic) double distance;
@property (nonatomic) NSTimeInterval endTime;
@property (nonatomic) double fare;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic, retain) EndLocation *endLocation;
@property (nonatomic, retain) StartLocation *startLocation;
@property (nonatomic, retain) NSSet *steps;
@end

@interface Journey (CoreDataGeneratedAccessors)

- (void)addStepsObject:(Step *)value;
- (void)removeStepsObject:(Step *)value;
- (void)addSteps:(NSSet *)values;
- (void)removeSteps:(NSSet *)values;

@end
