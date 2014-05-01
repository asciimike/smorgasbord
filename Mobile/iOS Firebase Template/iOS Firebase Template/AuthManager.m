//
//  AuthManager.m
//  iOS Firebase Template
//
//  Created by Michael McDonald on 4/22/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "AuthManager.h"


@implementation AuthManager

+ (id)sharedManager;
{
    static AuthManager *sharedAuthManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAuthManager = [[self alloc] init];
    });
    return sharedAuthManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.user = nil;
        Firebase *ref = [[Firebase alloc] initWithUrl:@"https://iostemplate.firebaseio.com"];
        self.authClient = [[FirebaseSimpleLogin alloc] initWithRef:ref];
        self.currentConnection = nil;
    }
    return self;
}

- (void)loginWithEmail:(NSString *)email andPassword:(NSString *)password;
{

}

- (void)logout;
{
    NSString *path = [NSString stringWithFormat:@"https://iostemplate.firebaseio.com/users/%@/connections/%@", self.user.uid, self.currentConnection];
    Firebase *connectionRef = [[Firebase alloc] initWithUrl:path];
    [connectionRef removeValue];
    self.user = nil;
    self.currentConnection = nil;
    [self.authClient logout];
}

- (void)dealloc
{
    self.user = nil;
    self.currentConnection = nil;
    self.authClient = nil;
}

@end
