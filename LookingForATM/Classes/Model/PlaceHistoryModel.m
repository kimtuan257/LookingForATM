//
//  PlaceHistoryModel.m
//  LookingForATM
//
//  Created by Le Kim Tuan on 9/27/15.
//  Copyright © 2015 Le Kim Tuan. All rights reserved.
//

#import "PlaceHistoryModel.h"
#import "PlaceHistory.h"

@implementation PlaceHistoryModel
+(NSFetchedResultsController *)fetchDataWithDelegate:(id)delegate {
    return [PlaceHistory MR_fetchAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"name != nil"] groupBy:nil delegate:delegate];
}
@end
