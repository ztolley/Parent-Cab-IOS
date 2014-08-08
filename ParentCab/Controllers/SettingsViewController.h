//
//  SettingsViewController.h
//  ParentCab
//
//  Created by Zac Tolley on 31/07/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITextField *rateField;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;


@end
