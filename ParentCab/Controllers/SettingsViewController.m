#import "SettingsViewController.h"
#import "FareService.h"
#import "Settings.h"


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

// Edit the rate
- (IBAction)selectRate:(id)sender {
	[self.rateField setUserInteractionEnabled:YES];
}

- (IBAction)rateChanged:(id)sender {
	float rate = [self.rateField.text floatValue];
	[settings setRate:rate];
}


@end
