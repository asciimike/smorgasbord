//
//  FBZLoginViewController.m
//  Buzzword
//
//  Created by Michael McDonald on 7/2/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FBZLoginViewController.h"

#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>

@interface FBZLoginViewController ()

@end

@implementation FBZLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginWithTwitter:(id)sender {
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://buzzword.firebaseio.com"];
    FirebaseSimpleLogin *authClient = [[FirebaseSimpleLogin alloc] initWithRef:ref];
    [authClient loginToTwitterAppWithId:@"hcuKeaKLIGeBTZCtvf28iM2dE"
                multipleAccountsHandler:^int(NSArray *usernames) {
                    // If you do not wish to authenticate with any of these usernames, return NSNotFound.
                    return NSNotFound;
//                    return [yourApp selectUserName:usernames]; //Change this to allow us to select from multiple accounts
                } withCompletionBlock:^(NSError *error, FAUser *user) {
                    if (error != nil) {
                        // There was an error authenticating
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed!" message:@"Twitter login failed, please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
                    } else {
                        // We have an authenticated Twitter user
                        Firebase *newUserRef = [[ref childByAppendingPath:@"users"] childByAppendingPath:user.uid];
                        [newUserRef setValue:user.thirdPartyUserData];
                    }
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
}

- (IBAction)loginWithFacebook:(id)sender {
    // Do something here, since currently we don't do anything.
}
@end
