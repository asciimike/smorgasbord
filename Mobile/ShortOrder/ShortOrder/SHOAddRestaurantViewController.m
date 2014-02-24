//
//  SHOAddRestaurantViewController.m
//  ShortOrder
//
//  Created by Michael McDonald on 2/23/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import <Firebase/Firebase.h>
#import "SHOAddRestaurantViewController.h"
#import "SHORestaurant.h"
#import "SHORestaurantViewController.h"

@interface SHOAddRestaurantViewController ()

@end

@implementation SHOAddRestaurantViewController

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
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    [self.locationManager startUpdatingLocation];
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

- (IBAction)createButtonPressed:(id)sender {
    if (![self.restaurantNameTextField.text isEqualToString:@""]) {
        NSString *referenceURL = [NSString stringWithFormat:@"https://shortorder.firebaseio.com/restaurants/%@", self.currentPlacemark.postalCode];
        Firebase *restaurantPushRef = [[[Firebase alloc] initWithUrl:referenceURL] childByAutoId];
        SHORestaurant *currentRestaurant = [[SHORestaurant alloc] initWithName:self.restaurantNameTextField.text isFavorite:NO];
        currentRestaurant.location = self.currentLocation;
        currentRestaurant.postalCode = self.currentPlacemark.postalCode;
        NSDictionary *currentDict = [currentRestaurant toDictionary];
        [restaurantPushRef setValue:currentDict];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            // This completion block doesn't work... don't use it (we need a better way... delegate method likely)
            SHORestaurantViewController *restaurantViewController = [[SHORestaurantViewController alloc] init];
            restaurantViewController.restaurant = currentRestaurant;
            [(UINavigationController *)self.presentingViewController pushViewController:restaurantViewController animated:YES];
        }];
    }
    [self.restaurantNameTextField resignFirstResponder];
    
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.restaurantNameTextField resignFirstResponder];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

// TODO eliminate the magic numbers here (especially for iPhone 4's vs 5's
// Use the notification dicationary
# pragma mark - Keyboard will show/hide notifications to scroll the view properly
- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setFrame:CGRectMake(0,-100,320,460)];
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setFrame:CGRectMake(0,0,320,460)];
    }];
}

#pragma mark - CLLocationManager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;
{
    self.currentLocation = [locations lastObject];
    NSLog(@"Lat: %.8f, Lon: %.8f",self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    [self.locationManager stopUpdatingLocation];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            self.currentPlacemark = [placemarks lastObject];
            self.locationLabel.text = [NSString stringWithFormat:@"%@ \n%@, %@ %@", self.currentPlacemark.name, self.currentPlacemark.locality, self.currentPlacemark.administrativeArea, self.currentPlacemark.postalCode];
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Failure" message:@"Location failed to find" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [alertView show];
}
@end
