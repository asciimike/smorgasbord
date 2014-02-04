//
//  SHORestaurantViewController.h
//  ShortOrder
//
//  Created by Michael McDonald on 2/3/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHORestaurantViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *waitTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *worthItLabel;

@property (strong, nonatomic) IBOutlet UILabel *noThanksLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
