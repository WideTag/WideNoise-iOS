//
//  MapViewController.m
//  WideNoise
//
//  Created by Emilio Pavia on 24/08/11.
//  Copyright 2011 WideTag, Inc. All rights reserved.
//

#import "MapViewController.h"
#import "WTNoise.h"

#import <QuartzCore/QuartzCore.h>

@interface MapViewController ()

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableSet *annotations;

@end

@implementation MapViewController

@synthesize mapView = _mapView;
@synthesize overlayView;
@synthesize overlayImageView;
@synthesize overlayLabel;
@synthesize topColorView;
@synthesize bottomColorView;

@synthesize locationManager = _locationManager;
@synthesize annotations = _annotations;

#pragma mark - Private methods


#pragma mark - CoreLocation delegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1000, 1000*self.mapView.frame.size.width/self.mapView.frame.size.height) animated:YES];
    
    if (newLocation.horizontalAccuracy >= 0 && newLocation.horizontalAccuracy < 1000) {
        [manager stopUpdatingLocation];
    }    
}

#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [self.locationManager stopUpdatingLocation];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    __block float averageLevel = 0.0;
    
    NSMutableSet *removedAnnotations = [[NSMutableSet alloc] init];
    for (WTNoise *noise in self.annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(noise.location.coordinate);
        if (!MKMapRectContainsPoint(mapView.visibleMapRect, annotationPoint)) {
            [removedAnnotations addObject:noise];
            [mapView removeAnnotation:noise];
        } else {
            averageLevel += noise.averageLevel;
        }
    }
    [self.annotations minusSet:removedAnnotations];
    [removedAnnotations release];
    
    [WTNoise processReportedNoisesInMapRect:mapView.visibleMapRect withBlock:^(NSArray *noises) {
        for (WTNoise *noise in noises) {
            if (![self.annotations containsObject:noise]) {
                [self.annotations addObject:noise];
                [mapView addAnnotation:noise];
                
                averageLevel += noise.averageLevel;
            }
        }
        
        averageLevel /= (float)[self.annotations count];    
        
        NSString *imageName = nil;
        NSString *description = nil;
        float color = 0;
        if (averageLevel <= 30) {
            imageName = @"icon_1.png";
            description = @"Feather";
            color = 30;
        } else if (averageLevel <= 60) {
            imageName = @"icon_2.png";
            description = @"Sleeping Cat";
            color = 60;
        } else if (averageLevel <= 70) {
            imageName = @"icon_3.png";
            description = @"TV";
            color = 70;
        } else if (averageLevel <= 90) {
            imageName = @"icon_4.png";
            description = @"Car";
            color = 90;
        } else if (averageLevel <= 100) {
            imageName = @"icon_5.png";
            description = @"Dragster";
            color = 90;
        } else if (averageLevel <= 115) {
            imageName = @"icon_6.png";
            description = @"T-rex";
            color = 115;
        } else {
            imageName = @"icon_7.png";
            description = @"Rock Concert";
            color = 120;
        }
        
        self.topColorView.backgroundColor = self.bottomColorView.backgroundColor = [UIColor colorWithHue:(120.0-color)/360.0 saturation:1.0 brightness:1.0 alpha:1.0];
        
        self.overlayImageView.image = [UIImage imageNamed:imageName];
        self.overlayLabel.text = [NSString stringWithFormat:@"%@ area", description];
    }];   
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *annotationView = nil;
    static NSString *annotationViewIdentifier = @"AnnotationIdentifier";
    
    annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewIdentifier];
    if (annotationView == nil) {
        annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewIdentifier] autorelease];
        annotationView.canShowCallout = YES;
        ((MKPinAnnotationView *)annotationView).animatesDrop = YES;
        
    }
    
    UIImageView *icon = [[[UIImageView alloc] initWithImage:((WTNoise *)annotation).icon] autorelease];
    icon.contentMode = UIViewContentModeCenter;
    annotationView.leftCalloutAccessoryView = icon;
    
    return annotationView;
}

#pragma mark -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [_mapView release];
    [overlayView release];
    [overlayImageView release];
    [overlayLabel release];
    [topColorView release];
    [bottomColorView release];
    [_locationManager release];
    [_annotations release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [self.locationManager startUpdatingLocation];
    
    self.topColorView.layer.masksToBounds = NO;
    self.topColorView.layer.shadowOpacity = 0.85;
    self.topColorView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.topColorView.bounds].CGPath;
    self.topColorView.layer.shadowRadius = 2;
    self.topColorView.layer.shadowOffset = CGSizeMake(0, 0);
    
    self.bottomColorView.layer.masksToBounds = NO;
    self.bottomColorView.layer.shadowOpacity = 0.85;
    self.bottomColorView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.topColorView.bounds].CGPath;
    self.bottomColorView.layer.shadowRadius = 2;
    self.bottomColorView.layer.shadowOffset = CGSizeMake(0, 0);
    
    self.annotations = [NSMutableSet set];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.mapView = nil;
    self.overlayView = nil;
    self.overlayImageView = nil;
    self.overlayLabel = nil;
    self.topColorView = nil;
    self.bottomColorView = nil;
    self.locationManager = nil;
    self.annotations = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.locationManager stopUpdatingLocation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
