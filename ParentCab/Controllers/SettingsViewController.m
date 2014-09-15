#import "SettingsViewController.h"
#import "FareService.h"
#import "Settings.h"
#import "DistanceUnitTableViewController.h"

@interface SettingsViewController ()
{
	Settings *settings;
}
@end

@implementation SettingsViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	settings = [Settings defaultSettings];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.rateField setText:[NSString stringWithFormat:@"%.02f",[settings getRate]]];
	[self.unitField setText:[settings getDistanceUnit]];
}

#pragma mark - handle rates
- (IBAction)selectRate:(id)sender {
	[self.rateField setUserInteractionEnabled:YES];
}

- (IBAction)rateChanged:(id)sender {
	float rate = [self.rateField.text floatValue];
	[settings setRate:rate];
}

#pragma mark - section titles
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setLocale:settings.locale];
	
	NSString *unit = [settings getDistanceUnit];
	if ([unit isEqualToString:@"miles"]) {
		unit = @"mile";
	}

	NSString *sectionName;
	switch (section)
	{
		case 0:
			sectionName = [NSString stringWithFormat:@"%@ per %@", numberFormatter.currencySymbol, unit];
			break;
		default:
			sectionName = @"";
			break;
	}

	return sectionName;
}

#pragma mark - segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if([segue.identifier isEqualToString:@"distanceunit"])
	{
		DistanceUnitTableViewController *distanceUnitController = segue.destinationViewController;
		distanceUnitController.settingsViewController = self;
	}
}

@end
