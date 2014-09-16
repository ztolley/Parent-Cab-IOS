//
//  DistanceUnitTableViewController.m
//  ParentCab
//
//  Created by Zac Tolley on 23/08/2014.
//  Copyright (c) 2014 Zac Tolley. All rights reserved.
//

#import "DistanceUnitTableViewController.h"
#import "Settings.h"
#import "SettingsViewController.h"


int const MILESROW = 0;
int const KMROW = 1;
@interface DistanceUnitTableViewController ()

@end

@implementation DistanceUnitTableViewController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	Settings *settings = [Settings defaultSettings];
	NSString *unit = [settings getDistanceUnit];
	
	NSIndexPath *index;
	
	if ([unit isEqualToString:SETTINGSMILES]) {
		index = [NSIndexPath indexPathForRow:MILESROW inSection:0];
	} else {
		index = [NSIndexPath indexPathForRow:KMROW inSection:0];
	}
	
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
	[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Settings *settings = [Settings defaultSettings];
	
	if (indexPath.row == MILESROW) {
		[settings setDistanceUnit:SETTINGSMILES];
		[self markSelected:SETTINGSMILES];
	} else {
		[settings setDistanceUnit:SETTINGSKM];
		[self markSelected:SETTINGSKM];
	}
	
	[self.settingsViewController.tableView reloadData];
}

- (void)markSelected:(NSString *)unit {
	NSIndexPath *index;
	UITableViewCell *cell;
	
	if ([unit isEqualToString:SETTINGSMILES]) {
		index = [NSIndexPath indexPathForRow:MILESROW inSection:0];
		cell = [self.tableView cellForRowAtIndexPath:index];
		[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
		
		index = [NSIndexPath indexPathForRow:KMROW inSection:0];
		cell = [self.tableView cellForRowAtIndexPath:index];
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	} else {
		index = [NSIndexPath indexPathForRow:KMROW inSection:0];
		cell = [self.tableView cellForRowAtIndexPath:index];
		[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
		
		index = [NSIndexPath indexPathForRow:MILESROW inSection:0];
		cell = [self.tableView cellForRowAtIndexPath:index];
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	}
}

@end
