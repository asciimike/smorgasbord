//
//  FBTAuthenticationViewController.m
//  iOS Firebase Template
//
//  Created by Michael McDonald on 4/17/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FBTAuthenticationViewController.h"
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>
#import "FBTUser.h"

@interface FBTAuthenticationViewController ()

@end

@implementation FBTAuthenticationViewController

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

- (IBAction)signInButtonPressed:(id)sender;
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.loginActivityIndicator startAnimating];
    
    Firebase *authRef = [[Firebase alloc] initWithUrl:@"https://iostemplate.firebaseio.com"];
    FirebaseSimpleLogin *authClient = [[FirebaseSimpleLogin alloc] initWithRef:authRef];
    [authClient loginWithEmail:self.usernameTextField.text andPassword:self.passwordTextField.text withCompletionBlock:^(NSError *error, FAUser *user) {
        if (error != nil) {
            // Error, error
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed!" message:@"Please check your email and password, and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else if (user == nil) {
            //
        } else {
            Firebase *connectedRef = [[authRef childByAppendingPath:@"connections"] childByAppendingPath:user.uid];
            [connectedRef setValue:@YES];
            [connectedRef onDisconnectRemoveValue];
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
        [self.loginActivityIndicator stopAnimating];
    }];
}

- (IBAction)cancelButtonPressed:(id)sender;
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)registerButtonPressed:(id)sender;
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.loginActivityIndicator startAnimating];
    
    Firebase *authRef = [[Firebase alloc] initWithUrl:@"https://iostemplate.firebaseio.com"];
    Firebase *userRef = [authRef childByAppendingPath:@"users"];
    FirebaseSimpleLogin *authClient = [[FirebaseSimpleLogin alloc] initWithRef:authRef];
    [authClient createUserWithEmail:self.usernameTextField.text password:self.passwordTextField.text
                 andCompletionBlock:^(NSError* error, FAUser* user) {
                     if (error != nil) {
                         // There was an error creating the account
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed!" message:@"Please check your email and password, and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                         [alert show];
                         [self.loginActivityIndicator stopAnimating];
                     } else {
                         // We created a new user account
                         Firebase *newUserRef = [userRef childByAppendingPath:user.uid];
                         FBTUser *newUser = [[FBTUser alloc] initWithUsername:user.email];
                         [newUserRef setValue:[newUser toDictionary]];
                         [self.loginActivityIndicator stopAnimating];
                         [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                     }
                 }];

}

- (IBAction)backgroundTap:(id)sender;
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (IBAction)usernameDoneEditing:(id)sender;
{
    [self.passwordTextField becomeFirstResponder];
}

- (IBAction)passwordDoneEditing:(id)sender;
{
    [self.passwordTextField resignFirstResponder];
}

# pragma mark - Keyboard will show/hide notifications to scroll the view properly
- (void)viewWillAppear:(BOOL)animated;
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setFrame:CGRectMake(0,-30,320,460)];
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setFrame:CGRectMake(0,0,320,460)];
    }];
}

@end
