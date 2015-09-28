//
//  ATMHistoryModel.m
//  LookingForATM
//
//  Created by Le Kim Tuan on 9/28/15.
//  Copyright © 2015 Le Kim Tuan. All rights reserved.
//

#import "ATMHistoryModel.h"
#import "ATMHistory.h"

@implementation ATMHistoryModel
+(NSFetchedResultsController *)fetchHistoryWithDelegate:(id)delegate {
    return [ATMHistory MR_fetchAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"name != nil"] groupBy:nil delegate:delegate];
}
@end
