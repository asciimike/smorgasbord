//
//  FBZMainViewController.h
//  TwitterMultiLogin
//
//  Created by Michael McDonald on 7/30/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>

@interface FBZMainViewController : UITableViewController <UIActionSheetDelegate>

@property (strong, nonatomic) NSString *currentTwitterHandle;
@end
