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
    return [self initWithTwitter:@"" andCreator:nil andAttendees:[[NSMutableArray alloc] init] andWords:[[NSMutableArray alloc] init]];
}

- (id)initWithTwitter:(NSString *)twitterID andCreator:(NSString *)creator;
{
    return [self initWithTwitter:twitterID andCreator:creator andAttendees:[[NSMutableArray alloc] init] andWords:[[NSMutableArray alloc] init]];
}

- (id)initWithTwitter:(NSString *)twitterID andCreator:(NSString *)creator andAttendees:(NSMutableArray *)attendees andWords:(NSMutableArray *)words;
{
    self = [super init];
    if (self) {
        self.twitterID = twitterID;
        self.creator = creator;
        self.attendees = attendees;
        self.words = words;
    }
    return self;
}

#pragma mark Firebase Protocol methods

- (id)initWithDictionary:(NSDictionary *)dict;
{
    NSString *twitterID = [dict objectForKey:@"Twitter ID"];
    NSString *creator = [dict objectForKey:@"Creator"];
    NSMutableArray *attendees = [dict objectForKey:@"Attendees"];
    NSMutableArray *words = [dict objectForKey:@"Words"];
    return [self initWithTwitter:twitterID andCreator:creator andAttendees:attendees andWords:words];
}


- (NSDictionary *)toDictionary;
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.twitterID forKey:@"Twitter ID"];
    [dict setObject:self.creator forKey:@"Creator"];
    [dict setObject:self.attendees forKey:@"Attendees"];
    [dict setObject:self.words forKey:@"Words"];
    return dict;
}

#pragma mark Overriding isEqual methods to allow for deletion

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToConference:other];
}

- (BOOL)isEqualToConference:(FBZConference *)conference {
    if (self == conference)
        return YES;
    if (!([self.twitterID isEqualToString:conference.twitterID]))
        return NO;
    return YES;
}


@end
