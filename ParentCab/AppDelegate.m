//
//  AppDelegate.m
//  ParentCab
//
//  Created by Zac Tolley on 19/07/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import "AppDelegate.h"
#import "PCabCoreDataHelper.h"
#import "SDCloudUserDefaults.h"

@interface AppDelegate ()
@property (nonatomic, strong, readonly) PCabCoreDataHelper *coreDataHelper;
@end

@implementation AppDelegate
#define debug 0

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	// Override point for customization after application launch.
	_coreDataHelper = [PCabCoreDataHelper new];
	[_coreDataHelper setupCoreData];
	[_coreDataHelper iCloudAccountIsSignedIn];

	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	[[self cdh] saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	[[self cdh] ensureAppropriateStoreIsLoaded];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	[[self cdh] saveContext];
}



- (PCabCoreDataHelper*)cdh {
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	if (!_coreDataHelper) {
		static dispatch_once_t predicate;
		dispatch_once(&predicate, ^{
			_coreDataHelper = [PCabCoreDataHelper new];
		});
		[_coreDataHelper setupCoreData];
	}
	return _coreDataHelper;
}



@end
