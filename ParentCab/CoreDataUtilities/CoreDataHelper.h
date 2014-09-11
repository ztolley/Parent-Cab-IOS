#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper : NSObject

@property (nonatomic, readonly) NSManagedObjectContext       *parentContext;
@property (nonatomic, readonly) NSManagedObjectContext       *context;
@property (nonatomic, readonly) NSManagedObjectModel         *model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, readonly) NSPersistentStore            *store;

@property (nonatomic, readonly) NSManagedObjectContext       *seedContext;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *seedCoordinator;
@property (nonatomic, readonly) NSPersistentStore            *seedStore;
@property (nonatomic)           BOOL                          seedInProgress;

@property (nonatomic, readonly) NSPersistentStore *iCloudStore;

+ (CoreDataHelper*)sharedHelper;
- (void)setupCoreData;
- (void)saveContext;
- (void)backgroundSaveContext;
- (BOOL)reloadStore;
- (NSURL *)applicationStoresDirectory;
- (BOOL)iCloudAccountIsSignedIn;
- (void)ensureAppropriateStoreIsLoaded;
- (BOOL)iCloudEnabledByUser;

@end
