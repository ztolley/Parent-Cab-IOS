//
//  JourneyListCell.m
//  Parentcab_iOS
//
//  Created by Zac Tolley on 08/12/2012.
//  Copyright (c) 2012 Exsite Consultants. All rights reserved.
//

#import "JourneyListCell.h"
#import "RouteOverlay.h"
#import "JourneyRouteDataSource.h"
#import "Model.h"

@interface JourneyListCell ()
{
	RouteOverlay *overlay;
}
@end

@implementation JourneyListCell

- (void)awakeFromNib {
	overlay = [[RouteOverlay alloc] initWithMap:self.mapView];
}

- (void)setJourney:(Journey *)journey
{
	_journey = journey;
	[overlay setDelegate:[[JourneyRouteDataSource alloc] initWithJourney:self.journey]];
	self.startStreet.text = journey.startLocation.thoroughfare;
	self.startPostCode.text = journey.startLocation.postcode;
	self.endStreet.text = journey.endLocation.thoroughfare;
	self.endPostCode.text = journey.endLocation.postcode;
	self.fare.text = [NSString stringWithFormat:@"£%.02f", journey.fare];
}
@end
