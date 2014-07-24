//
//  CoreDataTVC.h
//  ParentCab
//
//  Created by Zac Tolley on 24/07/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CoreDataTVC : UITableViewController
<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *frc;

- (void)performFetch;

@end
