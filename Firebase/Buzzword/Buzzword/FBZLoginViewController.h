//
//  FBZLoginViewController.h
//  Buzzword
//
//  Created by Michael McDonald on 7/2/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBZLoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *twitterLoginButton;
@property (strong, nonatomic) IBOutlet UIButton *facebookLoginButton;

- (IBAction)loginWithTwitter:(id)sender;
- (IBAction)loginWithFacebook:(id)sender;


@end
