//
//  SHORestaurant.m
//  ShortOrder
//
//  Created by Michael McDonald on 2/18/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import "SHORestaurant.h"
#import "SHOReview.h"

#define MINUTES_PER_HOUR 60

@implementation SHORestaurant

- (id)init
{
    return [self initWithName:@"Restaurant" waitInMinutes:0 andHours:0 isFavorite:NO];
}

- (id) initWithName:(NSString *)restaurantName isFavorite:(BOOL)favorite;
{
    NSInteger totalMinutes = [self predictWaitTimeFromReviewsByAveraging];
    NSInteger hours = totalMinutes / MINUTES_PER_HOUR;
    NSInteger minutes = totalMinutes % MINUTES_PER_HOUR;
    return [self initWithName:restaurantName waitInMinutes:minutes andHours:hours isFavorite:favorite];
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

- (NSInteger)predictWaitTimeFromReviewsByAveraging;
{
    // Ensure we aren't going to divide by zero here
    if ([self.reviewList count] == 0) {
        return 0;
    }
    
    NSInteger runningAverage = 0;
    for (SHOReview *review in self.reviewList) {
        runningAverage += review.waitTimeMinutes + MINUTES_PER_HOUR*review.waitTimeHours;
    }
    
    return runningAverage/[self.reviewList count];
}

- (NSInteger)calculateWasWorthItPercent;
{
    if ([self.reviewList count] == 0) {
        return 0;
    }
    
    NSInteger worthIt = 0;
    for (SHOReview *review in self.reviewList) {
        if (review.wasWorthIt) {
            worthIt++;
        }
    }
    
    worthIt *= 100;
    worthIt /= [self.reviewList count];
    return worthIt;
}

- (NSInteger)calculateWasNotWorthItPercent;
{
    if ([self.reviewList count] == 0) {
        return 0;
    }
    
    return 100 - [self calculateWasWorthItPercent];
}

- (void)setReviewList:(NSMutableArray *)reviewList;
{
    _reviewList = reviewList;
    NSInteger totalMinutes = [self predictWaitTimeFromReviewsByAveraging];
    NSInteger hours = totalMinutes / MINUTES_PER_HOUR;
    NSInteger minutes = totalMinutes % MINUTES_PER_HOUR;
    self.waitTimeHours = hours;
    self.waitTimeMinutes = minutes;
    
}

@end
