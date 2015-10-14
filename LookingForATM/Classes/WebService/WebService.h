//
//  WebService.h
//  LookingForATM
//
//  Created by Le Kim Tuan on 10/14/15.
//  Copyright © 2015 Le Kim Tuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WebServiceDelegate;

@interface WebService : NSObject

@property (weak, nonatomic) id<WebServiceDelegate>delegate;

- (void)findATMWithName:(NSString *)name latitude:(double)latitude longitude:(double)longitude;

@end

@protocol WebServiceDelegate <NSObject>

- (void)sendListATMDelegate:(NSMutableArray *)listATM;

@end
