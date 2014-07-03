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

- (id)initWithWord:(NSString *)word andCount:(NSInteger)count;
{
    self = [super init];
    if (self) {
        self.word = word;
        self.count = count;
    }
    return self;
}

@end
