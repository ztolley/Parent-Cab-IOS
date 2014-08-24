#import "TripViewController.h"
#import "TripRecordViewController.h"
#import "Settings.h"
#import "Model.h"

@interface TripViewController ()
{
	CLLocationManager *locationManager;
	NSNumberFormatter *currencyNumberFormatter;
	Settings *settings;
}
@end

@implementation TripViewController

- (instancetype)initWithSettings:(Settings *)initSettings
{
	self = [super init];
	if (self) {
		settings = initSettings;
	}
	return self;
}
- (void)setupFormatter {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setLocale:settings.locale];
	[numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
	currencyNumberFormatter = numberFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setupFormatter];
	
	if (settings == nil) {
		settings = [Settings defaultSettings];
	}
	
	// Hide all the buttons until we know we have access to the users location
	[self showNoButtons];
	
	// Create a location manager just to find when we get a location.
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	self.map.delegate = self;
	
	//[locationManager requestWhenInUseAuthorization];
	self.map.showsUserLocation = YES;
	[self showStart];
	
	
	self.tripRecorder = [[TripRecorderService alloc] init];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	[[self tripRecorder] reset];
	[self setTripRecorder:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (self.tripRecorder.currentJourney != nil) {
		[self tripRecorder:self.tripRecorder updatedDistance:self.tripRecorder.currentJourney.distance];
		[self tripRecorder:self.tripRecorder updatedFare:self.tripRecorder.currentJourney.fare];
	} else {
		[self tripRecorder:nil updatedDistance:0.00];
		[self tripRecorder:nil updatedFare:0.00];
	}
}
#pragma mark - Mapview
- (void)mapView:(MKMapView *)mv didUpdateUserLocation:(MKUserLocation *)userLocation {
	@try {
		if (userLocation.location != nil) {
			CLLocationCoordinate2D loc = [userLocation coordinate];
			MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 250, 250);
			[mv setRegion:region animated:YES];
		}
	}
	@catch (NSException *exception) {
		NSLog(@"------------------- Parent CAB ERROR ----------------");
		NSLog(@"%@",exception);
		NSLog(@"%c, %@", userLocation.updating, userLocation.location);
		NSLog(@"------------------------------------------------------");
	}
}

#pragma mark - Trip Recorder Delegate
- (void)setTripRecorder:(TripRecorderService *)tripRecorder {
	_tripRecorder = tripRecorder;
	_tripRecorder.delegate = self;
}
- (void)tripRecorder: (TripRecorderService *)tripRecorder updatedDistance: (double)distance {
	NSString *unit = [settings getDistanceUnit];
	
	NSString *distanceString;
	
	if ([unit isEqualToString:SETTINGSMILES]) {
		distanceString = [NSString stringWithFormat:@"%.2lf miles", (distance * 0.000621371192)];
	} else {
		distanceString= [NSString stringWithFormat:@"%.2lf km", (distance/1000)];
	}
	
	[[self distanceLabel] setText: distanceString];
}
- (void)tripRecorder:(TripRecorderService *)tripRecorder updatedFare:(double)fare {
	
	NSString *numberAsString = [currencyNumberFormatter stringFromNumber:[NSNumber numberWithDouble:fare]];
	
	[[self fareLabel] setText:numberAsString];
}



#pragma mark - Button Actions
- (IBAction)reset:(id)sender {
	[self.tripRecorder reset];
	[self showStart];
}
- (IBAction)start:(id)sender {
	[self.tripRecorder startRecording];
	[self showSlider];
}
- (IBAction)resume:(id)sender {
	[self showSlider];
	[self.tripRecorder resume];
}
- (IBAction)sliderTouchUpInside:(id)sender {
	
	float value = self.slider.value;
	if (value > 95.0 ) {
		[self showActions];
		[self.tripRecorder pause];
	} else {
		[self.slider setValue:0 animated:YES];
	}
	
	
}


#pragma mark - Show Buttons
- (void)showStart {
	[self.slider setHidden:YES];
	
	[self.startButton setHidden:NO];
	[self.resetButton setHidden:YES];
	[self.resumeButton setHidden:YES];
	[self.billButton setHidden:YES];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)showSlider {
	[self.slider setHidden:NO];
	[self.slider setValue:0 animated:NO];
	
	[self.startButton setHidden:YES];
	[self.resetButton setHidden:YES];
	[self.resumeButton setHidden:YES];
	[self.billButton setHidden:YES];
	
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)showActions {
	[self.slider setHidden:YES];

	[self.startButton setHidden:YES];
	[self.resetButton setHidden:NO];
	[self.resumeButton setHidden:NO];
	[self.billButton setHidden:NO];
	
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)showNoButtons {
	[self.slider setHidden:YES];
	
	[self.startButton setHidden:YES];
	[self.resetButton setHidden:YES];
	[self.resumeButton setHidden:YES];
	[self.billButton setHidden:YES];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Location
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	//if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
	//	self.map.showsUserLocation = YES;
	//	[self showStart];
	//}
}

#pragma mark - Done
- (IBAction)done:(id)sender {

	UIAlertView *alert = [[UIAlertView alloc]
			initWithTitle: @"Journey End"
				  message: @"Are you sure the journey is finished?"
				 delegate: self
		cancelButtonTitle:@"No"
		otherButtonTitles:@"Yes",nil];
	[alert show];

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

	//show a waiting spinner
	NSLog(@"Clicked on alert view button %ld", (long)buttonIndex);


	if (buttonIndex == 1) {

		[self.tripRecorder finish:^(Journey *journey) {
			[self performSegueWithIdentifier:@"TRIPREVIEW" sender:journey];
			[self showStart];
			[self tripRecorder:nil updatedDistance:0.00];
			[self tripRecorder:nil updatedFare:0.00];
		}];
	} else {
		[self.tripRecorder reset];
	}

}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	Journey *journey = (Journey *)sender;
	
	if ([[segue identifier] isEqualToString:@"TRIPREVIEW"])
	{
		TripRecordViewController *upcomingViewController = [segue destinationViewController];
		upcomingViewController.journey = journey;
	}

}

@end
