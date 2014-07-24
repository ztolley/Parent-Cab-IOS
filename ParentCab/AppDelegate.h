#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class PCabCoreDataHelper;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;

- (PCabCoreDataHelper*)cdh;
@end

