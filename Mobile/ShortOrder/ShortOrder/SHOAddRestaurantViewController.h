//
//  SHOAddRestaurantViewController.h
//  ShortOrder
//
//  Created by Michael McDonald on 2/23/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface SHOAddRestaurantViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *restaurantImageView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UITextField *restaurantNameTextField;
@property (strong, nonatomic) IBOutlet UIButton *createRestaurantButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLPlacemark *currentPlacemark;

- (IBAction)createButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end
