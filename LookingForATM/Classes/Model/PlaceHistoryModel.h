//
//  PlaceHistoryModel.h
//  LookingForATM
//
//  Created by Le Kim Tuan on 9/27/15.
//  Copyright © 2015 Le Kim Tuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlaceHistoryModel : NSObject
+(NSFetchedResultsController*)fetchDataWithDelegate: (id)delegate;
@end
