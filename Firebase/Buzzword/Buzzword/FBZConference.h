//
//  FBZConference.h
//  Buzzword
//
//  Created by Michael McDonald on 7/2/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FirebaseProtocol.h"

@interface FBZConference : NSObject <FirebaseProtocol>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *twitterID;
@property (strong, nonatomic) NSMutableArray *attendes;

- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;

@end
