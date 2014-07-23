#import "TripListViewController.h"
#import "TripRecordViewController.h"
#import "JourneyListCell.h"
#import "Model.h"
#import "JourneyRepository.h"

@implementation TripListViewController {
	JourneyRepository *journeyRepository;
}


- (void)viewDidLoad {
	[super viewDidLoad];
	journeyRepository = [JourneyRepository sharedRepository];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [journeyRepository.journeys count];
}


#pragma mark - Table View Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    JourneyListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(JourneyListCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	Journey *journey = journeyRepository.journeys[indexPath.row];
	[cell setJourney:journey];
    return;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	Journey *journey = journeyRepository.journeys[indexPath.row];
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[journeyRepository deleteJourney:journey];
		[self.tableView reloadData];
	}
}


#pragma mark - Seque stuff
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"VIEWJOURNEY"])
    {
		JourneyListCell *cell = (JourneyListCell *)sender;
        TripRecordViewController *upcomingViewController = [segue destinationViewController];
		upcomingViewController.journey = cell.journey;
    }
}



@end
