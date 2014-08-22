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
#import "Settings.h"

@interface JourneyListCell ()
{
	RouteOverlay *overlay;
	NSNumberFormatter *currencyNumberFormatter;
}
@end

@implementation JourneyListCell

- (instancetype)init {
	return [self initWithSettings:[Settings defaultSettings]];
}
- (instancetype)initWithSettings:(Settings *)initSettings
{
	self = [super init];
	if (self) {
		[self setupFormatter:initSettings];
	}
	return self;
}

- (void)setupFormatter:(Settings *)settings {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setLocale:settings.locale];
	[numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
	currencyNumberFormatter = numberFormatter;
}

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
	
	NSString *numberAsString = [currencyNumberFormatter stringFromNumber:[NSNumber numberWithDouble:journey.fare]];
	self.fare.text = numberAsString;
}
@end
