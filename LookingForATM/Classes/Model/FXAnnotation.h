//
//  FXAnnotation.h
//  SearchPlaceAFNetworking
//
//  Created by Lê Kim Tuấn on 9/16/15.
//  Copyright © 2015 Lê Kim Tuấn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FXAnnotation : NSObject<MKAnnotation>

// cac property bat buoc
@property (nonatomic, copy) NSString                    *title;
@property (nonatomic, copy) NSString                    *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D    coordinate;

// cac property tu them vao
@property (nonatomic) int index;

@end
