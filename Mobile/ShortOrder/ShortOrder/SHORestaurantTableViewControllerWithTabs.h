//
//  SHORestaurantTableViewControllerWithTabs.h
//  ShortOrder
//
//  Created by Michael McDonald on 2/3/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHORestaurantTableViewControllerWithTabs : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITabBar *tabBar;

@end
