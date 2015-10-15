//
//  WebService.m
//  LookingForATM
//
//  Created by Le Kim Tuan on 10/14/15.
//  Copyright © 2015 Le Kim Tuan. All rights reserved.
//

#import "WebService.h"
#import "Items.h"
#import <AFNetworking/AFNetworking.h>

@implementation WebService

#pragma mark - Public

- (void)findATMWithName:(NSString *)name latitude:(double)latitude longitude:(double)longitude {
    NSString *nameEncoded = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=5000&types=atm&name=%@&key=AIzaSyADSGUtQ4ssp4Z6pszLMcpL24W3eobN8jo", latitude, longitude, nameEncoded];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *arrayPlace = [NSMutableArray new];
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSArray *results = [dic objectForKey:@"results"];
        for (NSDictionary *objectResult in results) {
            Items *item = [Items new];
            
            NSString *name = [objectResult objectForKey:@"name"];
            item.name = name;
            
            NSString *address = [objectResult objectForKey:@"vicinity"];
            item.address = address;
            
            NSDictionary *geometry = [objectResult objectForKey:@"geometry"];
            NSDictionary *location = [geometry objectForKey:@"location"];
            NSString *latitude = [location objectForKey:@"lat"];
            NSString *longitude = [location objectForKey:@"lng"];
            item.latitude = [latitude doubleValue];
            item.longitude = [longitude doubleValue];
            
            NSArray *typeArray = [objectResult objectForKey:@"types"];
            NSString *type = [typeArray firstObject];
            item.type = type;
            
            [arrayPlace addObject:item];
        }
        [_delegate sendListATMDelegate:arrayPlace];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR!");
    }];
    [operation start];
}

@end
