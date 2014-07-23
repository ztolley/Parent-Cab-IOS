#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Journey;
@class Step;
@class Location;

@interface JourneyRepository : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (JourneyRepository *)sharedRepository;
- (NSArray *)journeys;
- (NSUInteger)journeyCount;
- (void)deleteJourney:(Journey *)journey;

- (Journey *)getNewJourney;
- (Step *)getNewStep;
- (Location *)getNewLocation;

@end
