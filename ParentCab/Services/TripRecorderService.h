//
//  TripRecorderService.h
//  Parentcab_iOS
//
//  Created by Zac Tolley on 10/10/2012.
//  Copyright (c) 2012 Exsite Consultants. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@class Journey;
@class TripRecorderService;
@class PCabCoreDataHelper;
@class FareService;

typedef void (^ JourneyBlock)(Journey *journey);

@protocol TripRecorderServiceDelegate <NSObject>
@required
- (void)tripRecorder:(TripRecorderService *)tripRecorder updatedDistance:(double)distance;
- (void)tripRecorder:(TripRecorderService *)tripRecorder updatedFare:(double)fare;
@end


@interface TripRecorderService : NSObject
<CLLocationManagerDelegate>

// Properties
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) Journey *currentJourney;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (weak, nonatomic) id<TripRecorderServiceDelegate> delegate;
@property (strong, nonatomic) PCabCoreDataHelper *cdh;
@property (strong, nonatomic) FareService *fareService;


// Actions
- (void)startRecording;
- (void)pause;
- (void)resume;
- (void)finish: (JourneyBlock)journeyBlock;
- (void)reset;

@end
