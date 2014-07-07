//
//  FBZConferencesTableViewController.h
//  Buzzword
//
//  Created by Michael McDonald on 7/2/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface FBZConferencesTableViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *conferenceList;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) ACAccountStore *accountStore;

@end
