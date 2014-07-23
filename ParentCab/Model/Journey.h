//
//  Journey.h
//  ParentCab
//
//  Created by Zac Tolley on 19/07/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class Location;

@interface Journey : NSManagedObject

@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval endTime;
@property (nonatomic) double distance;
@property (nonatomic) double fare;
@property (nonatomic, retain) Location *endLocation;
@property (nonatomic, retain) Location *startLocation;
@property (nonatomic, retain) NSOrderedSet *steps;
@end

@interface Journey (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inStepsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromStepsAtIndex:(NSUInteger)idx;
- (void)insertSteps:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeStepsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInStepsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceStepsAtIndexes:(NSIndexSet *)indexes withSteps:(NSArray *)values;
- (void)addStepsObject:(NSManagedObject *)value;
- (void)removeStepsObject:(NSManagedObject *)value;
- (void)addSteps:(NSOrderedSet *)values;
- (void)removeSteps:(NSOrderedSet *)values;
@end
