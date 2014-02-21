//
//  SHOReviewPickerModalViewController.m
//  ShortOrder
//
//  Created by Michael McDonald on 2/20/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import "SHOReviewPickerModalViewController.h"
#import "SHORestaurantViewController.h"
#import "SHOReview.h"

@interface SHOReviewPickerModalViewController ()

@end

@implementation SHOReviewPickerModalViewController

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
    self.waitTimePicker.countDownDuration = 60;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitButtonPressed:(id)sender {
    // Create a new review and add it to the previous restaurant
    NSInteger totalTimeInSeconds = self.waitTimePicker.countDownDuration;
    NSInteger totalTimeInMinutes = totalTimeInSeconds / 60;
    NSInteger waitTimeHours = totalTimeInMinutes / 60;
    NSInteger waitTimeMinutes = totalTimeInMinutes % 60;
    SHOReview *newReview = [[SHOReview alloc] initWithWaitTimeMinutes:waitTimeMinutes andHours:waitTimeHours wasWorthIt:self.wasWorthIt atDate:[NSDate date]];
    [self.restaurant.reviewList addObject:newReview];
    
    SHORestaurantViewController *restaurantViewController = (SHORestaurantViewController *)[[(UINavigationController *)self.presentingViewController viewControllers] lastObject];
    [restaurantViewController refreshData];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
