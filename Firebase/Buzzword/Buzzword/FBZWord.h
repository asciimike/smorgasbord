//
//  FBZWord.h
//  Buzzword
//
//  Created by Michael McDonald on 7/3/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBZWord : NSObject

@property (strong, nonatomic) NSString *word;
@property NSInteger count;

- (id)initWithWord:(NSString *)word andCount:(NSInteger)count;

@end
