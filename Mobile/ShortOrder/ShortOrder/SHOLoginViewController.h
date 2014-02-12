//
//  SHOLoginViewController.h
//  ShortOrder
//
//  Created by Michael McDonald on 2/11/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol LoginControllerDelegate
//@required
//- (BOOL) loginCompleted;
//- (void) cancelPressed;
//- (void) registerPressed;
//@end

@interface SHOLoginViewController : UIViewController

//@property (weak, nonatomic) id <LoginControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loginActivityIndicator;

- (IBAction)signInButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)registerButtonPressed:(id)sender;
- (IBAction)backgroundTap:(id)sender;
- (IBAction)usernameDoneEditing:(id)sender;
- (IBAction)passwordDoneEditing:(id)sender;

@end
