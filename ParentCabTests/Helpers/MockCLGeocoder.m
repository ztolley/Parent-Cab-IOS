//
//  MockCLGeocoder.m
//  ParentCab
//
//  Created by Zac Tolley on 18/08/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import "MockCLGeocoder.h"
#import "PCPlacemark.h"

@implementation MockCLGeocoder



- (void)reverseGeocodeLocation:(CLLocation *)location
			 completionHandler:(CLGeocodeCompletionHandler)completionHandler
{
	if (completionHandler != nil) {
	
		//PCPlacemark *placemark = [[PCPlacemark alloc] init];
		//NSArray *placemarks = [[NSArray alloc] initWithObjects:placemark, nil];
		completionHandler(nil, nil);
		//return;
	}
	
}


@end
