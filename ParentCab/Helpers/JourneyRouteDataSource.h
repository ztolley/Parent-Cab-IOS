//
//  JourneyRouteDataSource.h
//  Parentcab_iOS
//
//  Created by Zac Tolley on 14/11/2012.
//  Copyright (c) 2012 Exsite Consultants. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteOverlay.h"

@class Journey;

@interface JourneyRouteDataSource : NSObject
<RouteOverlayDataSource>
{

}

@property (strong, nonatomic) Journey *journey;

- (id)initWithJourney:(Journey *)journey;


@end
