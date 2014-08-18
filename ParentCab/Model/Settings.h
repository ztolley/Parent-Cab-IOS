#import <Foundation/Foundation.h>

@interface Settings : NSObject

- (void)setRate:(float)newRate;
- (float)getRate;

- (void)setDistanceUnit:(NSString *)newDistance;
- (NSString *)getDistanceUnit;

@property (strong, nonatomic)NSLocale *locale;

extern NSString *const DISTANCEUNITKEY;
extern NSString *const RATEKEY;
@end
