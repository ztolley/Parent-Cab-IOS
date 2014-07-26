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
	[super awakeFromNib];
	overlay = [[RouteOverlay alloc] initWithMap:self.mapView];
}

- (void)setJourney:(Journey *)journey
{

	[overlay setDelegate:[[JourneyRouteDataSource alloc] initWithJourney:journey]];
	self.startEnd.text = [NSString stringWithFormat:@"%@ - %@",
						  journey.startLocation.postcode,
						  journey.endLocation.postcode];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
	NSString *numberAsString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:journey.fare]];
	self.fare.text = numberAsString;
}
@end
