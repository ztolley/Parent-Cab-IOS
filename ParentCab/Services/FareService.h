//
//  FareService.h
//  ParentCab
//
//  Created by Zac Tolley on 14/08/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CLLocation;

struct Fare
{
	double money;
	double distance;
};

@interface FareService : NSObject
- (struct Fare)fareForMoveFromLocation:(CLLocation *)startLocation toLocation:(CLLocation *)endLocation;
extern NSString *const RATEKEY;
@end

