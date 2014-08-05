//
//  SettingsViewController.m
//  ParentCab
//
//  Created by Zac Tolley on 31/07/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import "SettingsViewController.h"
#import "TripRecorderService.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.rateField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// See if there is a default already
	float defaultRate = [defaults floatForKey:RATEKEY];
	
	[self.rateField setText:[NSString stringWithFormat:@"%f4",defaultRate]];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	float rate = [self.rateField.text floatValue];
	
	if (rate > 0 && rate < 10) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setFloat:rate forKey:RATEKEY];
	}
}

@end
