//
//  SHOHomeViewController.h
//  ShortOrder
//
//  Created by Michael McDonald on 2/3/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface SHOHomeViewController : UIViewController <CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *nearLabel;
@property (strong, nonatomic) IBOutlet UIButton *nearButton;
@property (strong, nonatomic) IBOutlet UILabel *searchLabel;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UIButton *searchGoButton;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

- (IBAction)signInButtonPressed:(id)sender;
- (IBAction)searchFieldPressedEnter:(id)sender;
- (IBAction)backgroundTap:(id)sender;
- (IBAction)searchGoButtonPressed:(id)sender;
- (IBAction)nearButtonPressed:(id)sender;

@end
