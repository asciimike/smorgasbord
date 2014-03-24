//
//  SHOUser.m
//  ShortOrder
//
//  Created by Michael McDonald on 3/24/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import "SHOUser.h"

@implementation SHOUser

- (id)init;
{
    return [self initWithUsername:@"" andFavoriteRestaurants:[[NSMutableArray alloc] init]];
}

- (id)initWithUsername:(NSString *)username;
{
    return [self initWithUsername:username andFavoriteRestaurants:[[NSMutableArray alloc] init]];
}

- (id)initWithUsername:(NSString *)username andFavoriteRestaurants:(NSMutableArray *)restaurants;
{
    self = [super init];
    if (self) {
        self.username = username;
        self.favoriteRestaurants = restaurants;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict;
{
    NSString *username = [dict objectForKey:@"username"];
    NSArray *favoriteArray = [dict objectForKey:@"favoriteRestaurants"];
    NSMutableArray *mutableFavorites = [[NSMutableArray alloc] initWithArray:favoriteArray];
    return [self initWithUsername:username andFavoriteRestaurants:mutableFavorites];
}

- (NSDictionary *)toDictionary;
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.username forKey:@"username"];
    [dict setObject:self.favoriteRestaurants forKey:@"favoriteRestaurants"];
    return dict;
}

- (void)favoriteRestaurant:(SHORestaurant *)restaurant;
{
    [self.favoriteRestaurants addObject:restaurant.restaurantID];
}


@end
