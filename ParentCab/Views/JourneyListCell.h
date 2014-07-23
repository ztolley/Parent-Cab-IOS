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

@interface JourneyListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *fare;
@property (weak, nonatomic) IBOutlet UILabel *startStreet;
@property (weak, nonatomic) IBOutlet UILabel *startPostCode;
@property (weak, nonatomic) IBOutlet UILabel *endStreet;
@property (weak, nonatomic) IBOutlet UILabel *endPostCode;
@property (strong, nonatomic) Journey *journey;





@end
