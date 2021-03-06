//
//  Step.h
//  ParentCab
//
//  Created by Zac Tolley on 01/09/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Journey, StepLocation;

@interface Step : NSManagedObject

@property (nonatomic) NSTimeInterval timestamp;
@property (nonatomic, retain) Journey *journey;
@property (nonatomic, retain) StepLocation *location;

@end
