#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper :NSObject


@property (nonatomic, readonly) NSManagedObjectContext       *context;
@property (nonatomic, readonly) NSManagedObjectContext       *parentContext;

@property (nonatomic, readonly) NSManagedObjectModel         *model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, readonly) NSPersistentStore            *store;

@property (nonatomic, readonly) NSPersistentStore			 *iCloudStore;

- (void)setupCoreData;
- (void)saveContext;
- (void)backgroundSaveContext;
- (NSURL *)applicationStoresDirectory;

- (BOOL)iCloudAccountIsSignedIn;

@end