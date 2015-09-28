//
//  DetailVC.m
//  LookingForATM
//
//  Created by Le Kim Tuan on 9/27/15.
//  Copyright © 2015 Le Kim Tuan. All rights reserved.
//

#import "DetailVC.h"
#import "AppDelegate.h"
#import "FXAnnotation.h"
#import <MapKit/MapKit.h>

@interface DetailVC ()<MKMapViewDelegate> {
    MKRoute *_currentRoute;
    MKPolyline *_routeOverlay;
    AppDelegate *_myAppdelegate;
}
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@end

@implementation DetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _myAppdelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    [self showDetailPlace];
    [self addPinToMap];
    [self directionOnmap];
}

- (IBAction)backHomeVC:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goToFavorites:(id)sender {
    NSLog(@"Go to Favorites");
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)showDetailPlace {
    _nameLabel.text = [NSString stringWithFormat:@"%@", _name];
    _addressLabel.text = [NSString stringWithFormat:@"Address : %@", _address];
    CLLocation *itemLocation = [[CLLocation alloc]initWithLatitude:_latitude longitude:_longitude];
    _distanceLabel.text = [NSString stringWithFormat:@"Distance : %0.2f km", [_myAppdelegate.currentLocation distanceFromLocation:itemLocation]/1000];
}

-(void)addPinToMap {
    FXAnnotation *pin = [FXAnnotation new];
    pin.title = _name;
    pin.subtitle = _address;
    pin.coordinate = CLLocationCoordinate2DMake(_latitude, _longitude);
    [_mapView addAnnotation:pin];
}

-(void)drawRouteOnMap:(MKRoute*)route {
    if (_routeOverlay) {
        [_mapView removeOverlay:_routeOverlay];
    }
    _routeOverlay = route.polyline;
    [_mapView addOverlay:_routeOverlay];
}

-(void)directionOnmap {
    CLLocation *currentLocation = _myAppdelegate.currentLocation;
    CLLocationCoordinate2D currentCoord = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    MKPlacemark *currentPlacemark = [[MKPlacemark alloc]initWithCoordinate:currentCoord addressDictionary:nil];
    MKMapItem *current = [[MKMapItem alloc]initWithPlacemark:currentPlacemark];
    
    CLLocationCoordinate2D itemCoord = CLLocationCoordinate2DMake(_latitude, _longitude);
    MKPlacemark *itemPlacemark = [[MKPlacemark alloc]initWithCoordinate:itemCoord addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc]initWithPlacemark:itemPlacemark];
    
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    [request setSource:current];
    [request setDestination:item];
    
    MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"ERROR!");
        }
        _currentRoute = [response.routes firstObject];
        [self drawRouteOnMap:_currentRoute];
    }];
}


#pragma mark - MapView Delegate
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    CLLocation *location = [[CLLocation alloc]initWithLatitude:_latitude longitude:_longitude];
    MKCoordinateRegion region;
    region.center.latitude  = location.coordinate.latitude;
    region.center.longitude = location.coordinate.longitude;
    MKCoordinateSpan          span;
    span.latitudeDelta      = 0.02;
    span.longitudeDelta     = 0.02;
    region.span             = span;
    [_mapView setRegion:region animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc]init];
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    // set reuseable
    static NSString *defaultPinID = @"mypin";
    annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
    if (!annotationView){
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
    }
        
    annotationView.canShowCallout = YES;
    annotationView.draggable = YES;
    annotationView.image = [UIImage imageNamed:@"Marker.png"];
    
    return annotationView;
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *render = [[MKPolylineRenderer alloc]initWithOverlay:overlay];
    render.strokeColor = [UIColor blueColor];
    render.lineWidth = 4;
    return render;
}

@end
