#import <Foundation/Foundation.h>

@interface Settings : NSObject

+ (id)defaultSettings;

- (void)setRate:(float)newRate;
- (float)getRate;

- (void)setDistanceUnit:(NSString *)newDistance;
- (NSString *)getDistanceUnit;

- (void)reset;

@property (strong, nonatomic)NSLocale *locale;

extern NSString *const SETTINGSMILES;
extern NSString *const SETTINGSKM;
@end
