#import "TripViewController.h"
#import "TripRecordViewController.h"
#import "JourneyRepository.h"
#import "TripRecorderService.h"
#import "Model.h"

@interface TripViewController ()
<MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, TripRecorderServiceDelegate>
{
	CLLocationManager *locationManager;
}
@end

@implementation TripViewController


- (void)viewDidLoad {
    [super viewDidLoad];

	// Hide all the buttons until we know we have access to the users location
	[self showNoButtons];
	
	// Create a location manager just to find when we get a location.
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	self.map.delegate = self;
	
	[locationManager requestWhenInUseAuthorization];
	
	self.tripRecorder = [[TripRecorderService alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	[[self tripRecorder] reset];
	[self setTripRecorder:nil];
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

	double miles = distance * 0.000621371192;
	
	// turn it into an Integer for output.
	NSString *myString = [NSString stringWithFormat:@"%.2lf miles", miles];
	[[self distanceLabel] setText: myString];
}
- (void)tripRecorder:(TripRecorderService *)tripRecorder updatedFare:(double)fare {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
	NSString *numberAsString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:fare]];
	
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
	if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
		self.map.showsUserLocation = YES;
		[self showStart];
	}
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
			[self performSegueWithIdentifier:@"TRIPREVIEW" sender:self];
		}];
	} else {
		[self.tripRecorder reset];
	}

}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"TRIPREVIEW"])
	{
		TripRecordViewController *upcomingViewController = [segue destinationViewController];
		upcomingViewController.journey = self.tripRecorder.currentJourney;
		[self reset:nil];
	}

}

@end
