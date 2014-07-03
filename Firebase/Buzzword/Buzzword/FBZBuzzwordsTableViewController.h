//
//  FBZBuzzwordsTableViewController.h
//  Buzzword
//
//  Created by Michael McDonald on 7/2/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBZBuzzwordsTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutlet UITextField *wordInput;
@property (strong, nonatomic) IBOutlet UIButton *addWordButton;

- (IBAction)addWordPressed:(id)sender;

@end
