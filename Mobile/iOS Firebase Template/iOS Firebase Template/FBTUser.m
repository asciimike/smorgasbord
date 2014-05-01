//
//  FBTUser.m
//  iOS Firebase Template
//
//  Created by Michael McDonald on 4/17/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FBTUser.h"

@implementation FBTUser

- (id) init;
{
    return [self initWithUsername:@""];
}

- (id) initWithUsername:(NSString *)username;
{
    self = [super init];
    if (self) {
        self.username = username;
        self.firstname = @"";
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict;
{
    NSString *username = [dict objectForKey:@"username"];
    NSString *firstname = [dict objectForKey:@"firstname"];
    return [self initWithUsername:username];
}

- (NSDictionary *)toDictionary;
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.username forKey:@"username"];
    [dict setObject:self.firstname forKey:@"firstname"];
    return dict;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToUser:other];
}

- (BOOL)isEqualToUser:(FBTUser *)user {
    if (self == user)
        return YES;
    if (!([self.uid isEqualToString:user.uid]))
        return NO;
    return YES;
}



@end
