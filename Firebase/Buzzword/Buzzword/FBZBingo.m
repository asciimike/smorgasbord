//
//  FBZBingo.m
//  Buzzword
//
//  Created by Michael McDonald on 7/8/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FBZBingo.h"

@implementation FBZBingo

- (id)init
{
    return [self initWithConference:[[FBZConference alloc] init]];
}

- (id)initWithConference:(FBZConference *)conference;
{
    self = [super init];
    if (self) {
        self.currentConference = conference;
        self.words = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)startGame;
{
    NSMutableArray *availableWords = self.currentConference.words;
    for (NSInteger i = 0; i < 9; i++) {
        NSInteger rand = arc4random_uniform([availableWords count] - (i - 1));
//        FBZWord
        
    }
}

//- (BOOL)checkBoard;
//{
//    
//}

@end
