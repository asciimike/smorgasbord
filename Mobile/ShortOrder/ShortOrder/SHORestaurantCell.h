//
//  SHORestaurantCell.h
//  ShortOrder
//
//  Created by Michael McDonald on 2/3/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHORestaurant.h"

@interface SHORestaurantCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *restaurantImageView;
@property (strong, nonatomic) IBOutlet UILabel *restaurantNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentWaitLabel;

@property (strong, nonatomic) SHORestaurant *restaurant;

- (void)setWaitTimeInMinutes:(NSInteger)waitTimeMinutes Hours:(NSInteger)waitTimeHours;

@end
