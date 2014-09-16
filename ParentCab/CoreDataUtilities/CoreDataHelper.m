#import "CoreDataHelper.h"
#import "JourneyImporter.h"

@implementation CoreDataHelper

#define debug 0

#pragma mark - SHARED HELPER
+ (CoreDataHelper*)sharedHelper {
    
    static dispatch_once_t predicate;
    static CoreDataHelper *cdh = nil;
    dispatch_once(&predicate, ^{
        cdh = [CoreDataHelper new];
        [cdh setupCoreData];
    });
    return cdh;
}

#pragma mark - FILES
NSString *storeFilename = @"parentcab.sqlite";
NSString *iCloudStoreFilename = @"iCloud.sqlite";
NSString *ubiquityStoreName = @"ParentCab";

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
    [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]] URLByAppendingPathComponent:@"Stores"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[storesDirectory path]]) {
        NSError *error = nil;
        if ([fileManager createDirectoryAtURL:storesDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            if (debug==1) NSLog(@"Successfully created Stores directory");
        }
        else {
			if (debug==1) NSLog(@"FAILED to create Stores directory: %@", error);
		}
    }
    return storesDirectory;
}
- (NSURL *)storeURL {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [[self applicationStoresDirectory] URLByAppendingPathComponent:storeFilename];
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
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
    
    _parentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_parentContext performBlockAndWait:^{
        [_parentContext setPersistentStoreCoordinator:_coordinator];
        [_parentContext
         setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    }];
    
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_context setParentContext:_parentContext];
    [_context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
	
    _seedCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
    _seedContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_seedContext performBlockAndWait:^{
        [_seedContext setPersistentStoreCoordinator:_seedCoordinator];
        [_seedContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [_seedContext setUndoManager:nil]; // the default on iOS
    }];
    _seedInProgress = NO;
    
    [self listenForStoreChanges];
    return self;
}
- (void)loadStore {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_store) {return;} // Don’t load store if it’s already loaded
	
	NSDictionary *options =
	@{
	  NSMigratePersistentStoresAutomaticallyOption:@YES
	  ,NSInferMappingModelAutomaticallyOption:@YES
	  };
	NSError *error = nil;
	_store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
										configuration:nil
												  URL:[self storeURL]
											  options:options
												error:&error];
	if (!_store) {
		if (debug==1) NSLog(@"Failed to add store. Error: %@", error);abort();
	} else {
		if (debug==1) NSLog(@"Successfully added store: %@", _store);
	}

}
- (void)setupCoreData {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (!_store && !_iCloudStore) {

        if ([self iCloudEnabledByUser]) {
            if (debug==1) NSLog(@"** Attempting to load the iCloud Store **");
            if ([self loadiCloudStore]) {
                return;
            }
        }
        if (debug==1) {
			NSLog(@"** Attempting to load the Local, Non-iCloud Store **");
		}
        [self loadStore];
    } else {
        if (debug==1) {
			NSLog(@"SKIPPED setupCoreData, there's an existing Store:\n ** _store(%@)\n ** _iCloudStore(%@)", _store, _iCloudStore);
		}
    }
}

#pragma mark - SAVING
- (void)saveContext {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([_context hasChanges]) {
        NSError *error = nil;
        if ([_context save:&error]) {
            if (debug==1) NSLog(@"_context SAVED changes to persistent store");
        } else {
            if (debug==1) NSLog(@"Failed to save _context: %@", error);
            [self showValidationError:error];
        }
    } else {
        if (debug==1) NSLog(@"SKIPPED _context save, there are no changes!");
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
                if (debug==1) NSLog(@"_parentContext SAVED changes to persistent store");
            }
            else {
                if (debug==1) NSLog(@"_parentContext FAILED to save: %@", error);
                [self showValidationError:error];
            }
        }
        else {
            if (debug==1) NSLog(@"_parentContext SKIPPED saving as there are no changes");
        }
    }];
}

#pragma mark - VALIDATION ERROR HANDLING
- (void)showValidationError:(NSError *)anError {
    
    if (anError && [anError.domain isEqualToString:@"NSCocoaErrorDomain"]) {
        NSArray *errors = nil;  // holds all errors
        NSString *txt = @""; // the error message text of the alert
        
        // Populate array with error(s)
        if (anError.code == NSValidationMultipleErrorsError) {
            errors = [anError.userInfo objectForKey:NSDetailedErrorsKey];
        } else {
            errors = [NSArray arrayWithObject:anError];
        }
        // Display the error(s)
        if (errors && errors.count > 0) {
            // Build error message text based on errors
            for (NSError * error in errors) {
                NSString *entity =
                [[[error.userInfo objectForKey:@"NSValidationErrorObject"]entity]name];
                
                NSString *property =
                [error.userInfo objectForKey:@"NSValidationErrorKey"];
                
                switch (error.code) {
                    case NSValidationRelationshipDeniedDeleteError:
                        txt = [txt stringByAppendingFormat:
                               @"%@ delete was denied because there are associated %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
                        break;
                    case NSValidationRelationshipLacksMinimumCountError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' relationship count is too small (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationRelationshipExceedsMaximumCountError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' relationship count is too large (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationMissingMandatoryPropertyError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' property is missing (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationNumberTooSmallError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' number is too small (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationNumberTooLargeError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' number is too large (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationDateTooSoonError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' date is too soon (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationDateTooLateError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' date is too late (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationInvalidDateError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' date is invalid (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationStringTooLongError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' text is too long (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationStringTooShortError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' text is too short (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationStringPatternMatchingError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' text doesn't match the specified pattern (Code %li).", property, (long)error.code];
                        break;
                    case NSManagedObjectValidationError:
                        txt = [txt stringByAppendingFormat:
                               @"generated validation error (Code %li)", (long)error.code];
                        break;
                    default:
                        txt = [txt stringByAppendingFormat:
                               @"Unhandled error code %li in showValidationError method"
                               , (long)error.code];
                        break;
                }
            }
            // display error message txt message
            UIAlertView *alertView =
            [[UIAlertView alloc] initWithTitle:@"Validation Error"
                                       message:[NSString stringWithFormat:@"%@Please double-tap the home button and close this application by swiping the application screenshot upwards",txt]
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:nil];
            [alertView show];
        }
    }
}

#pragma mark – UNDERLYING DATA CHANGE NOTIFICATION
- (void)somethingChanged {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Send a notification that tells observing interfaces to refresh their data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
}

#pragma mark - CORE DATA RESET
- (void)resetContext:(NSManagedObjectContext*)moc {
    [moc performBlockAndWait:^{
        [moc reset];
    }];
}
- (BOOL)reloadStore {
    BOOL success = NO;
    NSError *error = nil;
    if (![_coordinator removePersistentStore:_store error:&error]) {
        NSLog(@"Unable to remove persistent store : %@", error);
    }
    [self resetContext:_context];
    [self resetContext:_parentContext];
    _store = nil;
    [self setupCoreData];
    [self somethingChanged];
    if (_store) {success = YES;}
    return success;
}
- (void)removeAllStoresFromCoordinator:(NSPersistentStoreCoordinator*)psc {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    for (NSPersistentStore *s in psc.persistentStores) {
        NSError *error = nil;
        if (![psc removePersistentStore:s error:&error]) {
            NSLog(@"Error removing persistent store: %@", error);
        }
    }
}
- (void)resetCoreData {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_context performBlockAndWait:^{
        [_context save:nil];
        [self resetContext:_context];
    }];
    [_parentContext performBlockAndWait:^{
        [_parentContext save:nil];
        [self resetContext:_parentContext];
    }];
    [self removeAllStoresFromCoordinator:_coordinator];
    _store = nil;
    _iCloudStore = nil;
}
- (BOOL)unloadStore:(NSPersistentStore*)ps {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (ps) {
        NSPersistentStoreCoordinator *psc = ps.persistentStoreCoordinator;
        NSError *error = nil;
        if (![psc removePersistentStore:ps error:&error]) {
            NSLog(@"ERROR removing store from the coordinator: %@",error);
            return NO; // Fail
        } else {
            ps = nil;
            return YES; // Reset complete
        }
    }
    return YES; // No need to reset, store is nil
}
- (void)removeFileAtURL:(NSURL*)url {
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] removeItemAtURL:url error:&error]) {
        NSLog(@"Failed to delete '%@' from '%@'", [url lastPathComponent], [url URLByDeletingLastPathComponent]);
    } else {
        if (debug==1) NSLog(@"Deleted '%@' from '%@'", [url lastPathComponent], [url URLByDeletingLastPathComponent]);
    }
}

#pragma mark - ICLOUD
- (BOOL)iCloudAccountIsSignedIn {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    if (token) {
        if (debug==1) NSLog(@"** iCloud is SIGNED IN with token '%@' **", token);
        return YES;
    }
    if (debug==1) NSLog(@"** iCloud is NOT SIGNED IN **");
    if (debug==1) NSLog(@"--> Is iCloud Documents and Data enabled for a valid iCloud account on your Mac & iOS Device or iOS Simulator?");
    if (debug==1) NSLog(@"--> Have you enabled the iCloud Capability in the Application Target?");
    if (debug==1) NSLog(@"--> Is there a CODE_SIGN_ENTITLEMENTS Xcode warning that needs fixing? You may need to specifically choose a developer instead of using Automatic selection");
    if (debug==1) NSLog(@"--> Are you using a Pre-iOS7 Simulator?");
    return NO;
}
- (BOOL)loadiCloudStore {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_iCloudStore) {return YES;} // Don’t load iCloud store if it’s already loaded
    
    NSDictionary *options =
    @{
      NSMigratePersistentStoresAutomaticallyOption:@YES
      ,NSInferMappingModelAutomaticallyOption:@YES
      ,NSPersistentStoreUbiquitousContentNameKey:ubiquityStoreName
      //,NSPersistentStoreUbiquitousContentURLKey:@"ChangeLogs" // Optional since iOS7
      };
    NSError *error;
    _iCloudStore = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                              configuration:nil
                                                        URL:[self iCloudStoreURL]
                                                    options:options
                                                      error:&error];
    if (_iCloudStore) {
        if (debug==1) NSLog(@"** The iCloud Store has been successfully configured at '%@' **", _iCloudStore.URL.path);
        [self mergeNoniCloudDataWithiCloud];
        //[self destroyAlliCloudDataForThisApplication];
        return YES;
    }
    if (debug==1) NSLog(@"** FAILED to configure the iCloud Store : %@ **", error);
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
               name:NSPersistentStoreCoordinatorStoresDidChangeNotification
             object:_coordinator];
    
    [dc addObserver:self
           selector:@selector(persistentStoreDidImportUbiquitiousContentChanges:)
               name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
             object:_coordinator];
}
- (void)storesWillChange:(NSNotification *)n {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

    [_context performBlockAndWait:^{
        [_context save:nil];
        [self resetContext:_context];
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
    // Refresh UI
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged"
                                                        object:nil
                                                      userInfo:nil];
}
- (void)persistentStoreDidImportUbiquitiousContentChanges:(NSNotification*)n {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_context performBlock:^{
        [_context mergeChangesFromContextDidSaveNotification:n];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged"
                                                            object:nil];
    }];
}
- (BOOL)iCloudEnabledByUser {
	return YES; // we assume the user always wants to use iCloud, after all they can opt out in system settings
}
- (void)ensureAppropriateStoreIsLoaded {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (!_store && !_iCloudStore) {
        return; // If neither store is loaded, skip (usually first launch)
    }
    if (![self iCloudEnabledByUser] && _store) {
        NSLog(@"The Non-iCloud Store is loaded as it should be");
        return;
    }
    if ([self iCloudEnabledByUser] && _iCloudStore) {
        NSLog(@"The iCloud Store is loaded as it should be");
        return;
    }
    NSLog(@"** The user preference on using iCloud with this application appears to have changed. Core Data will now be reset. **");
    
    [self resetCoreData];
    [self setupCoreData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];

}

#pragma mark - ICLOUD SEEDING
- (BOOL)loadNoniCloudStoreAsSeedStore {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_seedInProgress) {
        NSLog(@"Seed already in progress ...");
        return NO;
    }
    
    if (![self unloadStore:_seedStore]) {
        NSLog(@"Failed to ensure _seedStore was removed prior to migration.");
        return NO;
    }
    
    if (![self unloadStore:_store]) {
        NSLog(@"Failed to ensure _store was removed prior to migration.");
        return NO;
    }
    
    NSDictionary *options =
    @{
      NSReadOnlyPersistentStoreOption:@YES
      };
    NSError *error = nil;
    _seedStore = [_seedCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                configuration:nil
                                                          URL:[self storeURL]
                                                      options:options error:&error];
    if (!_seedStore) {
        NSLog(@"Failed to load Non-iCloud Store as Seed Store. Error: %@", error);
        return NO;
    }
    NSLog(@"Successfully loaded Non-iCloud Store as Seed Store: %@", _seedStore);
    return YES;
}
- (void)mergeNoniCloudDataWithiCloud {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

	if (![[NSFileManager defaultManager] fileExistsAtPath:[[self storeURL] path]]) {
		if (debug==1) {
			NSLog(@"Skipped unnecessary migration of Non-iCloud store to iCloud (there's no store file).");
		}
		return;
	}
	
	
    [_seedContext performBlock:^{
        
        if ([self loadNoniCloudStoreAsSeedStore]) {
            
            NSLog(@"*** STARTED DEEP COPY FROM NON-ICLOUD STORE TO ICLOUD STORE ***");
			
			JourneyImporter *journeyImporter = [[JourneyImporter alloc] init];
			[journeyImporter deepCopyJourneysFromContext:_seedContext toContext:_parentContext];
			[self backgroundSaveContext];

            NSLog(@"*** FINISHED DEEP COPY FROM NON-ICLOUD STORE TO ICLOUD STORE ***");
            NSLog(@"*** REMOVING OLD NON-ICLOUD STORE ***");
            
            if ([self unloadStore:_seedStore]) {
                
                [_context performBlock:^{
                    // Tell the interface to refresh once import completes
                    [self somethingChanged];
                    
                    // Remove migrated store
                    NSString *wal = [storeFilename stringByAppendingString:@"-wal"];
                    NSString *shm = [storeFilename stringByAppendingString:@"-shm"];
                    
                    [self removeFileAtURL:[self storeURL]];
                    [self removeFileAtURL:[[self applicationStoresDirectory] URLByAppendingPathComponent:wal]];
                    [self removeFileAtURL:[[self applicationStoresDirectory] URLByAppendingPathComponent:shm]];
                }];
            }
        }

    }];
}

#pragma mark - ICLOUD RESET
- (void)destroyAlliCloudDataForThisApplication {
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[_iCloudStore URL] path]]) {
        if (debug==1) NSLog(@"Skipped destroying iCloud content, _iCloudStore.URL is %@", [[_iCloudStore URL] path]);
        return;
    }
	
    NSLog(@"\n\n\n\n\n **** Destroying ALL iCloud content for this application, this could take a while...  **** \n\n\n\n\n\n");
    
    [self removeAllStoresFromCoordinator:_coordinator];
    [self removeAllStoresFromCoordinator:_seedCoordinator];
    _coordinator = nil;
    _seedCoordinator = nil;
    
    NSDictionary *options =
    @{
      NSPersistentStoreUbiquitousContentNameKey: ubiquityStoreName
      //,NSPersistentStoreUbiquitousContentURLKey:@"ChangeLogs" // Optional since iOS7
      };
    NSError *error;
    if ([NSPersistentStoreCoordinator
         removeUbiquitousContentAndPersistentStoreAtURL:[_iCloudStore URL]
         options:options
         error:&error]) {
         NSLog(@"\n\n\n\n\n");
         NSLog(@"*        This application's iCloud content has been destroyed        *");
         NSLog(@"* On ALL devices, please delete any reference to this application in *");
         NSLog(@"*  Settings > iCloud > Storage & Backup > Manage Storage > Show All  *");
         NSLog(@"\n\n\n\n\n");
         abort();
         /*
          The application is force closed to ensure iCloud data is wiped cleanly.
          This method shouldn't be called in a production application.
         */
    } else {
        NSLog(@"\n\n FAILED to destroy iCloud content at URL: %@ Error:%@", [_iCloudStore URL],error);
    }
}
@end
