//
//  FBZBingo.h
//  Buzzword
//
//  Created by Michael McDonald on 7/8/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>

#import "FBZConference.h"

@interface FBZBingo : NSObject

@property (strong, nonatomic)FBZConference *currentConference;
@property (strong, nonatomic)NSMutableDictionary *words;
//@property (strong, nonatomic)FAUser *winningUser;

@end
