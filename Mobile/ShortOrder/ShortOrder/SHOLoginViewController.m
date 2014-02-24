//
//  SHOLoginViewController.m
//  ShortOrder
//
//  Created by Michael McDonald on 2/11/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import "SHOLoginViewController.h"
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>

@interface SHOLoginViewController ()

@end

@implementation SHOLoginViewController

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
    Firebase *authRef = [[Firebase alloc] initWithUrl:@"https://shortorder.firebaseio.com"];
    FirebaseSimpleLogin *authClient = [[FirebaseSimpleLogin alloc] initWithRef:authRef];
    [authClient loginWithEmail:self.usernameTextField.text andPassword:self.passwordTextField.text withCompletionBlock:^(NSError *error, FAUser *user) {
        if (error != nil) {
            // There was an error creating the account
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed!" message:@"Please check your email and password, and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [self.loginActivityIndicator stopAnimating];
        } else {
            // We created a new user account
            NSLog(@"User %@ logged in", user);
            [self.loginActivityIndicator stopAnimating];
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }

    }];
}

- (IBAction)cancelButtonPressed:(id)sender;
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)registerButtonPressed:(id)sender;
{
    // Please, for the love of god, add some validity checking to these (at least the email address)
    Firebase *authRef = [[Firebase alloc] initWithUrl:@"https://shortorder.firebaseio.com"];
    FirebaseSimpleLogin *authClient = [[FirebaseSimpleLogin alloc] initWithRef:authRef];
    [authClient createUserWithEmail:self.usernameTextField.text password:self.passwordTextField.text
                 andCompletionBlock:^(NSError* error, FAUser* user) {
                     
                     if (error != nil) {
                         // There was an error creating the account
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed!" message:@"Please check your email and password, and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                         [alert show];
                     } else {
                         // We created a new user account
                         NSLog(@"New user %@ created", user);
                     }
                 }];
    
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.firebase.com"]]];
}

- (IBAction)backgroundTap:(id)sender;
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (IBAction)usernameDoneEditing:(id)sender;
{
//    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField becomeFirstResponder];
}

- (IBAction)passwordDoneEditing:(id)sender;
{
    [self.passwordTextField resignFirstResponder];
}

// TODO eliminate the magic numbers here (especially for iPhone 4's vs 5's
// Use the notification dicationary
# pragma mark - Keyboard will show/hide notifications to scroll the view properly
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
