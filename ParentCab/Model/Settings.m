#import "Settings.h"

NSString *const RATEKEY = @"PencePerMeter";
NSString *const DISTANCEUNITKEY = @"DistanceUnit";
NSString *const SETTINGSMILES = @"miles";
NSString *const SETTINGSKM = @"km";

@interface Settings ()
{
	NSUserDefaults *defaults;
}
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

- (void)reset {
	[defaults removeObjectForKey:RATEKEY];
	[defaults removeObjectForKey:DISTANCEUNITKEY];
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
