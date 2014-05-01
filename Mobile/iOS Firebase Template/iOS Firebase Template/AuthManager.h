//
//  AuthManager.h
//  iOS Firebase Template
//
//  Created by Michael McDonald on 4/22/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>

@interface AuthManager : NSObject

@property (strong, nonatomic) FAUser *user;
@property (strong, nonatomic) FirebaseSimpleLogin *authClient;
@property (strong, nonatomic) NSString *currentConnection;

+ (id)sharedManager;
- (id)init;
- (void)dealloc;
- (void)loginWithEmail:(NSString *)email andPassword:(NSString *)password;
- (void)logout;

@end
