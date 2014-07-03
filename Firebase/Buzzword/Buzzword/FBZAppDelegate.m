//
//  FBZAppDelegate.m
//  Buzzword
//
//  Created by Michael McDonald on 7/2/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FBZAppDelegate.h"
#import "FBZConferencesTableViewController.h"
#import "FBZBuzzwordsTableViewController.h"
#import "FBZLoginViewController.h"

#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>

@implementation FBZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    //Create conferences table view controller
    FBZConferencesTableViewController *conferencesViewController = [[FBZConferencesTableViewController alloc] init];
    conferencesViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Conferences" image:[UIImage imageNamed:@"office"] tag:0];
    UINavigationController *conferencesNavController = [[UINavigationController alloc] initWithRootViewController:conferencesViewController];
    
    //Create buzzwords view controller
    FBZBuzzwordsTableViewController *buzzwordsViewController = [[FBZBuzzwordsTableViewController alloc] init];
    buzzwordsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Trending Words" image:[UIImage imageNamed:@"bubble-quote"] tag:1];
    UINavigationController *buzzwordsNavController = [[UINavigationController alloc] initWithRootViewController:buzzwordsViewController];
    
    //Create bingo view controller
    UIViewController *bingoViewController = [[UIViewController alloc] init];
    bingoViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Buzzword Bingo" image:[UIImage imageNamed:@"grid3"] tag:2];
    UINavigationController *bingoNavController = [[UINavigationController alloc] initWithRootViewController:bingoViewController];
    
    //Create tab bar controller which is the app's root view controller
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[conferencesNavController, buzzwordsNavController, bingoNavController];
    self.window.rootViewController = tabBarController;
//    self.window.backgroundColor = [UIColor colorWithRed:0.0 green:(153.0/255.0) blue:(102.0/255.0) alpha:1.0];
    self.window.tintColor = [UIColor colorWithRed:0.0 green:(153.0/255.0) blue:(102.0/255.0) alpha:1.0];
    
    Firebase *ref = [[Firebase alloc] initWithUrl:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FBZFirebaseURL"]];
    FirebaseSimpleLogin *authClient = [[FirebaseSimpleLogin alloc] initWithRef:ref];
    [authClient checkAuthStatusWithBlock:^(NSError *error, FAUser *user) {
        if (error != nil) {
            // Oh no! There was an error performing the check
        } else if (user == nil) {
            // No user is logged in
            // Throw up the login screen
            FBZLoginViewController *loginController = [[FBZLoginViewController alloc] init];
            loginController.modalPresentationStyle = UIModalPresentationFullScreen;
            loginController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self.window.rootViewController presentViewController:loginController animated:YES completion:nil];
        } else {
            // There is a logged in user
            // Continue with the below
//            NSLog(@"User is currently logged in: %@", user.thirdPartyUserData);
        }
    }];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
