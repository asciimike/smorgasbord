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
#import "SHOLoginViewController.h"

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
    #warning Use Firebase simple login (facebook) to log users in
    // Present a custom alert that asks the user to sign in (firebase simple login)
    
    SHOLoginViewController *loginController = [[SHOLoginViewController alloc] init];
    loginController.modalPresentationStyle = UIModalPresentationFullScreen;
    loginController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:loginController animated:YES completion:nil];
     
    
//    UIView *loginView = [[[NSBundle mainBundle] loadNibNamed:@"SHOLoginViewController" owner:self options:nil] objectAtIndex:0];
//    
//    [self.view addSubview:loginView];
    
    //Animate frame on screen
    
}

- (IBAction)searchFieldPressedEnter:(id)sender;
{
//    [sender resignFirstResponder];
    [self searchGoButtonPressed:self];
}

- (IBAction)backgroundTap:(id)sender;
{
    [self.searchTextField resignFirstResponder];
}

- (IBAction)searchGoButtonPressed:(id)sender {
    // Get user input to find out where we should be searching
    NSString *textBoxInput = self.searchTextField.text;
    [self switchToRestaurantListNearLocation:textBoxInput];
}

- (IBAction)nearButtonPressed:(id)sender {
    // Use gelocation to find out the area code near me
    [self switchToRestaurantListNearLocation:@"47803"];
}

- (void)switchToRestaurantListNearLocation:(NSString *)location;
{
    // Hide the keyboard if it's present
    if (self.searchTextField.isFirstResponder) {
        [self.searchTextField resignFirstResponder];
    }
    
    SHORestaurantTableViewControllerWithTabs *restaurantTableViewController = [[SHORestaurantTableViewControllerWithTabs alloc] initWithNibName:@"SHORestaurantTableViewControllerWithTabs" bundle:[NSBundle mainBundle]];
    
    if ([location isEqualToString:@""]) {
        // Must input valid things! Check here for validity...
    } else {
        NSString *locationString = [NSString stringWithFormat: @"Restaurants Near %@", location];
        restaurantTableViewController.title = locationString;
        [self.navigationController pushViewController:restaurantTableViewController animated:YES];
    }
}

// TODO eliminate the magic numbers here (especially for iPhone 4's vs 5's
// Use the notification dicationary
# pragma mark - Keyboard will show/hide notifications to scroll the view properly
- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setFrame:CGRectMake(0,-120,320,460)];
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setFrame:CGRectMake(0,0,320,460)];
    }];
}

@end
