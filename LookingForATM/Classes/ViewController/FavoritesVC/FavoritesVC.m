//
//  FavoritesVC.m
//  LookingForATM
//
//  Created by Le Kim Tuan on 9/28/15.
//  Copyright © 2015 Le Kim Tuan. All rights reserved.
//

#import "FavoritesVC.h"
#import "HomeCell.h"
#import "Items.h"
#import "ATMFavorites.h"
#import "ATMFavoritesModel.h"
#import "ATMHistory.h"
#import "ATMHistoryModel.h"
#import "AppDelegate.h"
#import "DetailVC.h"
#import <CoreLocation/CoreLocation.h>
#import <UIScrollView+EmptyDataSet.h>

@interface FavoritesVC ()<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource> {
    AppDelegate *_myAppDelegate;
    CLLocationManager *_locationManager;
}
@property (weak, nonatomic) IBOutlet UITableView *favoritesTableView;
@property (weak, nonatomic) IBOutlet UITableView *historyTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation FavoritesVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [_titleLabel setText:@"ATM Searched"];
    [_favoritesTableView setHidden:YES];
    _myAppDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_favoritesTableView registerNib:[UINib nibWithNibName:@"HomeCell" bundle:nil] forCellReuseIdentifier:@"HomeCell"];
    [_historyTableView registerNib:[UINib nibWithNibName:@"HomeCell" bundle:nil] forCellReuseIdentifier:@"HomeCell"];
    
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = 10;//10 met
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;//do chinh xac gan 10 met
    [_locationManager startUpdatingLocation];
    
    self.favoritesTableView.emptyDataSetDelegate = self;
    self.favoritesTableView.emptyDataSetSource = self;
    self.favoritesTableView.tableFooterView = [UIView new];
    
    self.historyTableView.emptyDataSetSource = self;
    self.historyTableView.emptyDataSetDelegate = self;
    self.historyTableView.tableFooterView = [UIView new];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - IBActions

- (IBAction)segmentAction:(id)sender {
    if (_segmentedControl.selectedSegmentIndex == 0) {
        [_titleLabel setText:@"ATM Searched"];
        [_historyTableView setHidden:NO];
        [_favoritesTableView setHidden:YES];
    } else {
        [_titleLabel setText:@"ATM Favorites"];
        [_historyTableView setHidden:YES];
        [_favoritesTableView setHidden:NO];
    }
}

- (IBAction)backButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - getter ATMFavoritesModel

- (NSFetchedResultsController*)fetchFavorite {
    if (!_fetchFavorite) {
        _fetchFavorite = [ATMFavoritesModel fetchFavoriteWithDelegate:self];
    }
    return _fetchFavorite;
}

#pragma mark - getter ATMHistoryModel

- (NSFetchedResultsController*)fetchHistory {
    if (!_fetchHistory) {
        _fetchHistory = [ATMHistoryModel fetchHistoryWithDelegate:self];
    }
    return _fetchHistory;
}

#pragma mark - NSFetchResultController

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_favoritesTableView reloadData];
    [_historyTableView reloadData];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [_historyTableView reloadData];
    [_favoritesTableView reloadData];
}

#pragma mark - DZNDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"NO DATA";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"List ATM is empty";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"FavoritesEmpty.png"];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIColor whiteColor];
}

#pragma mark - DZNDataSetDelegate

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.favoritesTableView) {
        return [self.fetchFavorite.fetchedObjects count];
    } else {
        return [self.fetchHistory.fetchedObjects count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell" forIndexPath:indexPath];
    if (tableView == _favoritesTableView) {
        ATMFavorites *favorites = self.fetchFavorite.fetchedObjects[indexPath.row];
        cell.nameLabel.text = favorites.name;
        cell.addressLabel.text = favorites.address;
        double atmLatitude = [favorites.latitude doubleValue];
        double atmLongitude = [favorites.longitude doubleValue];
        CLLocation *atmLocation = [[CLLocation alloc]initWithLatitude:atmLatitude longitude:atmLongitude];
        cell.distanceLabel.text = [NSString stringWithFormat:@"%0.2f km", [_myAppDelegate.currentLocation distanceFromLocation:atmLocation]/1000];
        return cell;
    } else {
        ATMHistory *history = self.fetchHistory.fetchedObjects[indexPath.row];
        cell.nameLabel.text = history.name;
        cell.addressLabel.text = history.address;
        double atmLatitude = [history.latitude doubleValue];
        double atmLongitude = [history.longitude doubleValue];
        CLLocation *atmLocation = [[CLLocation alloc]initWithLatitude:atmLatitude longitude:atmLongitude];
        cell.distanceLabel.text = [NSString stringWithFormat:@"%0.2f km", [_myAppDelegate.currentLocation distanceFromLocation:atmLocation]/1000];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _favoritesTableView) {
        ATMFavorites *favorites = self.fetchFavorite.fetchedObjects[indexPath.row];
        [favorites MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        [_favoritesTableView reloadData];
    } else {
        ATMHistory *history = self.fetchHistory.fetchedObjects[indexPath.row];
        [history MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        [_historyTableView reloadData];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _favoritesTableView) {
        [_favoritesTableView deselectRowAtIndexPath:indexPath animated:YES];
        DetailVC *vc = [DetailVC new];
        ATMFavorites *favorite = self.fetchFavorite.fetchedObjects[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
        vc.name = favorite.name;
        vc.address = favorite.address;
        vc.latitude = [favorite.latitude doubleValue];
        vc.longitude = [favorite.longitude doubleValue];
    } else {
        [_historyTableView deselectRowAtIndexPath:indexPath animated:YES];
        DetailVC *vc = [DetailVC new];
        ATMHistory *history = self.fetchHistory.fetchedObjects[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
        vc.name = history.name;
        vc.address = history.address;
        vc.latitude = [history.latitude doubleValue];
        vc.longitude = [history.longitude doubleValue];
    }
}

@end
