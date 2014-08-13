//
//  CoreDataHelper.m
//  Test version using in memory store
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper
#define debug 0


#pragma mark - SETUP
- (id)init {

	self = [super init];
	if (!self) {return nil;}
	
	_model = [NSManagedObjectModel mergedModelFromBundles:nil];
	_coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
	_context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	[_context setPersistentStoreCoordinator:_coordinator];
	
	return self;

}

- (void)setupCoreData {
	if (_store) {
		return;
	}
	

	NSError *error = nil;
	_store = [_coordinator addPersistentStoreWithType:NSInMemoryStoreType
										configuration:nil
												  URL:nil
											  options:nil error:&error];
	
	if (!_store) {
		NSLog(@"Failed to add store. Error: %@", error);abort();
	}
	
}

#pragma mark - SAVING
- (void)saveContext {

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

@end
