//
//  SHORestaurantTableViewControllerWithTabs.m
//  ShortOrder
//
//  Created by Michael McDonald on 2/3/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import "SHORestaurantTableViewControllerWithTabs.h"
#import "SHORestaurantCell.h"

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
    // Do any additional setup after loading the view from its nib.
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
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SHORestaurantCell *cell = [self.tableView dequeueReusableCellWithIdentifier:RestaurantCellIdentifier];
    
    return cell;
}




@end
