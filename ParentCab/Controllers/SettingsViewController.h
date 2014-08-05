//
//  SettingsViewController.h
//  ParentCab
//
//  Created by Zac Tolley on 31/07/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *rateField;

@end
