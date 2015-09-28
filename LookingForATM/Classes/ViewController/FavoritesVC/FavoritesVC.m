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

@interface FavoritesVC ()<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *favoritesTableView;
@property (weak, nonatomic) IBOutlet UITableView *historyTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation FavoritesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [_favoritesTableView setHidden:YES];
    [_historyTableView setHidden:YES];
    [_favoritesTableView registerNib:[UINib nibWithNibName:@"HomeCell" bundle:nil] forCellReuseIdentifier:@"HomeCell"];
    [_historyTableView registerNib:[UINib nibWithNibName:@"HomeCell" bundle:nil] forCellReuseIdentifier:@"HomeCell"];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)segmentAction:(id)sender {
    if (_segmentedControl.selectedSegmentIndex == 0) {
        [_historyTableView setHidden:NO];
        [_favoritesTableView setHidden:YES];
    }else{
        [_historyTableView setHidden:YES];
        [_favoritesTableView setHidden:NO];
    }
}

- (IBAction)backToHome:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - getter
-(NSFetchedResultsController*)fetchResultController {
    if (!_fetchResultController) {
        _fetchResultController = [ATMFavoritesModel fetchDataWithDelegate:self];
    }
    return _fetchResultController;
}

#pragma mark - NSFetchResultController
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_favoritesTableView reloadData];
}

#pragma mark - TableView DataSource and Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchResultController.fetchedObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"HomeCell" owner:self options:nil][0];
    }
    ATMFavorites *favorites = self.fetchResultController.fetchedObjects[indexPath.row];
    cell.nameLabel.text = favorites.name;
    cell.addressLabel.text = favorites.address;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

@end
