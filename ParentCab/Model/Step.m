//
//  Step.m
//  ParentCab
//
//  Created by Zac Tolley on 19/07/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import "Step.h"
#import "Location.h"

@implementation Step

@dynamic timestamp;
@dynamic location;

-(NSString *)toString {
	return [NSString stringWithFormat:@"lat:%f long:%f", self.location.latitude, self.location.latitude];
}

@end
