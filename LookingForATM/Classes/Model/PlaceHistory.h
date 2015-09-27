//
//  PlaceHistory+CoreDataProperties.h
//  LookingForATM
//
//  Created by Le Kim Tuan on 9/27/15.
//  Copyright © 2015 Le Kim Tuan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

@class PlaceHistory;
@interface PlaceHistory : NSManagedObject

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;

@end
