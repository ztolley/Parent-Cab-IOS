//
//  TripRecordViewController.h
//  Parentcab_iOS
//
//  Created by Zac Tolley on 10/11/2012.
//  Copyright (c) 2012 Exsite Consultants. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class Journey;
@class Settings;

@interface TripRecordViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *fairLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *startStreetLabel;
@property (weak, nonatomic) IBOutlet UILabel *startPostCodeLabel;

@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endStreetLabel;
@property (weak, nonatomic) IBOutlet UILabel *endPostCodeLabel;

- (instancetype)initWithSettings:(Settings *)initSettings;

- (IBAction)shareJourney:(id)sender;
- (NSString *)generateEmailBodyForJourney:(Journey *)journey;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) Journey *journey;


@end
