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
    return [self initWithWaitTimeMinutes:0 andHours:0 wasWorthIt:NO atDate:[NSDate date]];
}

- (id)initWithWaitTimeMinutes:(NSInteger)minutes andHours:(NSInteger)hours wasWorthIt:(BOOL)worthIt atDate:(NSDate *)date;
{
    self = [super init];
    if (self) {
        self.waitTimeMinutes = minutes;
        self.waitTimeHours = hours;
        self.wasWorthIt = worthIt;
        self.timestamp = date;
    }
    return self;
}

@end
