//
//  GoogleMapsImage.h
//  Parentcab_iOS
//
//  Created by Zac Tolley on 05/12/2012.
//  Copyright (c) 2012 Exsite Consultants. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Journey;

@interface GoogleMapsImage : NSObject


+ (NSString *)encodeStringWithCoordinates:(NSArray *)steps;
+ (NSData *)getRouteMapForJourney:(Journey *)journey;
+ (NSString *)mapUrlForJourney:(Journey *)journey;
@end
