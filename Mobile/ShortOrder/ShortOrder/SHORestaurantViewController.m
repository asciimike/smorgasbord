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
#import "SHOReviewPickerModalViewController.h"

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
    
    self.tableView.tableHeaderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Separator.png"]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SHOReviewCell" bundle:nil] forCellReuseIdentifier:ReviewCellIdentifier];
    
    [self refreshData];
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
    
    cell.review = [self.restaurant.reviewList objectAtIndex:indexPath.row];
    
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

- (IBAction)worthItButtonPressed:(id)sender {
    [self launchReviewViewWasWorthIt:YES];
}

- (IBAction)noThanksButtonPressed:(id)sender {
    [self launchReviewViewWasWorthIt:NO];
}

- (void) launchReviewViewWasWorthIt:(BOOL)worthIt;
{
    // The much better modal view solution: looks and feels native
    SHOReviewPickerModalViewController *pickerController = [[SHOReviewPickerModalViewController alloc] init];
    pickerController.wasWorthIt = worthIt;
    pickerController.restaurant = self.restaurant;
    pickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    pickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:pickerController animated:YES completion:nil];
    
    /*
    // If you really want to run this code with my super shitty totally not native UI components (thanks OmniGraffle, no thanks CS degree)
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIView *coverView = [[UIView alloc] initWithFrame:screenRect];
    coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    [self.view addSubview:coverView];
    
    [UIView animateWithDuration:0.2 animations:^{
        UIView *latestView = [[self.view subviews] lastObject];
        latestView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }];
    
    
    UIView *reviewView = [[[NSBundle mainBundle] loadNibNamed:@"RestaurantReviewPickerView" owner:self options:nil] lastObject];
    reviewView.frame = CGRectMake(self.view.frame.size.width/2.0 - reviewView.frame.size.width/2.0, self.view.frame.size.height/2.0 - reviewView.frame.size.height/2.0, reviewView.frame.size.width, reviewView.frame.size.height);
    reviewView.alpha = 0;
    [self.view addSubview:reviewView];
    
    [UIView animateWithDuration:0.2 animations:^{
        UIView *latestView = [[self.view subviews] lastObject];
        latestView.alpha = 1.0;
    }];
     */
}

- (void) refreshData;
{
    [self.restaurant refreshData];
    
    [self setWaitTimeInMinutes:self.restaurant.waitTimeMinutes Hours:self.restaurant.waitTimeHours];
    
    self.worthItLabel.text = [NSString stringWithFormat:@"%d%%",[self.restaurant calculateWasWorthItPercent]];
    
    self.noThanksLabel.text = [NSString stringWithFormat:@"%d%%",[self.restaurant calculateWasNotWorthItPercent]];
    
    [self.tableView reloadData];
}


@end
