//
//  FBZConferencesTableViewController.h
//  Buzzword
//
//  Created by Michael McDonald on 7/2/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBZConferencesTableViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *conferenceList;

@property (strong, nonatomic) UISearchBar *searchBar;

@end