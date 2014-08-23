//
//  PCabCoreDataHelper.m
//  ParentCab
//
//  Created by Zac Tolley on 24/07/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import "PCabCoreDataHelper.h"
#import "Journey.h"
#import "Step.h"
#import "Location.h"

@implementation PCabCoreDataHelper

- (Journey *)getNewJourney {
	Journey *journey = [NSEntityDescription insertNewObjectForEntityForName:@"Journey" inManagedObjectContext:self.context];
	return journey;
}
- (Step *)getNewStep {
	Step *step = [NSEntityDescription insertNewObjectForEntityForName:@"Step" inManagedObjectContext:self.context];
	return step;
}
- (Location *)getNewLocation {
	Location *location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.context];
	return location;
}
- (void)deleteJourney:(Journey *)journey {
	if (journey != nil) {
		[self.context deleteObject:journey];
	}
}


@end
