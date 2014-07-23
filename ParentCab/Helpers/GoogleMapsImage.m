//
//  GoogleMapsImage.m
//  Parentcab_iOS
//
//  Created by Zac Tolley on 05/12/2012.
//  Copyright (c) 2012 Exsite Consultants. All rights reserved.
//

#import "GoogleMapsImage.h"
#import "Model.h"
#import <MapKit/MapKit.h>


@implementation GoogleMapsImage

+ (NSData *)getRouteMapForJourney:(Journey *)journey {

	NSError *error = nil;
	NSString *urlStr = [self mapUrlForJourney:journey];
	NSURL *myUrl = [NSURL URLWithString:urlStr];
	NSData* data = [NSData dataWithContentsOfURL: myUrl
										 options:NSDataReadingUncached
										   error:&error];
	
	return data;
}

+ (NSString *)mapUrlForJourney:(Journey *)journey {
	NSString *encString = [self encodeStringWithCoordinates:journey.steps.array];
	NSString *urlEncString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)encString, NULL, CFSTR(";:"), kCFStringEncodingUTF8);
	NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?size=400x400&sensor=true&path=enc:%@", urlEncString];
	return url;
}

+ (NSString *)encodeStringWithCoordinates:(NSArray *)steps {
	NSMutableString *encodedString = [NSMutableString string];
	int val = 0;
	int value = 0;
	CLLocationCoordinate2D prevCoordinate = CLLocationCoordinate2DMake(0, 0);
	
	for (NSManagedObject *obj in steps) {
		Step *step = (Step *)obj;
		CLLocationCoordinate2D coordinate;
		Location *location = (Location *)step.location;
		coordinate.latitude = location.latitude;
		coordinate.longitude = location.longitude;
		
		// Encode latitude
		val = (int) round((coordinate.latitude - prevCoordinate.latitude) * 1e5);
		val = (val < 0) ? ~(val<<1) : (val <<1);
		while (val >= 0x20) {
			int calculatedValue = (0x20|(val & 31)) + 63;
			[encodedString appendFormat:@"%c", calculatedValue];
			val >>= 5;
		}
		[encodedString appendFormat:@"%c", val + 63];
		
		// Encode longitude
		val = (int) round((coordinate.longitude - prevCoordinate.longitude) * 1e5);
		val = (val < 0) ? ~(val<<1) : (val <<1);
		while (val >= 0x20) {
			value = (0x20|(val & 31)) + 63;
			[encodedString appendFormat:@"%c", value];
			val >>= 5;
		}
		[encodedString appendFormat:@"%c", val + 63];
		
		prevCoordinate = coordinate;
	}
	
	return encodedString;
}

@end
