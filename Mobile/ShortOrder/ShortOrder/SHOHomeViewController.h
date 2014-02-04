//
//  SHOHomeViewController.h
//  ShortOrder
//
//  Created by Michael McDonald on 2/3/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHOHomeViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *nearLabel;
@property (strong, nonatomic) IBOutlet UIImageView *nearImageView;
@property (strong, nonatomic) IBOutlet UILabel *searchLabel;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UIButton *searchGoButton;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;

- (IBAction)searchGoButtonPressed:(id)sender;
- (IBAction)signInButtonPressed:(id)sender;
- (IBAction)searchFieldPressedEnter:(id)sender;
- (IBAction)backgroundTap:(id)sender;

@end
