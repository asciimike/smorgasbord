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
#import "FBZAttendesTableViewController.h"

#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>

@interface FBZConferencesTableViewController ()

@end

@implementation FBZConferencesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.conferenceList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.tableView.backgroundColor = [UIColor colorWithRed:0.0 green:(153.0/255.0) blue:(102.0/255.0) alpha:1.0];
    self.title = @"Conferences";
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0.0 green:(153.0/255.0) blue:(102.0/255.0) alpha:1.0], NSForegroundColorAttributeName, [UIColor colorWithRed:0.0 green:(153.0/255.0) blue:(102.0/255.0) alpha:1.0], NSBackgroundColorAttributeName, nil];

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320.0, 44)];
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
    
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
        Firebase *ref = [[[[[[Firebase alloc] initWithUrl:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FBZFirebaseURL"]] childByAppendingPath:@"conferences"] childByAppendingPath:currentConference.twitterID] childByAppendingPath:@"attendees"] childByAppendingPath:delegate.currentUser.uid];
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
    return [self.conferenceList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    // TODO: Probably use custom table view cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    FBZConference *currentConference = [self.conferenceList objectAtIndex:indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = @"Conference name"; //currentConference.name;
    cell.detailTextLabel.text = currentConference.twitterID;
    cell.textLabel.textColor = [UIColor colorWithRed:0.0 green:(153.0/255.0) blue:(102.0/255.0) alpha:1.0];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0 green:(153.0/255.0) blue:(102.0/255.0) alpha:0.5];

    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    FBZAttendesTableViewController *attendeesViewController = [[FBZAttendesTableViewController alloc] init];
    // Pass the selected object to the new view controller.
    
    FBZConference *currentConference = [self.conferenceList objectAtIndex:indexPath.row];
    
    FBZAppDelegate *delegate = (FBZAppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.currentConference = currentConference;

    
    // Push the view controller.
    [self.navigationController pushViewController:attendeesViewController animated:YES];
}
 

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
        if ((![conferenceName isEqualToString:@""]) && ([conferenceName characterAtIndex:0] == '@')) {
            Firebase *ref = [[[[Firebase alloc] initWithUrl:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FBZFirebaseURL"]] childByAppendingPath:@"conferences"] childByAppendingPath:conferenceName];
            FBZAppDelegate *delegate = (FBZAppDelegate *)[[UIApplication sharedApplication] delegate];
            FAUser *currentUser = [delegate getCurrentUser];
            FBZConference *newConference = [[FBZConference alloc] initWithTwitter:conferenceName andCreator:currentUser.uid];
            [ref setValue:newConference.toDictionary];
        } else {
            // Pop up an alert that says that they screwed up!
            UIAlertView *failedToAddView = [[UIAlertView alloc] initWithTitle:@"Failed to add conference" message:@"Please check the conference title and try again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [failedToAddView show];
        }
    }
}

@end
