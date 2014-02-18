//
//  SHORestaurant.m
//  ShortOrder
//
//  Created by Michael McDonald on 2/18/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import "SHORestaurant.h"

@implementation SHORestaurant

- (id)init
{
    return [self initWithName:@"Restaurant" waitInMinutes:0 andHours:0 isFavorite:NO];
}

- (id)initWithName:(NSString *)restaurantName waitInMinutes:(NSInteger)minutes andHours:(NSInteger)hours isFavorite:(BOOL)favorite;
{
    self = [super init];
    if (self) {
        self.waitTimeHours = hours;
        self.waitTimeMinutes = minutes;
        self.restaurantName = restaurantName;
        self.isFavorite = favorite;
    }
    return self;
}

@end
