//
//  SHOReview.h
//  ShortOrder
//
//  Created by Michael McDonald on 2/18/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import "SHOUser.h"
#import "FirebaseProtocol.h"
#import <Foundation/Foundation.h>

@interface SHOReview : NSObject <FirebaseProtocol>

@property (strong, nonatomic) SHOUser *user;
@property (strong, nonatomic) NSString *reviewID;
@property NSInteger waitTimeMinutes;
@property NSInteger waitTimeHours;
@property BOOL wasWorthIt;
@property (strong, nonatomic) NSDate *timestamp;

//TODO associate with UserID
- (id)initWithDictionary:(NSDictionary *)dict;
- (id)initWithWaitTimeMinutes:(NSInteger)minutes andHours:(NSInteger)hours wasWorthIt:(BOOL)worthIt atDate:(NSDate *)date;
- (NSDictionary *)toDictionary;
@end
