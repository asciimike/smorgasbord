//
//  FBZMessage.m
//  NotificationTest
//
//  Created by Michael McDonald on 9/2/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FBZMessage.h"

@implementation FBZMessage

- (id)init;
{
    return [self initWithId:@"" Author:@"" Data:@""];
}

- (id)initWithId:(NSString *)uid Author:(NSString *)author Data:(NSString *)data;
{
    self = [super init];
    if (self) {
        self.uid = uid;
        self.author = author;
        self.data = data;
        
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict;
{
    NSString *uid = [dict objectForKey:@"uid"];
    NSString *author = [dict objectForKey:@"author"];
    NSString *data = [dict objectForKey:@"data"];
    
    return [self initWithId:uid Author:author Data:data];
}

- (NSDictionary *)toDictionary;
{
    return [NSDictionary dictionaryWithObjects:@[self.author, self.data] forKeys:@[@"author", @"data"]];
}

@end
