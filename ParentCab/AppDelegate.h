#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class CoreDataHelper;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) CoreDataHelper *coreDataHelper;

@end

