//
//  Step.h
//  ParentCab
//
//  Created by Zac Tolley on 19/07/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class Location;

@interface Step : NSManagedObject

@property (nonatomic) NSTimeInterval timestamp;
@property (nonatomic, retain) Location *location;

-(NSString *)toString;

@end
