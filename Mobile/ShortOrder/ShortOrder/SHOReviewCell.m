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
//    self.ratingImage.image = self.review.wasWorthIt ? : ;
}

- (NSString *)formatWaitTimeMinutes:(NSInteger)minutes andHours:(NSInteger)hours;
{
    if (hours > 0) {
        return [NSString stringWithFormat:@"%d hr %d min", hours, minutes];
    }
    
    return [NSString stringWithFormat:@"%d min", minutes];
}

@end
