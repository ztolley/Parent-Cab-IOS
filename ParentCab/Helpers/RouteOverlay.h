//
//  RouteOverlay.h
//  Parentcab_iOS
//
//  Created by Zac Tolley on 14/11/2012.
//  Copyright (c) 2012 Exsite Consultants. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class RouteOverlay;

@protocol RouteOverlayDataSource <NSObject>
@required
- (NSUInteger)numberOfCoordinatesInRouteOverlay:(RouteOverlay *)overlay;
- (CLLocationCoordinate2D)locationForRouteOverlay:(RouteOverlay *)overlay AtIndex:(NSUInteger)index;
@end

@interface RouteOverlay : NSObject
<MKMapViewDelegate>

- (id)initWithMap:(MKMapView *)mapView;

@property (weak, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) MKPolyline *routeLine;
@property (strong, nonatomic) MKPolylineView *routeLineView;
@property (weak, nonatomic) id<RouteOverlayDataSource> delegate;


@end


