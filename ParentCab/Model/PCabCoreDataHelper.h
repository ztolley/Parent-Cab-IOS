//
//  PCabCoreDataHelper.h
//  ParentCab
//
//  Created by Zac Tolley on 24/07/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import "CoreDataHelper.h"

@class Journey;
@class Step;
@class StartLocation;
@class EndLocation;
@class StepLocation;


@interface PCabCoreDataHelper : CoreDataHelper

- (Journey *)getNewJourney;
- (Step *)getNewStep;
- (StartLocation *)getNewStartLocation;
- (EndLocation *)getNewEndLocation;
- (StepLocation *)getNewStepLocation;
- (void)deleteJourney:(Journey *)journey;

@end
