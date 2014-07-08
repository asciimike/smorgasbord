//
//  FBZWord.m
//  Buzzword
//
//  Created by Michael McDonald on 7/3/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FBZWord.h"

@implementation FBZWord

- (id)init
{
    return [self initWithWord:@"" andCount:0];
}

- (id)initWithWord:(NSString *)word andCount:(NSUInteger)count;
{
    self = [super init];
    if (self) {
        self.word = word;
        self.count = count;
    }
    return self;
}

#pragma mark Override isEqual methods

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToWord:other];
}

- (BOOL)isEqualToWord:(FBZWord *)word {
    if (self == word)
        return YES;
    if (!([self.word isEqualToString:word.word]))
        return NO;
    return YES;
}

@end
