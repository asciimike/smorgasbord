//
//  SHORestaurantViewController.m
//  ShortOrder
//
//  Created by Michael McDonald on 2/3/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import "SHORestaurantViewController.h"
#import "SHOReviewCell.h"
#import "SHOReview.h"

#define SHORT_WAIT_TIME 5
#define MEDIUM_WAIT_TIME 10
#define LONG_WAIT_TIME 20

@interface SHORestaurantViewController ()

@end

@implementation SHORestaurantViewController

static NSString *ReviewCellIdentifier = @"ReviewCellIdentifier";

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
    
    self.title = self.restaurant.restaurantName;
    
    [self setWaitTimeInMinutes:self.restaurant.waitTimeMinutes Hours:self.restaurant.waitTimeHours];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SHOReviewCell" bundle:nil] forCellReuseIdentifier:ReviewCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.restaurant.reviewList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SHOReviewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ReviewCellIdentifier];
    
    SHOReview *currentReview = [self.restaurant.reviewList objectAtIndex:indexPath.row];
    
    cell.waitTimeLabel.text = [self formatWaitTimeMinutes:currentReview.waitTimeMinutes andHours:currentReview.waitTimeHours];
    
    return cell;
}

//TODO: Refactor to pull colors out to a plist (or at the very least a header file)
- (void)setWaitTimeInMinutes:(NSInteger)waitTimeMinutes Hours:(NSInteger)waitTimeHours;
{
    if (waitTimeHours > 0) {
        self.waitTimeLabel.text = [NSString stringWithFormat:@"%d+ hr", waitTimeHours];
        self.waitTimeLabel.textColor = [UIColor colorWithRed:0.8353 green:0.1294 blue:0.0863 alpha:1.0];
    } else {
        self.waitTimeLabel.text = [NSString stringWithFormat:@"%d min", waitTimeMinutes];
        if (waitTimeMinutes <= SHORT_WAIT_TIME) {
            self.waitTimeLabel.textColor = [UIColor colorWithRed:0.0902 green:0.6431 blue:0.1020 alpha:1.0];
        } else if (waitTimeMinutes <= MEDIUM_WAIT_TIME) {
            self.waitTimeLabel.textColor = [UIColor colorWithRed:0.9922 green:0.7020 blue:0.1686 alpha:1.0];
        } else if (waitTimeMinutes <= LONG_WAIT_TIME) {
            self.waitTimeLabel.textColor = [UIColor colorWithRed:0.9882 green:0.3882 blue:0.1255 alpha:1.0];
        } else if (waitTimeMinutes > LONG_WAIT_TIME) {
            self.waitTimeLabel.textColor = [UIColor colorWithRed:0.8353 green:0.1294 blue:0.0863 alpha:1.0];
        }
    }
}

- (NSString *)formatWaitTimeMinutes:(NSInteger)minutes andHours:(NSInteger)hours;
{
    if (hours > 0) {
        return [NSString stringWithFormat:@"%d hr %d min", hours, minutes];
    }
    
    return [NSString stringWithFormat:@"%d min", minutes];
}

@end
