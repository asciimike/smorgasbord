//
//  FBZConferencesTableViewController.m
//  Buzzword
//
//  Created by Michael McDonald on 7/2/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FBZConferencesTableViewController.h"
#import "FBZConference.h"
#import "FBZAppDelegate.h"
#import "FBZAttendeesTableViewController.h"

@interface FBZConferencesTableViewController ()

@end

@implementation FBZConferencesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.conferenceList = [[NSMutableArray alloc] init];
        self.filteredConferenceList = [[NSMutableArray alloc] init];
        self.accountStore = [[ACAccountStore alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;

    self.title = @"Conferences";
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0.0 green:(153.0/255.0) blue:(102.0/255.0) alpha:1.0], NSForegroundColorAttributeName, [UIColor colorWithRed:0.0 green:(153.0/255.0) blue:(102.0/255.0) alpha:1.0], NSBackgroundColorAttributeName, nil];

    self.searchDisplayController.searchBar.barTintColor = [UIColor colorWithRed:0.0 green:(153.0/255.0) blue:(102.0/255.0) alpha:0.25];
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addConference)];
    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"exit3"] style:UIBarButtonItemStylePlain target:[[UIApplication sharedApplication] delegate] action:@selector(logout)];
    self.navigationItem.rightBarButtonItems = @[logoutItem, addItem];
    
    [self initFirebaseCallbacks];
}

- (void)viewWillAppear:(BOOL)animated;
{
    // Nil out current conference, since no conference is selected
    FBZAppDelegate *delegate = (FBZAppDelegate *)[[UIApplication sharedApplication] delegate];
    FBZConference *currentConference = [delegate getCurrentConference];
    
    if (currentConference) {
        NSString *screenName = [NSString stringWithFormat:@"@%@", [currentConference.twitter objectForKey:@"screen_name"]];
        Firebase *ref = [[[[[[Firebase alloc] initWithUrl:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FBZFirebaseURL"]] childByAppendingPath:@"conferences"] childByAppendingPath:screenName] childByAppendingPath:@"attendees"] childByAppendingPath:delegate.currentUser.uid];
        [ref removeValue];
    }
    delegate.currentConference = nil;
}

- (void)initFirebaseCallbacks;
{
    Firebase *ref = [[[Firebase alloc] initWithUrl:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FBZFirebaseURL"]] childByAppendingPath:@"conferences"];
    
    [ref observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        // If a conference is added...
        NSDictionary *dict = snapshot.value;
        FBZConference *newConference = [[FBZConference alloc] initWithDictionary:dict];
        [self.conferenceList addObject:newConference];
        [self.tableView reloadData];
    }];
    
    [ref observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        //Remove conference
        NSDictionary *dict = snapshot.value;
        FBZConference *removedConference = [[FBZConference alloc] initWithDictionary:dict];
        [self.conferenceList removeObject:removedConference];
        [self.tableView reloadData];
    }];
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredConferenceList count];
    } else {
        return [self.conferenceList count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    // TODO: Probably use custom table view cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    FBZConference *currentConference;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        currentConference = [self.filteredConferenceList objectAtIndex:indexPath.row];
    } else {
        currentConference = [self.conferenceList objectAtIndex:indexPath.row];
    }
        
    
    
//    NSDictionary *currentConference = [self.conferenceList objectAtIndex:indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = [currentConference.twitter objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@",[currentConference.twitter objectForKey:@"screen_name"]];
    cell.textLabel.textColor = [UIColor colorWithRed:0.0 green:(153.0/255.0) blue:(102.0/255.0) alpha:1.0];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0 green:(153.0/255.0) blue:(102.0/255.0) alpha:0.5];
    
    // Download images in the background
    NSURL *url = [NSURL URLWithString:[currentConference.twitter objectForKey:@"profile_image_url"]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    cell.imageView.image = [UIImage imageWithData:data];
    [cell.imageView.layer setMasksToBounds:YES];
    [cell.imageView.layer setCornerRadius:5.0];
    
    // Resizing from :http://stackoverflow.com/questions/2788028/how-do-i-make-uitableviewcells-imageview-a-fixed-size-even-when-the-image-is-sm
    CGSize itemSize = CGSizeMake(32, 32);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    FBZAttendeesTableViewController *attendeesViewController = [[FBZAttendeesTableViewController alloc] init];
    // Pass the selected object to the new view controller.
    
    FBZConference *currentConference = [self.conferenceList objectAtIndex:indexPath.row];
    
    FBZAppDelegate *delegate = (FBZAppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.currentConference = currentConference;
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Push the view controller.
    [self.navigationController pushViewController:attendeesViewController animated:YES];

}
 
#pragma mark - Navigation bar button item methods (adding a conference)

- (void) addConference;
{
    // Pop up the modal conference adder view
    UIAlertView *addConferenceAlertView = [[UIAlertView alloc] initWithTitle:@"Add Conference" message:@"Add the conference's twitter handle: @conference" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    addConferenceAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [addConferenceAlertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Add"]) {
        UITextField *conferenceTextField = [alertView textFieldAtIndex:0];
        NSString *conferenceName = conferenceTextField.text;
        // CHeck that only twitter handles can be added here
        // TODO Replace w/ NSRegularExpression
        if (![conferenceName isEqualToString:@""] && [conferenceName characterAtIndex:0] == '@') {
            [self addConferenceViaTwitter:[conferenceName lowercaseString]];
        } else {
            // Pop up an alert that says that they screwed up!
            UIAlertView *failedToAddView = [[UIAlertView alloc] initWithTitle:@"Failed to add conference" message:@"Please check the conference title and try again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [failedToAddView show];
        }
    }
}

#pragma mark - Search Display Controller methods

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Remove all objects from the filtered search array
    [self.filteredConferenceList removeAllObjects];
    
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@",searchText];
    self.filteredConferenceList = [NSMutableArray arrayWithArray:[self.conferenceList filteredArrayUsingPredicate:predicate]];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString;
{
    [self filterContentForSearchText:searchString scope:nil];
    return YES;
}

#pragma mark - Twitter API methods

- (BOOL)userHasAccessToTwitter;
{
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)addConferenceViaTwitter:(NSString *)twitterID;
{
    if ([self userHasAccessToTwitter]) {
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error) {
            if (granted) {
                // Request was granted, time to see if we can find out user info
                NSArray *accounts = [self.accountStore accountsWithAccountType:twitterAccountType];
                NSURL *twitterAPI = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json?screen_name"];
                NSDictionary *params = @{@"screen_name":twitterID};
                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:twitterAPI parameters:params];
                [request setAccount:[accounts lastObject]];
                [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    if (responseData) {
                        if (urlResponse.statusCode >=200 && urlResponse.statusCode < 300) {
                            NSError *jsonError;
                            NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                            if (userData) {
                                // We got user data back!
                                Firebase *ref = [[[[Firebase alloc] initWithUrl:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FBZFirebaseURL"]] childByAppendingPath:@"conferences"] childByAppendingPath:twitterID];
                                FBZAppDelegate *delegate = (FBZAppDelegate *)[[UIApplication sharedApplication] delegate];
                                FAUser *currentUser = [delegate getCurrentUser];
                                FBZConference *newConference = [[FBZConference alloc] initWithTwitter:userData andCreator:currentUser.uid];
                                [ref setValue:newConference.toDictionary];
                            } else {
                                // JSON Deserialization failed
                                NSLog(@"%@", [jsonError localizedDescription]);
                            }
                        } else {
                            // Some other error occurred, find out what it is
                            NSLog(@"Response status code is: %d", urlResponse.statusCode);
                            if (urlResponse.statusCode == 404) {
                                UIAlertView *badTwitterHandle = [[UIAlertView alloc] initWithTitle:@"Failed to add!" message:@"Please check the twitter ID of the conference and try again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                [badTwitterHandle show];
                            }
                        }
                    }
                }];
            } else {
                // Access denied!
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    } else {
        // User needs to log in to twitter... but they should never be here because they have to be logged in in order to do anything here
    }
}



@end
