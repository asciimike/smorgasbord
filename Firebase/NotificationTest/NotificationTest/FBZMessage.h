//
//  FBZMessage.h
//  NotificationTest
//
//  Created by Michael McDonald on 9/2/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FirebaseProtocol.h"

#import <Foundation/Foundation.h>

@interface FBZMessage : NSObject <FirebaseProtocol>

@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *data;

- (id)initWithId:(NSString *)uid Author:(NSString *)author Data:(NSString *)data;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;

@end
