#import "JourneyRepository.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "CoreDataHelper.h"
@interface JourneyRepository()

@property (strong, nonatomic)NSManagedObjectContext *moc;
@end

@implementation JourneyRepository

+ (JourneyRepository *)sharedRepository {
	static JourneyRepository *repository = nil;

	if (!repository) {
		repository = [[JourneyRepository alloc] init];
	}

	return repository;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
		AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		self.moc = appDelegate.coreDataHelper.context;
	}
    return self;
}




- (NSArray *)journeys {
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Journey"];
	return [self.moc executeFetchRequest:request error:nil];
}
- (NSUInteger)journeyCount {
	NSArray *result = [self journeys];
	return result.count;
}
- (void)deleteJourney:(Journey *)journey {
	[self.moc delete:journey];
}



- (Journey *)getNewJourney {
	Journey *journey = [NSEntityDescription insertNewObjectForEntityForName:@"Journey" inManagedObjectContext:self.moc];
	return journey;
}
- (Step *)getNewStep {
	Step *step = [NSEntityDescription insertNewObjectForEntityForName:@"Step" inManagedObjectContext:self.moc];
	return step;
}
- (Location *)getNewLocation {
	Location *location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.moc];
	return location;
}






@end
