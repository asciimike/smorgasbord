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
#import "SHOAddRestaurantViewController.h"

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
        self.restaurantList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SHORestaurantCell" bundle:nil] forCellReuseIdentifier:RestaurantCellIdentifier];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRestaurant)];
    
    self.title = [NSString stringWithFormat:@"Restaurants near %@", self.locationString];
    
    // TODO (UX): create the tab bar items for the actual values

    // Do any additional setup after loading the view from its nib.
    
//    [self setRestaurants];
    
    NSString *referenceURL = [NSString stringWithFormat:@"https://shortorder.firebaseio.com/restaurants/%@",self.locationString];
    Firebase *restaurantBase = [[Firebase alloc] initWithUrl:referenceURL];
        
    [restaurantBase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSDictionary *msgData = snapshot.value;
        SHORestaurant *currentRestaurant = [[SHORestaurant alloc] initWithDictionary:msgData];
        currentRestaurant.restaurantID = snapshot.name;
        [self.restaurantList addObject:currentRestaurant];
        [self.tableView reloadData];
    }];
    
    [restaurantBase observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        NSDictionary *msgData = snapshot.value;
        SHORestaurant *currentRestaurant = [[SHORestaurant alloc] initWithDictionary:msgData];
        currentRestaurant.restaurantID = snapshot.name;
        for (SHORestaurant *restaurant in self.restaurantList) {
            if ([currentRestaurant isEqual:restaurant]) {
                NSInteger location = [self.restaurantList indexOfObject:restaurant];
                [self.restaurantList replaceObjectAtIndex:location withObject:currentRestaurant];
                break;
            }
        }
        [self.tableView reloadData];
    }];
    
    [restaurantBase observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        NSDictionary *msgData = snapshot.value;
        SHORestaurant *currentRestaurant = [[SHORestaurant alloc] initWithDictionary:msgData];
        currentRestaurant.restaurantID = snapshot.name;
        for (SHORestaurant *restaurant in self.restaurantList) {
            if ([currentRestaurant isEqual:restaurant]) {
                [self.restaurantList removeObject:restaurant];
                break;
            }
        }
        [self.tableView reloadData];
    }];
    
    
    // Ensure that the tab bar is set up properly when entering the app
    UITabBarItem *firstItem = [[self.tabBar items] objectAtIndex:0];
    [self.tabBar.delegate tabBar:self.tabBar didSelectItem:firstItem];
    [self.tabBar setSelectedItem:firstItem];
    
}

- (void)viewWillAppear:(BOOL)animated;
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated;
{
    
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
    cell.restaurant = currentRestaurant;
    
    //cell.restaurantNameLabel.text = currentRestaurant.restaurantName;
    //[cell setWaitTimeInMinutes:currentRestaurant.waitTimeMinutes Hours:currentRestaurant.waitTimeHours];
    
    return cell;
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SHORestaurantViewController *restaurantViewController = [[SHORestaurantViewController alloc] initWithNibName:@"SHORestaurantViewController" bundle:nil];
    restaurantViewController.restaurant = [self.restaurantList objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:restaurantViewController animated:YES];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

# pragma mark - UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item;
{
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

- (void)addRestaurant;
{
    SHOAddRestaurantViewController *addRestaurantController = [[SHOAddRestaurantViewController alloc] init];
    addRestaurantController.modalPresentationStyle = UIModalPresentationFullScreen;
    addRestaurantController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:addRestaurantController animated:YES completion:nil];
    /*
    NSLog(@"Adding a new restaurant");
    Firebase *restaurantPushRef = [[[Firebase alloc] initWithUrl:@"https://shortorder.firebaseio.com/restaurants/"] childByAutoId];
    SHORestaurant *currentRestaurant = [self.restaurantList objectAtIndex:0];
    NSDictionary *currentDict = [currentRestaurant toDictionary];
    [restaurantPushRef setValue:currentDict];
     */
    
    // Pop up a box for the restaurant name
    
    // Take a picture
    
    // Go to the restaurant view
}



@end
