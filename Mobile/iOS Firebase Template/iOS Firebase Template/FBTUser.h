//
//  FBTUser.h
//  iOS Firebase Template
//
//  Created by Michael McDonald on 4/17/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FirebaseProtocol.h"
#import <Foundation/Foundation.h>

@interface FBTUser : NSObject <FirebaseProtocol>

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *firstname;
@property (strong, nonatomic) NSString *uid;

- (id) init;
- (id) initWithUsername:(NSString *)username;
- (id) initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;

@end
