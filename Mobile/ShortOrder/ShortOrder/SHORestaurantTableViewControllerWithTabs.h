//
//  SHORestaurantTableViewControllerWithTabs.h
//  ShortOrder
//
//  Created by Michael McDonald on 2/3/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>


@interface SHORestaurantTableViewControllerWithTabs : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITabBar *tabBar;
@property (strong, nonatomic) NSMutableArray *restaurantList;
@property (strong, nonatomic) NSArray *displayArray;
@property enum tabState currentTabState;
@property (strong, nonatomic) NSString *locationString;

@end
