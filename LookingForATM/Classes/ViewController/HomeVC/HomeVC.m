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
#import <AFNetworking/AFNetworking.h>
#import <MapKit/MapKit.h>

@interface HomeVC ()<UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, INSSearchBarDelegate> {
    NSMutableArray *_mainList;
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
    [_tableView registerNib:[UINib nibWithNibName:@"HomeCell" bundle:nil] forCellReuseIdentifier:@"HomeCell"];
    [_indicatorView setHidden:YES];
    [_indicatorView stopAnimating];
    self.navigationController.navigationBarHidden = YES;
    [_tableView setHidden:YES];
    [_mapView setHidden:YES];
    _searchBarINS = [[INSSearchBar alloc]initWithFrame:CGRectMake(20, 5, CGRectGetWidth(self.view.bounds) - 40.0, 34)];
    [self.view addSubview:_searchBarINS];
    _searchBarINS.delegate = self;
    _mapView.delegate = self;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
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

-(void)addPinToMap {
    FXAnnotation *pin = [FXAnnotation new];
    for (int i = 0; i < _mainList.count; i++) {
        Items *item = _mainList[i];
        pin.title = item.name;
        pin.subtitle = item.address;
        pin.coordinate = CLLocationCoordinate2DMake(item.latitude, item.longitude);
        CLLocationCoordinate2D zoomLocation;
        zoomLocation.latitude = item.latitude;
        zoomLocation.longitude = item.longitude;
        // 2
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*1609.344, 0.5*1609.344);
        // 3
        [_mapView setRegion:viewRegion animated:YES];
        [_mapView addAnnotation:pin];
    }
}

#pragma mark MapView Delegate
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

#pragma mark Search Bar Delegate
-(CGRect)destinationFrameForSearchBar:(INSSearchBar *)searchBar {
    return CGRectMake(20.0, 5.0, CGRectGetWidth(self.view.bounds) - 40.0, 34.0);
}

-(void)searchBarTextDidChange:(INSSearchBar *)searchBar {
    NSString *searchPlace = _searchBarINS.searchField.text;
    [self findATMWithName:searchPlace];
    [self addPinToMap];
    [_tableView reloadData];
}

-(void)searchBarDidTapReturn:(INSSearchBar *)searchBar {
    [_searchBarINS.searchField resignFirstResponder];
}

-(void)searchBar:(INSSearchBar *)searchBar willStartTransitioningToState:(INSSearchBarState)destinationState {
    
}

-(void)searchBar:(INSSearchBar *)searchBar didEndTransitioningFromState:(INSSearchBarState)previousState {
    
}

#pragma mark Parse WebService
-(void)findATMWithName:(NSString*)name {
    [_indicatorView setHidden:NO];
    [_indicatorView startAnimating];
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=16.066667,108.23333&radius=5000&types=atm&name=%@&key=AIzaSyADSGUtQ4ssp4Z6pszLMcpL24W3eobN8jo", name];
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

#pragma mark TableViewDelegate and TableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _mainList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell" forIndexPath:indexPath];
    Items *item = _mainList[indexPath.row];
    cell.nameLabel.text = item.name;
    cell.addressLabel.text = item.address;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

@end
