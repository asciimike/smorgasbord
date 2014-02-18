//
//  SHOReview.h
//  ShortOrder
//
//  Created by Michael McDonald on 2/18/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHOReview : NSObject

@property NSInteger waitTimeMinutes;
@property NSInteger waitTimeHours;
@property BOOL wasWorthIt;
@property (strong, nonatomic) NSDate *timestamp;

//TODO associate with UserID

- (id)initWithWaitTimeMinutes:(NSInteger)minutes andHours:(NSInteger)hours wasWorthIt:(BOOL)worthIt atDate:(NSDate *)date;

@end
