//
//  CoreDataHelper.m
//  Grocery Dude
//
//  Created by Tim Roadley on 18/09/13.
//  Copyright (c) 2013 Tim Roadley. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper
#define debug 0

#pragma mark - FILES
NSString *storeFilename = @"parentcab.sqlite";
NSString *iCloudStoreFilename = @"iCloud.sqlite";

#pragma mark - PATHS
- (NSString *)applicationDocumentsDirectory {
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class,NSStringFromSelector(_cmd));
	}
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) lastObject];
}
- (NSURL *)applicationStoresDirectory {
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	
	NSURL *storesDirectory =
	[[NSURL fileURLWithPath:[self applicationDocumentsDirectory]]
	 URLByAppendingPathComponent:@"Stores"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:[storesDirectory path]]) {
		NSError *error = nil;
		if ([fileManager createDirectoryAtURL:storesDirectory
				  withIntermediateDirectories:YES
								   attributes:nil
										error:&error]) {
			if (debug==1) {
				NSLog(@"Successfully created Stores directory");}
		}
		else {NSLog(@"FAILED to create Stores directory: %@", error);}
	}
	return storesDirectory;
}
- (NSURL *)storeURL {
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	return [[self applicationStoresDirectory]
			URLByAppendingPathComponent:storeFilename];
}
- (NSURL *)iCloudStoreURL {
	
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	
	return [[self applicationStoresDirectory] URLByAppendingPathComponent:iCloudStoreFilename];
}

#pragma mark - SETUP
- (id)init {
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	self = [super init];
	if (!self) {return nil;}
	
	_model = [NSManagedObjectModel mergedModelFromBundles:nil];
	_coordinator = [[NSPersistentStoreCoordinator alloc]
					initWithManagedObjectModel:_model];
	
	_parentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_parentContext performBlockAndWait:^{
        [_parentContext setPersistentStoreCoordinator:_coordinator];
        [_parentContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    }];
    
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_context setParentContext:_parentContext];
    [_context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
	
	
	return self;
}
- (void)loadStore {
	
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	
	// Don’t load store if it's already loaded
	if (_store) {
		return;
	}
	
	NSDictionary *options = @{
							  NSMigratePersistentStoresAutomaticallyOption: @YES,
							  NSInferMappingModelAutomaticallyOption: @YES
							  };
	
	NSError *error = nil;
	_store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
										configuration:nil
												  URL:[self storeURL]
											  options:options
												error:&error];
	
	if (!_store) {
		NSLog(@"Failed to add store. Error: %@", error);
		abort();
	} else {
		if (debug==1) {
			NSLog(@"Successfully added store: %@", _store);
		}
	}
}
- (void)setupCoreData {
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	if (![self loadiCloudStore]) {
		[self loadStore];
	}
}

#pragma mark - Stuff
- (void)resetContext:(NSManagedObjectContext*)moc {
    [moc performBlockAndWait:^{
        [moc reset];
    }];
}

#pragma mark - SAVING
- (void)saveContext {
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	if ([_context hasChanges]) {
		NSError *error = nil;
		if ([_context save:&error]) {
			NSLog(@"_context SAVED changes to persistent store");
		} else {
			NSLog(@"Failed to save _context: %@", error);
		}
	} else {
		NSLog(@"SKIPPED _context save, there are no changes!");
	}
}
- (void)backgroundSaveContext {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // First, save the child context in the foreground (fast, all in memory)
    [self saveContext];
    
    // Then, save the parent context.
    [_parentContext performBlock:^{
        if ([_parentContext hasChanges]) {
            NSError *error = nil;
            if ([_parentContext save:&error]) {
                NSLog(@"_parentContext SAVED changes to persistent store");
            }
            else {
                NSLog(@"_parentContext FAILED to save: %@", error);
                //[self showValidationError:error];
            }
        }
        else {
            NSLog(@"_parentContext SKIPPED saving as there are no changes");
        }
    }];
}




#pragma mark - iCloud
- (BOOL)iCloudAccountIsSignedIn {
	
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	
	id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
	
	if (token) {
		NSLog(@" ** iCloud is SIGNED IN with token '%@'  **", token);
		return YES;
	}
	
	NSLog(@" ** iCloud is NOT SIGNED IN **");
	return NO;
	
}
- (BOOL)loadiCloudStore {
	
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	
	if (_iCloudStore) {
		return YES;
	}
	
	NSDictionary *options = @{
							  NSMigratePersistentStoresAutomaticallyOption: @YES,
							  NSInferMappingModelAutomaticallyOption: @YES,
							  NSPersistentStoreUbiquitousContentNameKey: @"ParentCab"
							  };
	
	NSError *error = nil;
	
	_iCloudStore = [_coordinator addPersistentStoreWithType: NSSQLiteStoreType
											  configuration: nil
														URL: [self iCloudStoreURL]
													options: options
													  error: &error];
	
	if (_iCloudStore) {
		NSLog(@" ** The iCloud Store has been successfully configured at '%@'  **", _iCloudStore.URL.path);
		return YES;
	}
	
	NSLog(@" ** Failed to configure the iCloud Store: %@ **", error);
	return NO;
	
}
- (void)listenForStoreChanges {
	
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	
	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
	[dc addObserver:self
		   selector:@selector(storesWillChange:)
			   name:NSPersistentStoreCoordinatorStoresWillChangeNotification
			 object:_coordinator];
	
	[dc addObserver:self
		   selector:@selector(storesDidChange:)
			   name: NSPersistentStoreCoordinatorStoresDidChangeNotification
			 object:_coordinator];
	
	[dc addObserver:self
		   selector:@selector(persistentStoreDidImportUbiquitousContentChange:)
			   name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
			 object:_coordinator];
	
	
}

- (void)storesWillChange:(NSNotification *)n {
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	
	[_context performBlockAndWait:^{
		[_context save:nil];
		[self resetContext: _context];
	}];
	
    [_parentContext performBlockAndWait:^{
        [_parentContext save:nil];
        [self resetContext:_parentContext];
    }];
	// Refresh UI
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged"
														object:nil
													  userInfo:nil];

}
- (void)storesDidChange:(NSNotification *)n {
	
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged"
														object:nil
													  userInfo:nil];
	
}
- (void)persistentStoreDidImportUbiquitousContentChange:(NSNotification *)n {
	
	if (debug==1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}

	[_context performBlock:^{
		
		[_context mergeChangesFromContextDidSaveNotification:n];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged"
															object:nil
														  userInfo:nil];
	}];

}


@end
