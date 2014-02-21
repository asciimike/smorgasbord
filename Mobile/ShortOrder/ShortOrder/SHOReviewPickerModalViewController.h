//
//  SHOReviewPickerModalViewController.h
//  ShortOrder
//
//  Created by Michael McDonald on 2/20/14.
//  Copyright (c) 2014 Michael McDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHORestaurant.h"

@interface SHOReviewPickerModalViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIDatePicker *waitTimePicker;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic) BOOL wasWorthIt;
@property (strong, nonatomic) SHORestaurant *restaurant;

- (IBAction)submitButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end
