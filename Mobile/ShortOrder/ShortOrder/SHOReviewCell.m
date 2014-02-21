//
//  SHOReviewCell.m
//  ShortOrder
//
//  Created by Michael McDonald on 2/4/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import "SHOReviewCell.h"

@implementation SHOReviewCell

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

- (void)setReview:(SHOReview *)newReview;
{
    _review = newReview;
    self.waitTimeLabel.text = [self formatWaitTimeMinutes:self.review.waitTimeMinutes andHours:self.review.waitTimeHours];
    self.timeStampLabel.text = [self getTimeStampString];
    self.ratingImage.image = self.review.wasWorthIt ? [UIImage imageNamed:@"WorthItButton.png"] : [UIImage imageNamed:@"NotWorthItButton.png"];
}

- (NSString *)formatWaitTimeMinutes:(NSInteger)minutes andHours:(NSInteger)hours;
{
    if (hours > 0) {
        return [NSString stringWithFormat:@"%d hr %d min", hours, minutes];
    }
    
    return [NSString stringWithFormat:@"%d min", minutes];
}

- (NSString *)getTimeStampString;
{
    NSTimeInterval difference = -[self.review.timestamp timeIntervalSinceNow];
    
    if (difference < 60) {
        return [NSString stringWithFormat:@"A moment ago"];
    } else if (difference < 60*60) {
        if (difference > 60 && difference < 120) {
            return [NSString stringWithFormat:@"1 minute ago"];
        }
        return [NSString stringWithFormat:@"%d minutes ago",((int)difference/(60))];
    } else if (difference < 60*60*24) {
        if (difference > 60*60 && difference < 60*60*2) {
            return [NSString stringWithFormat:@"1 hour ago"];
        }
        return [NSString stringWithFormat:@"%d hours ago",((int)difference/(60*60))];
    } else if (difference < 60*60*24*7){
        if (difference > 60*60*24 && difference < 60*60*24*2) {
            return [NSString stringWithFormat:@"1 day ago"];
        }
        return [NSString stringWithFormat:@"%d days ago",((int)difference/(60*60*24))];
    } else {
        return [NSString stringWithFormat:@"A while ago"];
    }
    
}

@end
