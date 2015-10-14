//
//  HomeVC.m
//  LookingForATM
//
//  Created by Le Kim Tuan on 9/22/15.
//  Copyright © 2015 Le Kim Tuan. All rights reserved.
//

#import "HomeVC.h"
#import "HomeCell.h"
#import "Items.h"
#import "INSSearchBar.h"
#import "FXAnnotation.h"
#import "ATMHistory.h"
#import "DetailVC.h"
#import "FavoritesVC.h"
#import "AppDelegate.h"
#import "WebService.h"
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>

@interface HomeVC ()<UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, INSSearchBarDelegate, WebServiceDelegate> {
    NSMutableArray *_mainList;
    NSMutableArray *_pins;
    MKPolyline *_routeOverlay;
    MKRoute *_currentRoute;
    AppDelegate *_myAppdelegate;
    WebService *_loadDataWebService;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (strong, nonatomic) INSSearchBar *searchBarINS;
@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    _myAppdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [_tableView registerNib:[UINib nibWithNibName:@"HomeCell" bundle:nil] forCellReuseIdentifier:@"HomeCell"];
    
    [_tableView setHidden:YES];
    [_mapView setHidden:YES];
    
    [_indicatorView setHidden:YES];
    [_indicatorView stopAnimating];
    
    //init Search Bar
    _searchBarINS = [[INSSearchBar alloc]initWithFrame:CGRectMake(35, 20, CGRectGetWidth(self.view.bounds) - 70, 34)];
    [self.view addSubview:_searchBarINS];
    _searchBarINS.delegate = self;
    
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    
    //init array annotation
    _pins = [NSMutableArray new];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)segmentAction:(id)sender {
    if (_segmentControl.selectedSegmentIndex == 1) {
        [_mapView setHidden:YES];
        [_tableView setHidden:NO];
    }else{
        [_tableView setHidden:YES];
        [_mapView setHidden:NO];
    }
}

- (IBAction)actionGetLocation:(id)sender {
    [_mapView setHidden:NO];
    _mapView.showsUserLocation = YES;
    CLLocation *location = _mapView.userLocation.location;
    MKCoordinateRegion region;
    region.center.latitude  = location.coordinate.latitude;
    region.center.longitude = location.coordinate.longitude;
    MKCoordinateSpan          span;
    span.latitudeDelta      = 0.02;
    span.longitudeDelta     = 0.02;
    region.span             = span;
    [_mapView setRegion:region animated:YES];
}

- (IBAction)goToFavorites:(id)sender {
    FavoritesVC *favoriteVC = [FavoritesVC new];
    [self.navigationController pushViewController:favoriteVC animated:YES];
}

- (void)addPinToMap {
    if (_pins) {
        //remove all overlay and annotation
        [_mapView removeOverlay:_routeOverlay];
        [_mapView removeAnnotations:_pins];
        
        //remove old object in array pins
        [_pins removeAllObjects];
    }
    for (int i = 0; i < _mainList.count; i++) {
        FXAnnotation *pin = [FXAnnotation new];
        Items *item = _mainList[i];
        pin.title = item.name;
        pin.subtitle = item.address;
        pin.coordinate = CLLocationCoordinate2DMake(item.latitude, item.longitude);
        pin.index = i;
        
        [_pins addObject:pin];
    }
    //add annotation for map
    [_mapView addAnnotations:_pins];
}

- (void)drawRouteOnMap: (MKRoute*)route {
    if (_routeOverlay) {
        [_mapView removeOverlay:_routeOverlay];
    }
    _routeOverlay = route.polyline;
    
    [_mapView addOverlay:_routeOverlay];
}

- (IBAction)goToDetail:(id)sender {
    ATMHistory *history = [ATMHistory MR_createEntity];
    DetailVC *detailVC = [DetailVC new];
    FavoritesVC *favorite = [FavoritesVC new];
    UIButton *button = (UIButton*)sender;
    Items *item = _mainList[button.tag];
    
    //Check in coredata atmcurrent has or not
    BOOL flag = YES;
    for (int i = 0; i < favorite.fetchHistory.fetchedObjects.count; i++) {
        ATMHistory *dataTemp = favorite.fetchHistory.fetchedObjects[i];
        
        //Get location atm in coredata
        double latitudeATMCoreData = [dataTemp.latitude doubleValue];
        double longitudeATMCoreData = [dataTemp.longitude doubleValue];
        CLLocation *locationATMCoreData = [[CLLocation alloc]initWithLatitude:latitudeATMCoreData longitude:longitudeATMCoreData];
        
        //Get location atm current
        double latitudeATMCurrent = item.latitude;
        double longitudeATMCurrent = item.longitude;
        CLLocation *locationATMCurrent = [[CLLocation alloc]initWithLatitude:latitudeATMCurrent longitude:longitudeATMCurrent];
        
        //Compare location of atm in coredata and current by calculator distance between 2 locations
        float distance = [locationATMCurrent distanceFromLocation:locationATMCoreData];
        if (distance == 0) {
            flag = NO;
            break;
        }
    }
    if (flag) {
        history.name = item.name;
        history.address = item.address;
        history.latitude = [NSNumber numberWithDouble:item.latitude];
        history.longitude = [NSNumber numberWithDouble:item.longitude];
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    }
    [self.navigationController pushViewController:detailVC animated:YES];
    detailVC.name = item.name;
    detailVC.address = item.address;
    detailVC.latitude = item.latitude;
    detailVC.longitude = item.longitude;
}

#pragma mark - MapView Delegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    CLLocation *location = userLocation.location;
    MKCoordinateRegion region;
    region.center.latitude  = location.coordinate.latitude;
    region.center.longitude = location.coordinate.longitude;
    MKCoordinateSpan          span;
    span.latitudeDelta      = 0.02;
    span.longitudeDelta     = 0.02;
    region.span             = span;
    [_mapView setRegion:region animated:YES];
    [self searchBarTextDidChange:_searchBarINS];
    if (_routeOverlay) {
        [_mapView removeOverlay:_routeOverlay];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    FXAnnotation *annotation = view.annotation;
    [SVProgressHUD showWithStatus:@"Calculating" maskType:SVProgressHUDMaskTypeGradient];
    
    //location source
    CLLocation *sourceLocation = _myAppdelegate.currentLocation;
    CLLocationCoordinate2D sourceCoordinate = CLLocationCoordinate2DMake(sourceLocation.coordinate.latitude, sourceLocation.coordinate.longitude);
    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc]initWithCoordinate:sourceCoordinate addressDictionary:nil];
    MKMapItem *source = [[MKMapItem alloc]initWithPlacemark:sourcePlacemark];
    
    //location destination
    CLLocationCoordinate2D destinationCoordinate = CLLocationCoordinate2DMake(annotation.coordinate.latitude, annotation.coordinate.longitude);
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc]initWithCoordinate:destinationCoordinate addressDictionary:nil];
    MKMapItem *destination = [[MKMapItem alloc]initWithPlacemark:destinationPlacemark];
    
    MKDirectionsRequest *directionRequest = [MKDirectionsRequest new];
    [directionRequest setSource:source];
    [directionRequest setDestination:destination];
    
    MKDirections *direction = [[MKDirections alloc]initWithRequest:directionRequest];
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"ERROR!");
            return;
        }
        _currentRoute = [response.routes firstObject];
        [self drawRouteOnMap:_currentRoute];
        [SVProgressHUD dismiss];
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc]init];
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    //check use location pin
    if(annotation != mapView.userLocation) {
        FXAnnotation *fxAnnotation = (FXAnnotation*)annotation;
        // set reuseable
        static NSString *defaultPinID = @"mypin";
        
        annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if (!annotationView){
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        }
        
        annotationView.canShowCallout = YES;
        annotationView.draggable = YES;
        annotationView.image = [UIImage imageNamed:@"MarkerATM.png"];
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        rightButton.tag = fxAnnotation.index;
        [rightButton addTarget:self action:@selector(goToDetail:) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setTitle:annotation.title forState:UIControlStateNormal];
        annotationView.rightCalloutAccessoryView = rightButton;
        annotationView.canShowCallout = YES;
    }else{
        [mapView.userLocation setTitle:@"I am here"];
    }
    return annotationView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *render = [[MKPolylineRenderer alloc]initWithPolyline:overlay];
    render.strokeColor = [UIColor greenColor];
    render.lineWidth = 3;
    return render;
}

#pragma mark - WebService Delegate
- (void)sendListATMDelegate:(NSMutableArray *)listATM {
    [_mainList removeAllObjects];
    _mainList = [NSMutableArray arrayWithArray:listATM];
    [_tableView reloadData];
}

#pragma mark - Search Bar Delegate
- (CGRect)destinationFrameForSearchBar:(INSSearchBar *)searchBar {
    return CGRectMake(35, 20, CGRectGetWidth(self.view.bounds) - 70, 34);
}

- (void)searchBarTextDidChange:(INSSearchBar *)searchBar {
    [_indicatorView setHidden:NO];
    [_indicatorView startAnimating];
    NSString *searchText = searchBar.searchField.text;
    double currentLatitude = _myAppdelegate.currentLocation.coordinate.latitude;
    double currentLongitude = _myAppdelegate.currentLocation.coordinate.longitude;
    _loadDataWebService = [WebService new];
    _loadDataWebService.delegate = self;
    [_loadDataWebService findATMWithName:searchText latitude:currentLatitude longitude:currentLongitude];
}

- (void)searchBarDidTapReturn:(INSSearchBar *)searchBar {
    [searchBar.searchField resignFirstResponder];
    [self addPinToMap];
}

- (void)searchBar:(INSSearchBar *)searchBar willStartTransitioningToState:(INSSearchBarState)destinationState {
    
}

- (void)searchBar:(INSSearchBar *)searchBar didEndTransitioningFromState:(INSSearchBarState)previousState {
    
}

#pragma mark - TableViewDelegate and TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _mainList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell" forIndexPath:indexPath];
    Items *item = _mainList[indexPath.row];
    cell.nameLabel.text = item.name;
    cell.addressLabel.text = item.address;
    CLLocation *itemLocation = [[CLLocation alloc]initWithLatitude:item.latitude longitude:item.longitude];
    cell.distanceLabel.text = [NSString stringWithFormat:@"%0.2f km", [_myAppdelegate.currentLocation distanceFromLocation:itemLocation]/1000];
    [_indicatorView setHidden:YES];
    [_indicatorView stopAnimating];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //Check in coredata atmcurrent has or not
    DetailVC *detailVC = [DetailVC new];
    ATMHistory *history = [ATMHistory MR_createEntity];
    FavoritesVC *favorite = [FavoritesVC new];
    Items *item = _mainList[indexPath.row];
    BOOL flag = YES;
    for (int i = 0; i < favorite.fetchHistory.fetchedObjects.count; i++) {
        ATMHistory *dataTemp = favorite.fetchHistory.fetchedObjects[i];
        
        //Get location of ATM in CoreData
        double latitudeATMCoreData = [dataTemp.latitude doubleValue];
        double longitudeATMCoreData = [dataTemp.longitude doubleValue];
        CLLocation *locationATMCoreData = [[CLLocation alloc]initWithLatitude:latitudeATMCoreData longitude:longitudeATMCoreData];
        
        //Get location of ATM current
        double latitudeATMCurrent = item.latitude;
        double longitudeATMCurrent = item.longitude;
        CLLocation *locationATMCurrent = [[CLLocation alloc]initWithLatitude:latitudeATMCurrent longitude:longitudeATMCurrent];
        
        //Compare location of ATM in coredata and current by calculator distance between 2 locations
        float distance = [locationATMCurrent distanceFromLocation:locationATMCoreData];
        if (distance == 0) {
            flag = NO;
            break;
        }
    }
    if (flag) {
        history.name = item.name;
        history.address = item.address;
        history.latitude = [NSNumber numberWithDouble:item.latitude];
        history.longitude = [NSNumber numberWithDouble:item.longitude];
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    }
    [self.navigationController pushViewController:detailVC animated:YES];
    detailVC.name = item.name;
    detailVC.address = item.address;
    detailVC.latitude = item.latitude;
    detailVC.longitude = item.longitude;
}

@end
