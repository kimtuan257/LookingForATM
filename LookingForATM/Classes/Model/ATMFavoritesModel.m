//
//  ATMFavoritesModel.m
//  LookingForATM
//
//  Created by Le Kim Tuan on 9/28/15.
//  Copyright © 2015 Le Kim Tuan. All rights reserved.
//

#import "ATMFavoritesModel.h"
#import "ATMFavorites.h"

@implementation ATMFavoritesModel
+(NSFetchedResultsController *)fetchFavoriteWithDelegate:(id)delegate {
    return [ATMFavorites MR_fetchAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"name != nil"] groupBy:nil delegate:delegate];
}
@end
