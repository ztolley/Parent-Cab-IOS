#import "Settings.h"

NSString *const RATEKEY = @"PencePerMeter";
NSString *const DISTANCEUNITKEY = @"DistanceUnit";

@interface Settings ()
{
	NSUserDefaults *defaults;
}
@end


@implementation Settings

- (instancetype)init
{
    self = [super init];
    if (self) {
        defaults = [NSUserDefaults standardUserDefaults];
		_locale = [NSLocale currentLocale];
    }
    return self;
}

- (void)setRate:(float)newRate {
	[defaults setFloat:newRate forKey:RATEKEY];
}
- (float)getRate {

	float defaultRate = [defaults floatForKey:RATEKEY];
	
	if (defaultRate == 0) {
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSNumber *appDefaultRate = [mainBundle objectForInfoDictionaryKey:RATEKEY];
		defaultRate = appDefaultRate.floatValue;
		[defaults setFloat:defaultRate forKey:RATEKEY];
	}
	
	return defaultRate;
}

- (void)setDistanceUnit:(NSString *)newDistance {
	[defaults setObject:newDistance forKey:DISTANCEUNITKEY];
}
- (NSString *)getDistanceUnit {
	NSString *distanceUnit = [defaults stringForKey:DISTANCEUNITKEY];

	if (distanceUnit == nil) {
		distanceUnit = [self distanceUnitForLocale];
	}
	
	return distanceUnit;
}


- (NSString *)distanceUnitForLocale {
	
	NSString *countryCode = [_locale objectForKey: NSLocaleCountryCode];
	
	if ([countryCode isEqualToString:@"GB"] || [countryCode isEqualToString:@"US"]) {
		return @"miles";
	} else {
		return @"km";
	}
	
}

@end
