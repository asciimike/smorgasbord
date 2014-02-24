//
//  SHORestaurantViewController.h
//  ShortOrder
//
//  Created by Michael McDonald on 2/3/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHORestaurant.h"

@interface SHORestaurantViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *waitTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *worthItLabel;
@property (strong, nonatomic) IBOutlet UILabel *noThanksLabel;
@property (strong, nonatomic) IBOutlet UIButton *worthItButton;
@property (strong, nonatomic) IBOutlet UIButton *noThanksButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SHORestaurant *restaurant;
@property (strong, nonatomic) NSMutableArray *reviews;

- (IBAction)worthItButtonPressed:(id)sender;
- (IBAction)noThanksButtonPressed:(id)sender;
- (void) refreshData;

@end
