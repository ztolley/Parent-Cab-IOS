//
//  TripListViewController.h
//  Parentcab_iOS
//
//  Created by Zac Tolley on 08/11/2012.
//  Copyright (c) 2012 Exsite Consultants. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTVC.h"

@interface TripListViewController : CoreDataTVC
<UIActionSheetDelegate>

@property (strong, nonatomic) UIActionSheet *clearConfirmActionSheet;


@end
