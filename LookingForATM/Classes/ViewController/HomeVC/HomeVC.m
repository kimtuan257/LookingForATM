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
#import <AFNetworking/AFNetworking.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>

@interface HomeVC ()<UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, INSSearchBarDelegate> {
    NSMutableArray *_mainList;
    NSMutableArray *_pins;
    MKPolyline *_routeOverlay;
    MKRoute *_currentRoute;
    AppDelegate *_myAppdelegate;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) INSSearchBar *searchBarINS;
@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _myAppdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [_tableView registerNib:[UINib nibWithNibName:@"HomeCell" bundle:nil] forCellReuseIdentifier:@"HomeCell"];
    [_indicatorView setHidden:YES];
    [_indicatorView stopAnimating];
    self.navigationController.navigationBarHidden = YES;
    [_tableView setHidden:YES];
    [_mapView setHidden:YES];
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

-(void)addPinToMap {
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

-(void)drawRouteOnMap: (MKRoute*)route {
    if (_routeOverlay) {
        [_mapView removeOverlay:_routeOverlay];
    }
    _routeOverlay = route.polyline;
    
    [_mapView addOverlay:_routeOverlay];
}

-(IBAction)selectActionPin:(id)sender {
    UIButton *button = (UIButton*)sender;
    Items *item = _mainList[button.tag];
    MKDirectionsRequest *directionRequest = [MKDirectionsRequest new];
    
    //location source
    CLLocation *sourceLocation = _myAppdelegate.currentLocation;
    CLLocationCoordinate2D sourceCoordinate = CLLocationCoordinate2DMake(sourceLocation.coordinate.latitude, sourceLocation.coordinate.longitude);
    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc]initWithCoordinate:sourceCoordinate addressDictionary:nil];
    MKMapItem *source = [[MKMapItem alloc]initWithPlacemark:sourcePlacemark];
    
    //location destination
    CLLocationCoordinate2D destinationCoordinate = CLLocationCoordinate2DMake(item.latitude, item.longitude);
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc]initWithCoordinate:destinationCoordinate addressDictionary:nil];
    MKMapItem *destination = [[MKMapItem alloc]initWithPlacemark:destinationPlacemark];
    
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
    }];
}

-(IBAction)goToDetail:(id)sender {
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
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
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

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
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
        annotationView.image = [UIImage imageNamed:@"Marker.png"];
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        rightButton.tag = fxAnnotation.index;
        [rightButton addTarget:self action:@selector(selectActionPin:) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setTitle:annotation.title forState:UIControlStateNormal];
        annotationView.rightCalloutAccessoryView = rightButton;
        annotationView.canShowCallout = YES;
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        leftButton.tag = fxAnnotation.index;
        [leftButton addTarget:self action:@selector(goToDetail:) forControlEvents:UIControlEventTouchUpInside];
        annotationView.leftCalloutAccessoryView = leftButton;
        annotationView.canShowCallout = YES;
    }else{
        [mapView.userLocation setTitle:@"I am here"];
    }
    return annotationView;
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *render = [[MKPolylineRenderer alloc]initWithPolyline:overlay];
    render.strokeColor = [UIColor blueColor];
    render.lineWidth = 4;
    return render;
}

#pragma mark - Search Bar Delegate
-(CGRect)destinationFrameForSearchBar:(INSSearchBar *)searchBar {
    return CGRectMake(35, 20, CGRectGetWidth(self.view.bounds) - 70, 34);
}

-(void)searchBarTextDidChange:(INSSearchBar *)searchBar {
    NSString *searchPlace = _searchBarINS.searchField.text;
    [self findATMWithName:searchPlace];
    [_tableView reloadData];
}

-(void)searchBarDidTapReturn:(INSSearchBar *)searchBar {
    [_searchBarINS.searchField resignFirstResponder];
    [self addPinToMap];
}

-(void)searchBar:(INSSearchBar *)searchBar willStartTransitioningToState:(INSSearchBarState)destinationState {
    
}

-(void)searchBar:(INSSearchBar *)searchBar didEndTransitioningFromState:(INSSearchBarState)previousState {
    
}

#pragma mark - Parse WebService
-(void)findATMWithName:(NSString*)name {
    NSString *nameEncoded = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//encoding UTF8 "dong a->dong%20a"
    [_indicatorView setHidden:NO];
    [_indicatorView startAnimating];
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=16.066667,108.23333&radius=5000&types=atm&name=%@&key=AIzaSyADSGUtQ4ssp4Z6pszLMcpL24W3eobN8jo", nameEncoded];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *tempArray = [NSMutableArray new];
        NSDictionary *dic = (NSDictionary*)(responseObject);
        NSArray *results = [dic objectForKey:@"results"];
        for (NSDictionary *objectResult in results) {
            Items *item = [Items new];
            
            //parse name's bank atm
            NSString *name = [objectResult objectForKey:@"name"];
            item.name = name;
            
            //parse address atm
            NSString *address = [objectResult objectForKey:@"vicinity"];
            item.address = address;
            
            //parse location atm
            NSDictionary *geometry = [objectResult objectForKey:@"geometry"];
            NSDictionary *location = [geometry objectForKey:@"location"];
            NSString *latitude = [location objectForKey:@"lat"];
            NSString *longitude = [location objectForKey:@"lng"];
            item.latitude = [latitude doubleValue];
            item.longitude = [longitude doubleValue];
            
            [tempArray addObject:item];
            [_indicatorView setHidden:YES];
            [_indicatorView stopAnimating];
        }
        _mainList = [NSMutableArray arrayWithArray:tempArray];
        [_tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR!");
        [_indicatorView setHidden:YES];
        [_indicatorView startAnimating];
    }];
    [operation start];
}

#pragma mark - TableViewDelegate and TableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _mainList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell" forIndexPath:indexPath];
    Items *item = _mainList[indexPath.row];
    cell.nameLabel.text = item.name;
    cell.addressLabel.text = item.address;
    CLLocation *itemLocation = [[CLLocation alloc]initWithLatitude:item.latitude longitude:item.longitude];
    cell.distanceLabel.text = [NSString stringWithFormat:@"%0.2f km", [_myAppdelegate.currentLocation distanceFromLocation:itemLocation]/1000];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
