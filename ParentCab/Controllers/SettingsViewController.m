#import "SettingsViewController.h"
#import "FareService.h"


@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// See if there is a default already
	float defaultRate = [defaults floatForKey:RATEKEY];
	
	[self.rateField setText:[NSString stringWithFormat:@"%.02f",defaultRate]];
	[self.rateField becomeFirstResponder];
}



- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender {
	// set the preference for the rate after checking it then pop
	float rate = [self.rateField.text floatValue];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat:rate forKey:RATEKEY];
	[self.navigationController popViewControllerAnimated:YES];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// get the reference to the text field
	[self.rateField setUserInteractionEnabled:YES];

}

@end
