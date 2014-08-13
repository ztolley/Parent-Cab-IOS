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
@class Location;


@interface PCabCoreDataHelper : CoreDataHelper

- (Journey *)getNewJourney;
- (Step *)getNewStep;
- (Location *)getNewLocation;
- (void)deleteJourney:(Journey *)journey;

@end
