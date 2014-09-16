#import "Settings.h"
#import "SDCloudUserDefaults.h"

NSString *const RATEKEY = @"PencePerMeter";
NSString *const DISTANCEUNITKEY = @"DistanceUnit";
NSString *const SETTINGSMILES = @"miles";
NSString *const SETTINGSKM = @"km";

@interface Settings ()

@end


@implementation Settings

+ (id)defaultSettings {
	
	static Settings *defaultSettings = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		defaultSettings = [[self alloc] init];
	});
	return defaultSettings;
	
}

- (instancetype)init
{
    self = [super init];
    if (self) {
		_locale = [NSLocale currentLocale];
    }
    return self;
}

- (void)setRate:(float)newRate {
	[SDCloudUserDefaults setFloat:newRate forKey:RATEKEY];
}
- (float)getRate {

	float defaultRate = [SDCloudUserDefaults floatForKey:RATEKEY];
	
	if (defaultRate == 0) {
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSNumber *appDefaultRate = [mainBundle objectForInfoDictionaryKey:RATEKEY];
		defaultRate = appDefaultRate.floatValue;
		[SDCloudUserDefaults setFloat:defaultRate forKey:RATEKEY];
	}
	
	return defaultRate;
}

- (void)setDistanceUnit:(NSString *)newDistance {
	[SDCloudUserDefaults setObject:newDistance forKey:DISTANCEUNITKEY];
}
- (NSString *)getDistanceUnit {
	NSString *distanceUnit = [SDCloudUserDefaults stringForKey:DISTANCEUNITKEY];

	if (distanceUnit == nil) {
		distanceUnit = [self distanceUnitForLocale];
	}
	
	return distanceUnit;
}

- (void)reset {
	[SDCloudUserDefaults removeObjectForKey:RATEKEY];
	[SDCloudUserDefaults removeObjectForKey:DISTANCEUNITKEY];
	_locale = [NSLocale currentLocale];
}

- (NSString *)distanceUnitForLocale {
	
	NSString *countryCode = [_locale objectForKey: NSLocaleCountryCode];
	
	if ([countryCode isEqualToString:@"GB"] || [countryCode isEqualToString:@"US"]) {
		return SETTINGSMILES;
	} else {
		return SETTINGSKM;
	}
	
}

@end
