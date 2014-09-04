//
//  Journey.h
//  ParentCab
//
//  Created by Zac Tolley on 01/09/2014.
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
@property (nonatomic, retain) NSOrderedSet *steps;
@end

@interface Journey (CoreDataGeneratedAccessors)

- (void)insertObject:(Step *)value inStepsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromStepsAtIndex:(NSUInteger)idx;
- (void)insertSteps:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeStepsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInStepsAtIndex:(NSUInteger)idx withObject:(Step *)value;
- (void)replaceStepsAtIndexes:(NSIndexSet *)indexes withSteps:(NSArray *)values;
- (void)addStepsObject:(Step *)value;
- (void)removeStepsObject:(Step *)value;
- (void)addSteps:(NSOrderedSet *)values;
- (void)removeSteps:(NSOrderedSet *)values;
@end
