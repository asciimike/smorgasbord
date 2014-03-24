//
//  SHOReview.m
//  ShortOrder
//
//  Created by Michael McDonald on 2/18/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import "SHOReview.h"

@implementation SHOReview

- (id)init
{
    return [self initWithWaitTimeMinutes:0 andHours:0 wasWorthIt:NO atDate:[NSDate date] byUser:nil];
}

- (id)initWithDictionary:(NSDictionary *)dict;
{
    NSInteger minutes = [[dict objectForKey:@"reviewWaitTimeMinutes"] integerValue];
    NSInteger hours = [[dict objectForKey:@"reviewWaitTimeHours"] integerValue];
    BOOL worthIt = [[dict objectForKey:@"reviewWasWorthIt"] integerValue];
    NSTimeInterval timeInterval = [(NSNumber *)[dict objectForKey:@"timestamp"] doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
    //pull user out
    SHOUser *user = [[SHOUser alloc] initWithDictionary:nil];
    return [self initWithWaitTimeMinutes:minutes andHours:hours wasWorthIt:worthIt atDate:date byUser:user];
}

- (id)initWithWaitTimeMinutes:(NSInteger)minutes andHours:(NSInteger)hours wasWorthIt:(BOOL)worthIt atDate:(NSDate *)date;
{
    return [self initWithWaitTimeMinutes:minutes andHours:hours wasWorthIt:worthIt atDate:date byUser:nil];
}

- (id)initWithWaitTimeMinutes:(NSInteger)minutes andHours:(NSInteger)hours wasWorthIt:(BOOL)worthIt atDate:(NSDate *)date byUser:(SHOUser *)user;
{
    self = [super init];
    if (self) {
        self.waitTimeMinutes = minutes;
        self.waitTimeHours = hours;
        self.wasWorthIt = worthIt;
        self.timestamp = date;
        self.user = user;
    }
    return self;
}

- (NSDictionary *)toDictionary;
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[NSNumber numberWithInteger:self.waitTimeMinutes] forKey:@"reviewWaitTimeMinutes"];
    [dict setValue:[NSNumber numberWithInteger:self.waitTimeHours] forKey:@"reviewWaitTimeHours"];
    [dict setValue:[NSNumber numberWithBool:self.wasWorthIt] forKey:@"reviewWasWorthIt"];
    [dict setValue:[NSNumber numberWithDouble:[self.timestamp timeIntervalSinceReferenceDate]] forKey:@"timestamp"];
    // Add user ID
    return dict;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToReview:other];
}

- (BOOL)isEqualToReview:(SHOReview *)review {
    if (self == review)
        return YES;
    if (!([self.reviewID isEqualToString:review.reviewID]))
        return NO;
    return YES;
}



@end
