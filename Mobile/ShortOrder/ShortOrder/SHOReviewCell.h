//
//  SHOReviewCell.h
//  ShortOrder
//
//  Created by Michael McDonald on 2/4/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHOReview.h"

@interface SHOReviewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *waitTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (strong, nonatomic) IBOutlet UIImageView *ratingImage;
@property (strong, nonatomic) SHOReview *review;
@end
