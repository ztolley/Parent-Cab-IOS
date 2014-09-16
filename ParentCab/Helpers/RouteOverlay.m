//
//  RouteOverlay.m
//  Parentcab_iOS
//
//  Created by Zac Tolley on 14/11/2012.
//  Copyright (c) 2012 Exsite Consultants. All rights reserved.
//

#import "RouteOverlay.h"

@implementation RouteOverlay
{
	MKMapRect _routeRect;
}

- (id)initWithMap:(MKMapView *)mapView {
	self = [super init];
	if (self) {
		_mapView = mapView;
		_mapView.delegate = self;
	}
	return self;
}


#pragma mark - getter and setter overrides
- (void)setMapView:(MKMapView *)mapView {
	_mapView = mapView;
	[self regen];
}

- (void)setDelegate:(id<RouteOverlayDataSource>)delegate
{
	_delegate = delegate;
	[self regen];
}

- (void)regen {
	if (_mapView != nil && _delegate != nil) {
		
		if (self.routeLine != nil) {
			[_mapView removeOverlay:self.routeLine];
		}
		
		// create the overlay
		[self setupPolyline];
		
		// add the overlay to the map
		if (nil != self.routeLine) {
			[_mapView addOverlay:self.routeLine];
		}
		
		// zoom in on the route.
		[self zoomInOnRoute];
	
	}
}




#pragma mark - Map Overlay Stuff
- (void)setupPolyline
{
	// while we create the route points, we will also be calculating the bounding box of our route
	// so we can easily zoom in on it.
	MKMapPoint northEastPoint;
	MKMapPoint southWestPoint;
	
	northEastPoint.y = 0;
	northEastPoint.x = 0;
	southWestPoint.y = 0;
	southWestPoint.x = 0;

	// Find out how many map points we are going to plot.
	NSUInteger pointCount = [self.delegate numberOfCoordinatesInRouteOverlay:self];
	int sizeThing = sizeof(CLLocationCoordinate2D);
	MKMapPoint* pointArr = malloc(sizeThing * pointCount);
	
	for(int iPos = 0; iPos < pointCount; iPos++)
	{
		CLLocationCoordinate2D coordinate = [self.delegate locationForRouteOverlay:self AtIndex:iPos];
		MKMapPoint point = MKMapPointForCoordinate(coordinate);
		
		
		//
		// adjust the bounding box
		//
		
		// if it is the first point, just use them, since we have nothing to compare to yet.
		if (iPos == 0) {
			northEastPoint = point;
			southWestPoint = point;
		}
		else
		{
			if (point.x > northEastPoint.x)
				northEastPoint.x = point.x;
			if(point.y > northEastPoint.y)
				northEastPoint.y = point.y;
			if (point.x < southWestPoint.x)
				southWestPoint.x = point.x;
			if (point.y < southWestPoint.y)
				southWestPoint.y = point.y;
		}
		
		pointArr[iPos] = point;
		
	}
	
	// create the polyline based on the array of points.
	self.routeLine = [MKPolyline polylineWithPoints:pointArr count:pointCount];
	
	_routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
	
	// clear the memory allocated earlier for the points
	free(pointArr);
}

-(void) zoomInOnRoute
{
	[self.mapView setVisibleMapRect:_routeRect];
}

#pragma mark MKMapViewDelegate
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
	if ([overlay isKindOfClass:MKPolyline.class]) {
		MKPolylineRenderer *lineView = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
		lineView.strokeColor = [UIColor redColor];
		lineView.fillColor = [UIColor redColor];
		lineView.lineWidth = 5;
		return lineView;
	}
	
	return nil;
}

@end
