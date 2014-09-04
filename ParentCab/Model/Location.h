//
//  Location.h
//  ParentCab
//
//  Created by Zac Tolley on 01/09/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Location : NSManagedObject

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, retain) NSString * postcode;
@property (nonatomic, retain) NSString * thoroughfare;

@end
