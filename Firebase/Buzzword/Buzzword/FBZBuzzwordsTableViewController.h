//
//  FBZBuzzwordsTableViewController.h
//  Buzzword
//
//  Created by Michael McDonald on 7/2/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FBZConference.h"

@interface FBZBuzzwordsTableViewController : UITableViewController

@property (strong, nonatomic)FBZConference *currentConference;
@property (strong, nonatomic)NSMutableArray *wordList;

@end
