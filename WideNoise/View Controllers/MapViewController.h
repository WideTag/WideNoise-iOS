//
//  MapViewController.h
//  WideNoise
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIView *overlayView;
@property (nonatomic, retain) IBOutlet UIImageView *overlayImageView;
@property (nonatomic, retain) IBOutlet UILabel *overlayLabel;
@property (nonatomic, retain) IBOutlet UIView *topColorView;
@property (nonatomic, retain) IBOutlet UIView *bottomColorView;

@end
