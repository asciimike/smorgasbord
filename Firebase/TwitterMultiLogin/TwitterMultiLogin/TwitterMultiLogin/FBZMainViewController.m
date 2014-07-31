//
//  FBZMainViewController.m
//  TwitterMultiLogin
//
//  Created by Michael McDonald on 7/30/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FBZMainViewController.h"

@interface FBZMainViewController ()

@end

@implementation FBZMainViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@""] style:UIBarButtonItemStylePlain target:self action:@selector(authenticateWithTwitter)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Auth" style:UIBarButtonItemStylePlain target:self action:@selector(authenticateWithTwitter)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"Logout"];
    
    return cell;
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentTwitterHandle) {
        Firebase *ref = [[Firebase alloc] initWithUrl:@"https://buzzword.firebaseio.com"];
        FirebaseSimpleLogin *authRef = [[FirebaseSimpleLogin alloc] initWithRef:ref];
        [authRef logout];
        self.currentTwitterHandle = nil;
        self.title = @"";
    }
}


- (void)authenticateWithTwitter;
{
    if (self.currentTwitterHandle) {
        // If the user has a currently selected twitter handle, log them in normally
        Firebase *ref = [[Firebase alloc] initWithUrl:@"https://buzzword.firebaseio.com"];
        FirebaseSimpleLogin *authRef = [[FirebaseSimpleLogin alloc] initWithRef:ref];
        [authRef loginToTwitterAppWithId:@"hcuKeaKLIGeBTZCtvf28iM2dE" multipleAccountsHandler:^int(NSArray *usernames) {
            return (int)[usernames indexOfObject:self.currentTwitterHandle];
        } withCompletionBlock:^(NSError *error, FAUser *user) {
            if (error != nil) {
                // An error has occurred!
            } else {
                // We have a user
                self.title = self.currentTwitterHandle;
            }
        }];
    } else {
        // Access account store to pull twitter accounts on device
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        activityIndicator.color = [UIColor blueColor];
        [self.view addSubview:activityIndicator];
        [activityIndicator startAnimating];
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if (granted) {
                NSArray *accounts = [accountStore accountsWithAccountType:accountType];
                [activityIndicator stopAnimating];
                [self handleMultipleTwitterAccounts:accounts];
            }
        }];
    }
}

- (void)handleMultipleTwitterAccounts:(NSArray *)accounts;
{
    switch ([accounts count]) {
        case 0:
            // Deal with setting up a twitter account (could also not be set up on the device, deal with this differently)
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/signup"]];
            break;
            
        case 1:
            // Single user system, go straight to login
            self.currentTwitterHandle = [[accounts firstObject] username];
            [self authenticateWithTwitter];
            break;
            
        default:
            // Handle multiple users
            [self selectTwitterAccount:accounts];
            break;
    }
}

- (void)selectTwitterAccount:(NSArray *)accounts;
{
    // Pop up action sheet which has different user accounts as options
    UIActionSheet *selectUserActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Twitter Account" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    for (ACAccount *account in accounts) {
        [selectUserActionSheet addButtonWithTitle:[account username]];
    }
    selectUserActionSheet.cancelButtonIndex = [selectUserActionSheet addButtonWithTitle:@"Cancel"];
    [selectUserActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    self.currentTwitterHandle = [actionSheet buttonTitleAtIndex:buttonIndex];
    [self authenticateWithTwitter];
}

@end
