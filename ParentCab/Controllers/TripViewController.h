#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@class TripRecorderService;

@interface TripViewController : UIViewController


@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UILabel *fareLabel;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *resumeButton;
@property (weak, nonatomic) IBOutlet UIButton *billButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIView *toolbarView;

@property (weak, nonatomic) IBOutlet UISlider *slider;


- (IBAction)reset:(id)sender;
- (IBAction)start:(id)sender;
- (IBAction)sliderTouchUpInside:(id)sender;
- (IBAction)resume:(id)sender;
- (IBAction)done:(id)sender;

@property (strong, nonatomic) TripRecorderService *tripRecorder;

@end