//
//  SHOUser.h
//  ShortOrder
//
//  Created by Michael McDonald on 3/24/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import "SHORestaurant.h"
#import "FirebaseProtocol.h"
#import <Foundation/Foundation.h>

@interface SHOUser : NSObject <FirebaseProtocol>

@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSMutableArray *favoriteRestaurants;

- (id)initWithUsername:(NSString *)username;
- (id)initWithUsername:(NSString *)username andFavoriteRestaurants:(NSMutableArray *)restaurants;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;
- (void)favoriteRestaurant:(SHORestaurant *)restaurant;


@end
