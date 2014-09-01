//
//  StepLocation.h
//  ParentCab
//
//  Created by Zac Tolley on 01/09/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Location.h"

@class Step;

@interface StepLocation : Location

@property (nonatomic, retain) Step *step;

@end
