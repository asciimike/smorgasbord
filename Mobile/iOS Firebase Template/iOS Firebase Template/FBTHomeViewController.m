//
//  FBTHomeViewController.m
//  iOS Firebase Template
//
//  Created by Michael McDonald on 4/17/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FBTHomeViewController.h"
#import "FBTAuthenticationViewController.h"
#import "FBTUser.h"
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>

@interface FBTHomeViewController ()

@end

@implementation FBTHomeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.mutableUsers = [[NSMutableArray alloc] init];
//        self.user = [[FAUser alloc] init];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"Online Users";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign in" style:UIBarButtonItemStylePlain target:self action:@selector(authenticate)];
    
    Firebase *isConnectedRef = [[Firebase alloc] initWithUrl:@"http://iostemplate.firebaseio.com/.info/connected"];
    [isConnectedRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (![snapshot.value boolValue]) {
            self.navigationItem.rightBarButtonItem.title = @"Sign in";
        }
    }];
    
    Firebase *isAuthenticatedRef = [[Firebase alloc] initWithUrl:@"http://iostemplate.firebaseio.com/.info/authenticated"];
    [isAuthenticatedRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if ([snapshot.value boolValue]) {
            self.navigationItem.rightBarButtonItem.title = @"Sign out";
        } else {
            self.navigationItem.rightBarButtonItem.title = @"Sign in";
        }
    }];
    
    Firebase *connectionRef = [[Firebase alloc] initWithUrl:@"http://iostemplate.firebaseio.com/connections"];
    
    // Fires off any time a user signs in (or reconnects)
    [connectionRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        Firebase *userRef = [[[Firebase alloc] initWithUrl:@"http://iostemplate.firebaseio.com/users"] childByAppendingPath:snapshot.name];
        [userRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            NSDictionary *msgData = snapshot.value;
            FBTUser *newUser = [[FBTUser alloc] initWithDictionary:msgData];
            newUser.uid = snapshot.name;
            [self.mutableUsers addObject:newUser];
            [self.tableView reloadData];
        }];
    }];
    
    // Fires off any time a user signs out (or disconnects)
    [connectionRef observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        Firebase *userRef = [[[Firebase alloc] initWithUrl:@"http://iostemplate.firebaseio.com/users"] childByAppendingPath:snapshot.name];
        [userRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            NSDictionary *msgData = snapshot.value;
            FBTUser *newUser = [[FBTUser alloc] initWithDictionary:msgData];
            newUser.uid = snapshot.name;
            [self.mutableUsers removeObject:newUser];
            [self.tableView reloadData];
        }];

    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Firebase callbacks

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.mutableUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    FBTUser *currentUser = [self.mutableUsers objectAtIndex:indexPath.row];
    cell.textLabel.text = currentUser.username;
    
    // Configure the cell...
    
    return cell;
}

- (void) authenticate;
{
    Firebase *ref = [[Firebase alloc] initWithUrl:@"http://iostemplate.firebaseio.com"];
    FirebaseSimpleLogin *authRef = [[FirebaseSimpleLogin alloc] initWithRef:ref];
    [authRef checkAuthStatusWithBlock:^(NSError *error, FAUser *user) {
        if (error != nil) {
            // Problem authenticating
        } else if (user == nil) {
            // No user logged in, so log in
            FBTAuthenticationViewController *loginController = [[FBTAuthenticationViewController alloc] init];
            loginController.modalPresentationStyle = UIModalPresentationFullScreen;
            loginController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentViewController:loginController animated:YES completion:nil];
        } else {
            // User successfully logged in, so log them out
            Firebase *connectionRef = [[ref childByAppendingPath:@"connections"] childByAppendingPath:user.uid];
            [connectionRef removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
                if (error != nil) {
                    // Error!
                } else {
                    [authRef logout];
                }
            }];
        }
    }];
}

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

@end
