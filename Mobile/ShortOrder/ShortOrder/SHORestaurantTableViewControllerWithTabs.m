//
//  SHORestaurantTableViewControllerWithTabs.m
//  ShortOrder
//
//  Created by Michael McDonald on 2/3/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import "SHORestaurantTableViewControllerWithTabs.h"
#import "SHORestaurantCell.h"
#import "SHORestaurantViewController.h"
#import "SHORestaurant.h"
#import "SHOReview.h"

enum tabState {WAIT_TIME_TAB, FAVORITES_TAB, RECENTS_TAB};

@interface SHORestaurantTableViewControllerWithTabs ()

@end

@implementation SHORestaurantTableViewControllerWithTabs

static NSString *RestaurantCellIdentifier = @"RestaurantCellIdentifier";

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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SHORestaurantCell" bundle:nil] forCellReuseIdentifier:RestaurantCellIdentifier];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
    
    // TODO (UX): create the tab bar items for the actual values

    // Do any additional setup after loading the view from its nib.
    
    [self setRestaurants];
    
    // Ensure that the tab bar is set up properly when entering the app
    UITabBarItem *firstItem = [[self.tabBar items] objectAtIndex:0];
    [self.tabBar.delegate tabBar:self.tabBar didSelectItem:firstItem];
    [self.tabBar setSelectedItem:firstItem];
    
}

- (void)viewWillAppear:(BOOL)animated;
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.restaurantList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SHORestaurantCell *cell = [self.tableView dequeueReusableCellWithIdentifier:RestaurantCellIdentifier];
    
    SHORestaurant *currentRestaurant = [self.restaurantList objectAtIndex:indexPath.row];
    
    cell.restaurantNameLabel.text = currentRestaurant.restaurantName;
    [cell setWaitTimeInMinutes:currentRestaurant.waitTimeMinutes Hours:currentRestaurant.waitTimeHours];
    
    return cell;
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SHORestaurantViewController *restaurantViewController = [[SHORestaurantViewController alloc] initWithNibName:@"SHORestaurantViewController" bundle:nil];
    restaurantViewController.restaurant = [self.restaurantList objectAtIndex:indexPath.row];
    restaurantViewController.restaurant.reviewList = [[NSMutableArray alloc] initWithObjects:[[SHOReview alloc] initWithWaitTimeMinutes:10 andHours:0 wasWorthIt:YES atDate:[NSDate date]],
                                                      [[SHOReview alloc] initWithWaitTimeMinutes:5 andHours:0 wasWorthIt:YES atDate:[NSDate date]], nil];
    
    [self.navigationController pushViewController:restaurantViewController animated:YES];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

# pragma mark - UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item;
{
    // Reset restaurants (for testing)
    [self setRestaurants];
    
    switch (item.tag) {
        case WAIT_TIME_TAB:
        {
            self.currentTabState = WAIT_TIME_TAB;
            NSSortDescriptor *hoursDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"waitTimeHours" ascending:YES];
            NSSortDescriptor *minutesDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"waitTimeMinutes" ascending:YES];
            self.restaurantList = [[self.restaurantList sortedArrayUsingDescriptors:@[hoursDescriptor,minutesDescriptor]] mutableCopy];
        }
            break;
        
        case FAVORITES_TAB:
        {
            self.currentTabState = FAVORITES_TAB;
            NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"restaurantName" ascending:YES];
            NSPredicate *isFavoritePredicate = [NSPredicate predicateWithFormat:@"isFavorite == 1"];
            self.restaurantList = [[self.restaurantList filteredArrayUsingPredicate:isFavoritePredicate] mutableCopy];
            self.restaurantList = [[self.restaurantList sortedArrayUsingDescriptors:@[nameDescriptor]] mutableCopy];
        }
            break;
        
        case RECENTS_TAB:
        {
            self.currentTabState = RECENTS_TAB;
            // TODO:
            // Use a predicate for "recent"
            // Sort by most recent first
        }
            break;
            
        default:
            break;
    }
    
    // TODO: How do we animate?
    [self.tableView reloadData];
}

- (void) setRestaurants;
{
    // Here is where we would create a firebase reference, pull in the dictionary, parse into restaurant objects, then create the mutable array, all on a background thread
    self.restaurantList = [[NSMutableArray alloc] initWithObjects:
    [[SHORestaurant alloc] initWithName:@"Chavas" waitInMinutes:5 andHours:0 isFavorite:YES],
    [[SHORestaurant alloc] initWithName:@"Royal Mandarin" waitInMinutes:10 andHours:0 isFavorite:NO],
    [[SHORestaurant alloc] initWithName:@"Real Hacienda" waitInMinutes:17 andHours:0 isFavorite:NO],
    [[SHORestaurant alloc] initWithName:@"Moggers" waitInMinutes:20 andHours:0 isFavorite:YES],
    [[SHORestaurant alloc] initWithName:@"Stables" waitInMinutes:5 andHours:1 isFavorite:YES],
    [[SHORestaurant alloc] initWithName:@"IHOP" waitInMinutes:3 andHours:0 isFavorite:NO],
    [[SHORestaurant alloc] initWithName:@"Outback Steakhouse" waitInMinutes:34 andHours:0 isFavorite:NO],
    [[SHORestaurant alloc] initWithName:@"Buffalo Wild Wings" waitInMinutes:10 andHours:0 isFavorite:NO],
    [[SHORestaurant alloc] initWithName:@"Magdy's" waitInMinutes:2 andHours:0 isFavorite:YES],
    [[SHORestaurant alloc] initWithName:@"Chez Panise" waitInMinutes:10 andHours:2 isFavorite:YES],
    [[SHORestaurant alloc] initWithName:@"Venizie" waitInMinutes:27 andHours:0 isFavorite:NO],
    [[SHORestaurant alloc] initWithName:@"Taj Mahal" waitInMinutes:14 andHours:0 isFavorite:YES],
    [[SHORestaurant alloc] initWithName:@"TGI Friday's" waitInMinutes:42 andHours:0 isFavorite:NO],
    nil];
}



@end
