//
//  SettingsTests.m
//  ParentCab
//
//  Created by Zac Tolley on 18/08/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Settings.h"

@interface SettingsTests : XCTestCase
{
	NSUserDefaults *defaults;
	Settings *settings;
}
@end

@implementation SettingsTests

- (void)setUp {
    [super setUp];
	settings = [[Settings alloc] init];
	
	defaults = [NSUserDefaults standardUserDefaults];
	
	// delete any saved values for rate, distance
	
	[defaults removeObjectForKey:DISTANCEUNITKEY];
	[defaults removeObjectForKey:RATEKEY];

}

- (void)tearDown {
	settings = nil;
    [super tearDown];
}

- (void)testGetDefaultRate {
	float rate = [settings getRate];
	XCTAssertEqual(.63f, rate);
}
- (void)testSetRate {
	[settings setRate:.10];
	float rate = [settings getRate];
	XCTAssertEqual(.1f, rate);
}


- (void)testGetDefaultUKDistance {
	NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en-GB"];
	settings.locale = locale;
	NSString *distanceUnit = [settings getDistanceUnit];
	XCTAssertTrue([distanceUnit isEqualToString:@"miles"]);
}
- (void)testGetDefaultUSDistance {
	NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en-US"];
	settings.locale = locale;
	NSString *distanceUnit = [settings getDistanceUnit];
	XCTAssertTrue([distanceUnit isEqualToString:@"miles"]);
}
- (void)testGetDefaultNonUKUSDistance {
	NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"fr_FR"];
	settings.locale = locale;
	NSString *distanceUnit = [settings getDistanceUnit];
	XCTAssertTrue([distanceUnit isEqualToString:@"km"]);
}
- (void)testSetDefaultDistance {
	[settings setDistanceUnit:@"slep"];
	
	NSString *distanceUnit = [settings getDistanceUnit];
	XCTAssertTrue([distanceUnit isEqualToString:@"slep"]);
}


@end
