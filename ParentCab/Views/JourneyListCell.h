//
//  JourneyListCell.h
//  Parentcab_iOS
//
//  Created by Zac Tolley on 08/12/2012.
//  Copyright (c) 2012 Exsite Consultants. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class Journey;
@class Settings;

@interface JourneyListCell : UITableViewCell

- (instancetype)initWithSettings:(Settings *)settings;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *fare;
@property (weak, nonatomic) IBOutlet UILabel *startEnd;


- (void)setJourney:(Journey *)journey;



@end
