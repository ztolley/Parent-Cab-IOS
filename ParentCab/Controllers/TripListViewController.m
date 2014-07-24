#import "TripListViewController.h"
#import "TripRecordViewController.h"
#import "JourneyListCell.h"
#import "Model.h"
#import "AppDelegate.h"
#import "PCabCoreDataHelper.h"

@implementation TripListViewController
#define debug 1

#pragma mark - Data
- (void)configureFetch {
	
	if (debug == 1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	
	PCabCoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Journey"];
	
	request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:NO]];
	[request setFetchBatchSize:50];

	
	self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
												   managedObjectContext:cdh.context
													 sectionNameKeyPath:nil
															  cacheName:nil];
	self.frc .delegate = self;
	

}


#pragma mark - View
- (void)viewDidLoad {
	
	if (debug == 1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	
	[super viewDidLoad];
	[self configureFetch];
	[self performFetch];
	
	self.clearConfirmActionSheet.delegate = self;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(performFetch)
												 name:@"SomethingChanged"
											   object:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (debug == 1) {
		NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	}
	
	static NSString *cellIdentifier = @"JourneyCell";
	JourneyListCell *cell = (JourneyListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

	cell.journey = [self.frc objectAtIndexPath:indexPath];

	return cell;
}




#pragma mark - Seque stuff
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowJourney"])
    {
		JourneyListCell *cell = (JourneyListCell *)sender;
        TripRecordViewController *upcomingViewController = [segue destinationViewController];
		upcomingViewController.journey = cell.journey;
    }
}



@end
