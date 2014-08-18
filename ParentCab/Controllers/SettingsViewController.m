#import "SettingsViewController.h"
#import "FareService.h"
#import "Settings.h"

@interface SettingsViewController ()
{
	Settings *settings;
}
@end

@implementation SettingsViewController

- (instancetype)init {
	
    self = [super init];
    if (self) {
		settings = [[Settings alloc] init];
    }
	
	return self;

}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.rateField setText:[NSString stringWithFormat:@"%.02f",[settings getRate]]];
	[self.rateField becomeFirstResponder];
}



- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender {
	// set the preference for the rate after checking it then pop
	float rate = [self.rateField.text floatValue];
	[settings setRate:rate];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// get the reference to the text field
	[self.rateField setUserInteractionEnabled:YES];
}

@end
