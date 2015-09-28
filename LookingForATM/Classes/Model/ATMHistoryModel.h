//
//  ATMHistoryModel.h
//  LookingForATM
//
//  Created by Le Kim Tuan on 9/28/15.
//  Copyright © 2015 Le Kim Tuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATMHistoryModel : NSObject
+(NSFetchedResultsController*)fetchHistoryWithDelegate:(id)delegate;
@end
