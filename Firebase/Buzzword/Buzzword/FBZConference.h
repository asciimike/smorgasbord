//
//  FBZConference.h
//  Buzzword
//
//  Created by Michael McDonald on 7/2/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>

#import "FirebaseProtocol.h"

@interface FBZConference : NSObject <FirebaseProtocol>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *twitterID;
@property (strong, nonatomic) NSString *creator;
@property (strong, nonatomic) NSMutableArray *attendees;
@property (strong, nonatomic) NSMutableArray *words;

- (id)initWithTwitter:(NSString *)twitterID andCreator:(NSString *)creator;
- (id)initWithTwitter:(NSString *)twitterID andCreator:(NSString *)creator andAttendees:(NSMutableArray *)attendees andWords:(NSMutableArray *)words;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;

@end
