#import "TripListViewController.h"
#import "TripRecordViewController.h"
#import "JourneyListCell.h"
#import "Model.h"
#import "AppDelegate.h"
#import "PCabCoreDataHelper.h"

@implementation TripListViewController
#define debug 0

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

	Journey *journey = [self.frc objectAtIndexPath:indexPath];
	
	[cell setJourney:journey];
	
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 84.00;
}



#pragma mark - Seque stuff
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowJourney"])
    {
		NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
		Journey *journey = [self.frc objectAtIndexPath:selectedIndexPath];
		
        TripRecordViewController *upcomingViewController = [segue destinationViewController];
		upcomingViewController.journey = journey;
    }
}

#pragma mark - allow editing
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		Journey *journey = [self.frc objectAtIndexPath:indexPath];
		[self.frc.managedObjectContext deleteObject:journey];
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}



@end
