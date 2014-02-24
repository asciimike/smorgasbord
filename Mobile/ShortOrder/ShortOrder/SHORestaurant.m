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

- (id)initWithDictionary:(NSDictionary *)dict;
{
    NSString *name = [dict objectForKey:@"restaurantName"];
    NSInteger minutes = [[dict objectForKey:@"waitTimeMinutes"] integerValue];
    NSInteger hours = [[dict objectForKey:@"waitTimeHours"] integerValue];
    BOOL favorite = [[dict objectForKey:@"isFavorite"] boolValue];
//    NSArray *reviews = [dict objectForKey:@"reviewList"];
//    NSMutableArray *mutableReviews = [[NSMutableArray alloc] init];
//    for (NSDictionary *dict in reviews) {
//        SHOReview *currentReview = [[SHOReview alloc] initWithDictionary:dict];
//        [mutableReviews addObject:currentReview];
//    }
//    self.reviewList = mutableReviews;
    //return [self initWithName:name isFavorite:favorite];
    return [self initWithName:name waitInMinutes:minutes andHours:hours isFavorite:favorite];
}

- (id)initWithName:(NSString *)restaurantName isFavorite:(BOOL)favorite;
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
    [self refreshData];
}

- (void)refreshData;
{
    NSSortDescriptor *hoursDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    _reviewList = [[_reviewList sortedArrayUsingDescriptors:@[hoursDescriptor]] mutableCopy];
    NSInteger totalMinutes = [self predictWaitTimeFromReviewsByAveraging];
    NSInteger hours = totalMinutes / MINUTES_PER_HOUR;
    NSInteger minutes = totalMinutes % MINUTES_PER_HOUR;
    self.waitTimeHours = hours;
    self.waitTimeMinutes = minutes;
}

- (NSDictionary *)toDictionary;
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.restaurantName forKey:@"restaurantName"];
    [dict setObject:[NSNumber numberWithInteger:self.waitTimeMinutes] forKey:@"waitTimeMinutes"];
    [dict setObject:[NSNumber numberWithInteger:self.waitTimeHours] forKey:@"waitTimeHours"];
    [dict setObject:[NSNumber numberWithBool:self.isFavorite] forKey:@"isFavorite"];
//    NSMutableArray *reviewArray = [[NSMutableArray alloc] init];
//    for (SHOReview *review in self.reviewList) {
//        [reviewArray addObject:[review toDictionary]];
//    }
//    [dict setObject:reviewArray forKey:@"reviewList"];
    return dict;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToRestaurant:other];
}

- (BOOL)isEqualToRestaurant:(SHORestaurant *)restaurant {
    if (self == restaurant)
        return YES;
    if (!([self.restaurantID isEqualToString:restaurant.restaurantID]))
        return NO;
    return YES;
}

@end
