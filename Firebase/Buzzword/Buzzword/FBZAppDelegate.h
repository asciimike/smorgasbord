//
//  FBZAppDelegate.h
//  Buzzword
//
//  Created by Michael McDonald on 7/2/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>

#import "FBZConference.h"

@interface FBZAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FAUser *currentUser;
@property (strong, nonatomic) FBZConference *currentConference;

- (void)logout;
- (FAUser *)getCurrentUser;
- (FBZConference *)getCurrentConference;

@end
