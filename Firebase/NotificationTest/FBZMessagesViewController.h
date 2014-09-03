//
//  FBZMessagesViewController.h
//  NotificationTest
//
//  Created by Michael McDonald on 9/2/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>

@interface FBZMessagesViewController : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *messagesArray;

@end
