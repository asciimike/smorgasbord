//
//  SHORestaurant.h
//  ShortOrder
//
//  Created by Michael McDonald on 2/18/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHORestaurant : NSObject

@property (strong, nonatomic) NSString *restaurantName;
@property (nonatomic) NSInteger waitTimeMinutes;
@property (nonatomic) NSInteger waitTimeHours;
@property BOOL isFavorite;
@property (strong, nonatomic) NSMutableArray *reviewList;

// add in info on location

- (id)initWithName:(NSString *)restaurantName waitInMinutes:(NSInteger)minutes andHours:(NSInteger)hours isFavorite:(BOOL)favorite;

- (NSInteger)predictWaitTimeFromReviewsByAveraging;
- (NSInteger)calculateWasWorthItPercent;
- (NSInteger)calculateWasNotWorthItPercent;

@end
