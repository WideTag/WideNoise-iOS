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
    float averageLevel = 0.0;
    
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
    
    int missing = 10-[self.annotations count];
    for (int i=0; i<missing; i++) {
        WTNoise *noise = [[[WTNoise alloc] init] autorelease];
        MKMapPoint randomPoint = MKMapPointMake(mapView.visibleMapRect.origin.x + (((double)rand()/(double)RAND_MAX)*mapView.visibleMapRect.size.width), mapView.visibleMapRect.origin.y + (((double)rand()/(double)RAND_MAX)*mapView.visibleMapRect.size.height));
        CLLocationCoordinate2D randomCoordinate = MKCoordinateForMapPoint(randomPoint);
        noise.location = [[[CLLocation alloc] initWithLatitude:randomCoordinate.latitude longitude:randomCoordinate.longitude] autorelease];
        [noise addSample:((double)rand()/(double)RAND_MAX)*120.0];
        noise.measurementDate = [NSDate date];
        [self.annotations addObject:noise];
        [mapView addAnnotation:noise];
        
        averageLevel += noise.averageLevel;
    }
    
    averageLevel /= (float)[self.annotations count];    
    
    NSString *imageName = nil;
    NSString *description = nil;
    float color = 0;
    if (averageLevel <= 30) {
		imageName = @"feather_icon.png";
        description = @"Feather";
        color = 30;
	} else if (averageLevel <= 60) {
		imageName = @"cat_icon.png";
        description = @"Sleeping Cat";
        color = 60;
	} else if (averageLevel <= 70) {
		imageName = @"tv_icon.png";
        description = @"TV";
        color = 70;
	} else if (averageLevel <= 90) {
		imageName = @"car_icon.png";
        description = @"Car";
        color = 90;
	} else if (averageLevel <= 100) {
		imageName = @"dragster_icon.png";
        description = @"Dragster";
        color = 90;
	} else if (averageLevel <= 115) {
		imageName = @"t-rex_icon.png";
        description = @"T-rex";
        color = 115;
	} else {
		imageName = @"concert_icon.png";
        description = @"Rock Concert";
        color = 120;
	}
    
    self.overlayView.backgroundColor = [UIColor colorWithHue:(120.0-color)/360.0 saturation:1.0 brightness:1.0 alpha:0.5];
    self.overlayView.layer.borderColor = [UIColor colorWithHue:(120.0-color)/360.0 saturation:1.0 brightness:1.0 alpha:1.0].CGColor;
    
    self.overlayImageView.image = [UIImage imageNamed:imageName];
    self.overlayLabel.text = [NSString stringWithFormat:@"This is a %@ area...", description];
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
    
    annotationView.leftCalloutAccessoryView = [[[UIImageView alloc] initWithImage:((WTNoise *)annotation).icon] autorelease];
    
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
    
    self.annotations = [NSMutableSet set];
    
    self.overlayView.layer.cornerRadius = 5.0;
    self.overlayView.layer.borderWidth = 3.0;
    /*
    self.overlayView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.overlayView.layer.shadowOffset = CGSizeMake(0, 1);
    self.overlayView.layer.shadowOpacity = 0.6;
    self.overlayView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.overlayView.bounds].CGPath;
    self.overlayView.layer.shadowRadius = 5.0;
     */
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
    self.locationManager = nil;
    self.annotations = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.locationManager startUpdatingLocation];
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
