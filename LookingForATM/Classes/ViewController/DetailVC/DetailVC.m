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
#import "ATMFavorites.h"
#import "FavoritesVC.h"
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
@property (weak, nonatomic) IBOutlet UIButton *addFavoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteFavoriteButton;
@end

@implementation DetailVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _myAppdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    [self showDetailPlace];
    [self addPinToMap];
    [self directionOnmap];
}

//Check in coredata atmcurrent has or not
- (void)viewWillAppear:(BOOL)animated {
    FavoritesVC *favorites = [FavoritesVC new];
    NSArray *tempArray = favorites.fetchFavorite.fetchedObjects;
    BOOL flag = YES;
    NSInteger tempArrayCount = [tempArray count];
    for (int i = 0; i < tempArrayCount; i++) {
        ATMFavorites *dataTemp = tempArray[i];
        
        //Get location of atm current
        CLLocation *locationATMCurrent = [[CLLocation alloc]initWithLatitude:_latitude longitude:_longitude];
        
        //Get location of atm in coredata
        double latitudeATMCoreData = [dataTemp.latitude doubleValue];
        double longitudeATMCoreData = [dataTemp.longitude doubleValue];
        CLLocation *locationATMCoreData = [[CLLocation alloc]initWithLatitude:latitudeATMCoreData longitude:longitudeATMCoreData];
        
        //Compare 2 locatios by calculator distance between 2 locations
        float distance = [locationATMCurrent distanceFromLocation:locationATMCoreData];
        if (distance == 0) {
            flag = NO;
            break;
        }
    }
    if (!flag) {
        [_addFavoriteButton setHidden:YES];
        [_deleteFavoriteButton setHidden:NO];
    } else {
        [_addFavoriteButton setHidden:NO];
        [_deleteFavoriteButton setHidden:YES];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - IBActions

- (IBAction)backButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addToFavorites:(id)sender {
    ATMFavorites *atm = [ATMFavorites MR_createEntity];
    atm.name = _name;
    atm.address = _address;
    atm.latitude = [NSNumber numberWithDouble:_latitude];
    atm.longitude = [NSNumber numberWithDouble:_longitude];
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"NOTICE"
                                                   message:@"Add ATM to Favorites success"
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil, nil];
    [alert show];
    [_addFavoriteButton setHidden:YES];
    [_deleteFavoriteButton setHidden:NO];
}

- (IBAction)deleteFavorites:(id)sender {
    FavoritesVC *favorites = [FavoritesVC new];
    NSArray *tempArray = favorites.fetchFavorite.fetchedObjects;
    NSInteger tempArrayCount = [tempArray count];
    for (int i = 0; i < tempArrayCount; i++) {
        ATMFavorites *dataTemp = tempArray[i];
        double latitudeTemp = [dataTemp.latitude doubleValue];
        double longitudeTemp = [dataTemp.longitude doubleValue];
        CLLocation *locationTemp = [[CLLocation alloc]initWithLatitude:latitudeTemp longitude:longitudeTemp];
        
        CLLocation *locationCurrent = [[CLLocation alloc]initWithLatitude:_latitude longitude:_longitude];
        
        if ([locationCurrent distanceFromLocation:locationTemp] == 0) {
            [dataTemp MR_deleteEntity];
            [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"NOTICE"
                                                           message:@"Remove ATM to Favorites success"
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil, nil];
            [alert show];
            [_addFavoriteButton setHidden:NO];
            [_deleteFavoriteButton setHidden:YES];
            break;
        }
    }
}

#pragma mark - Private

- (void)showDetailPlace {
    CLLocation *location = [[CLLocation alloc]initWithLatitude:_latitude longitude:_longitude];
    [self zoomMapAndCenterAtLocation:location span:0.02];
    
    _nameLabel.text = [NSString stringWithFormat:@"%@", _name];
    _addressLabel.text = [NSString stringWithFormat:@"%@", _address];
    CLLocation *itemLocation = [[CLLocation alloc]initWithLatitude:_latitude longitude:_longitude];
    _distanceLabel.text = [NSString stringWithFormat:@"%0.2f km", [_myAppdelegate.currentLocation distanceFromLocation:itemLocation]/1000];
}

- (void)addPinToMap {
    FXAnnotation *pin = [FXAnnotation new];
    pin.title = _name;
    pin.subtitle = _address;
    pin.coordinate = CLLocationCoordinate2DMake(_latitude, _longitude);
    [_mapView addAnnotation:pin];
}

- (void)drawRouteOnMap:(MKRoute*)route {
    if (_routeOverlay) {
        [_mapView removeOverlay:_routeOverlay];
    }
    _routeOverlay = route.polyline;
    [_mapView addOverlay:_routeOverlay];
}

- (void)directionOnmap {
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

#pragma mark - MAP

- (void)zoomMapAndCenterAtLocation:(CLLocation *)location span:(float)span {
    MKCoordinateRegion region;
    region.center.latitude  = location.coordinate.latitude;
    region.center.longitude = location.coordinate.longitude;
    
    MKCoordinateSpan coordSpan;
    coordSpan.latitudeDelta  = span;
    coordSpan.longitudeDelta = span;
    
    region.span = coordSpan;
    [_mapView setRegion:region animated:YES];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    [self directionOnmap];
    [self showDetailPlace];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
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
    annotationView.image = [UIImage imageNamed:@"MarkerATM.png"];
    
    return annotationView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *render = [[MKPolylineRenderer alloc]initWithOverlay:overlay];
    render.strokeColor = [UIColor greenColor];
    render.lineWidth = 3;
    return render;
}

@end
