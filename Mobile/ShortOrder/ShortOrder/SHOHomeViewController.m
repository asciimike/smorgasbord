//
//  SHOHomeViewController.m
//  ShortOrder
//
//  Created by Michael McDonald on 2/3/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import "SHOHomeViewController.h"
#import "SHORestaurantTableViewController.h"
#import "SHORestaurantTableViewControllerWithTabs.h"

@interface SHOHomeViewController ()

@end

@implementation SHOHomeViewController

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
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated;
{
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.title = @"Home";
    self.searchTextField.text = @"";
    self.searchTextField.placeholder = @"City or Zip Code";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchGoButtonPressed:(id)sender {
    // Go to the restaurant list view
//    SHORestaurantTableViewController *restaurantTableViewController = [[SHORestaurantTableViewController alloc] initWithNibName:@"SHORestaurantTableViewController" bundle:[NSBundle mainBundle]];
    SHORestaurantTableViewControllerWithTabs *restaurantTableViewController = [[SHORestaurantTableViewControllerWithTabs alloc] initWithNibName:@"SHORestaurantTableViewControllerWithTabs" bundle:[NSBundle mainBundle]];
    NSString *textBoxInput = self.searchTextField.text;
    if ([textBoxInput isEqualToString:@""]) {
        // Must input valid things! Check here for validity...
    } else {
        NSString *locationString = [NSString stringWithFormat: @"Restaurants Near %@", textBoxInput];
        restaurantTableViewController.title = locationString;
        [self.navigationController pushViewController:restaurantTableViewController animated:YES];
    }
}

- (IBAction)signInButtonPressed:(id)sender;
{
    // Present a custom alert that asks the user to sign in
}

- (IBAction)searchFieldPressedEnter:(id)sender;
{
    [sender resignFirstResponder];
}

- (IBAction)backgroundTap:(id)sender;
{
    [self.searchTextField resignFirstResponder];
}
@end
