//
//  FBZConference.m
//  Buzzword
//
//  Created by Michael McDonald on 7/2/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FBZConference.h"

@implementation FBZConference

- (id)init
{
    return [self initWithTwitter:@"" andAttendes:[[NSMutableArray alloc] init]];
}

- (id)initWithTwitter:(NSString *)twitterID andAttendes:(NSMutableArray *)attendes;
{
    self = [super init];
    if (self) {
        self.twitterID = twitterID;
        self.attendes = attendes;
    }
    return self;
}


- (id)initWithDictionary:(NSDictionary *)dict;
{
    NSString *twitterID = [dict objectForKey:@"Twitter ID"];
    NSMutableArray *attendes = [dict objectForKey:@"Attendes"];
    return [self initWithTwitter:twitterID andAttendes:attendes];
}


- (NSDictionary *)toDictionary;
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.twitterID forKey:@"Twitter ID"];
    [dict setObject:self.attendes forKey:@"Attendes"];
    return dict;
}


@end
