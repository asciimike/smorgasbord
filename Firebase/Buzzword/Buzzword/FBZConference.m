//
//  FBZConference.m
//  Buzzword
//
//  Created by Michael McDonald on 7/2/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FBZConference.h"

@implementation FBZConference

//- (id)init
//{
//    return [self initWithTwitter:@"" andCreator:nil andAttendees:[[NSMutableArray alloc] init] andWords:[[NSMutableArray alloc] init]];
//}
//
- (id)initWithTwitter:(NSDictionary *)twitter andCreator:(NSString *)creator;
{
    return [self initWithTwitter:twitter andCreator:creator andAttendees:[[NSMutableArray alloc] init] andWords:[[NSMutableArray alloc] init]];
}
//
//- (id)initWithTwitter:(NSString *)twitterID andCreator:(NSString *)creator andAttendees:(NSMutableArray *)attendees andWords:(NSMutableArray *)words;
//{
//    self = [super init];
//    if (self) {
//        self.twitterID = twitterID;
//        self.creator = creator;
//        self.attendees = attendees;
//        self.words = words;
//    }
//    return self;
//}

- (id)initWithTwitter:(NSDictionary *)twitter andCreator:(NSString *)creator andAttendees:(NSMutableArray *)attendees andWords:(NSMutableArray *)words;
{
    self = [super init];
    if (self) {
        self.twitter = twitter;
        self.creator = creator;
        self.attendees = attendees;
        self.words = words;
    }
    return self;
}

#pragma mark Firebase Protocol methods

- (id)initWithDictionary:(NSDictionary *)dict;
{
    NSDictionary *twitter = [dict objectForKey:@"twitter"];
    NSString *creator = [dict objectForKey:@"creator"];
    NSMutableArray *attendees = [dict objectForKey:@"attendees"];
    NSMutableArray *words = [dict objectForKey:@"words"];
    return [self initWithTwitter:twitter andCreator:creator andAttendees:attendees andWords:words];
}


- (NSDictionary *)toDictionary;
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.twitter forKey:@"twitter"];
    [dict setObject:self.creator forKey:@"creator"];
    [dict setObject:self.attendees forKey:@"attendees"];
    [dict setObject:self.words forKey:@"words"];
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

// Dictionary contents may change?
- (BOOL)isEqualToConference:(FBZConference *)conference {
    if (self == conference)
        return YES;
    if (!([self.twitter isEqualToDictionary:conference.twitter]))
        return NO;
    return YES;
}


@end
