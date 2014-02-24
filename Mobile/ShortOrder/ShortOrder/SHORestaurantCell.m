//
//  SHORestaurantCell.m
//  ShortOrder
//
//  Created by Michael McDonald on 2/3/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import "SHORestaurantCell.h"
#define SHORT_WAIT_TIME 5
#define MEDIUM_WAIT_TIME 10
#define LONG_WAIT_TIME 20

@implementation SHORestaurantCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRestaurant:(SHORestaurant *)restaurant;
{
    _restaurant = restaurant;
    self.restaurantNameLabel.text = _restaurant.restaurantName;
    [self setWaitTimeInMinutes:_restaurant.waitTimeMinutes Hours:_restaurant.waitTimeHours];
}

//TODO: Refactor to pull colors out to a plist (or at the very least a header file)
- (void)setWaitTimeInMinutes:(NSInteger)waitTimeMinutes Hours:(NSInteger)waitTimeHours;
{
    if (waitTimeHours > 0) {
        self.currentWaitLabel.text = [NSString stringWithFormat:@"%d hr %d min", waitTimeHours, waitTimeMinutes];
        self.currentWaitLabel.textColor = [UIColor colorWithRed:0.8353 green:0.1294 blue:0.0863 alpha:1.0];
    } else {
        self.currentWaitLabel.text = [NSString stringWithFormat:@"%d min", waitTimeMinutes];
        if (waitTimeMinutes <= SHORT_WAIT_TIME) {
            self.currentWaitLabel.textColor = [UIColor colorWithRed:0.0902 green:0.6431 blue:0.1020 alpha:1.0];
        } else if (waitTimeMinutes <= MEDIUM_WAIT_TIME) {
            self.currentWaitLabel.textColor = [UIColor colorWithRed:0.9922 green:0.7020 blue:0.1686 alpha:1.0];
        } else if (waitTimeMinutes <= LONG_WAIT_TIME) {
            self.currentWaitLabel.textColor = [UIColor colorWithRed:0.9882 green:0.3882 blue:0.1255 alpha:1.0];
        } else if (waitTimeMinutes > LONG_WAIT_TIME) {
            self.currentWaitLabel.textColor = [UIColor colorWithRed:0.8353 green:0.1294 blue:0.0863 alpha:1.0];
        }
    }
}

@end
