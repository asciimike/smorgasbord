//
//  FBZBuzzwordsTableViewController.m
//  Buzzword
//
//  Created by Michael McDonald on 7/2/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FBZBuzzwordsTableViewController.h"
#import "FBZAppDelegate.h"
#import "FBZWord.h"

#import <Firebase/Firebase.h>

@interface FBZBuzzwordsTableViewController ()

@end

@implementation FBZBuzzwordsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.wordList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0.0 green:(153.0/255.0) blue:(102.0/255.0) alpha:1.0], NSForegroundColorAttributeName, [UIColor colorWithRed:0.0 green:(153.0/255.0) blue:(102.0/255.0) alpha:1.0], NSBackgroundColorAttributeName, nil];

    self.clearsSelectionOnViewWillAppear = YES;
 
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addWord)];
    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"exit3"] style:UIBarButtonItemStylePlain target:[[UIApplication sharedApplication] delegate] action:@selector(logout)];
    self.navigationItem.rightBarButtonItems = @[logoutItem, addItem];
}

- (void)viewWillAppear:(BOOL)animated;
{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"FBZNoConferenceView"
                                                      owner:self
                                                    options:nil];

    UIView* myView = [nibViews objectAtIndex: 0];
    self.tableView.backgroundView = myView;
    
    [self.wordList removeAllObjects];
    [self.tableView reloadData];
    
    //check shared delegate for a conference, if one exists show everything, otherwise hide and disable buttons
    FBZAppDelegate *delegate = (FBZAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.currentConference = [delegate getCurrentConference];
    
    if (self.currentConference) {
        self.title = @"Trending Words";
        [self initFirebaseCallbacks];
    }
    
    if (!self.currentConference) {
        // Hide table view
//        self.tableView.hidden = YES;
        self.tableView.backgroundView.hidden = NO;
        // Disable buttons
        [[self.navigationItem.rightBarButtonItems objectAtIndex:1] setEnabled:NO];
    } else {
        // Unide table view
//        self.tableView.hidden = NO;
        self.tableView.backgroundView.hidden = YES;
        // Enable buttons
        [[self.navigationItem.rightBarButtonItems objectAtIndex:1] setEnabled:YES];
    }
}

- (void)initFirebaseCallbacks;
{
    NSString *screenName = [NSString stringWithFormat:@"@%@", [self.currentConference.twitter objectForKey:@"screen_name"]];
    Firebase *ref = [[[[[Firebase alloc] initWithUrl:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FBZFirebaseURL"]] childByAppendingPath:@"conferences"] childByAppendingPath:screenName] childByAppendingPath:@"words"];
    
    [ref observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        // If a conference is added...
        FBZWord *newWord = [[FBZWord alloc] initWithWord:snapshot.name andCount:(NSInteger)snapshot.value];
        [self.wordList addObject:newWord];
//        FBZConference *newConference = [[FBZConference alloc] initWithDictionary:dict];
//        [self.conferenceList addObject:newConference];
        [self.tableView reloadData];
    }];
    
    [ref observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        //Check which child had a value updated
        
        //Update UI appropriately
    }];
    
    [ref observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        //Remove conference
        NSDictionary *dict = snapshot.value;
//        FBZConference *removedConference = [[FBZConference alloc] initWithDictionary:dict];
//        [self.conferenceList removeObject:removedConference];
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
    return [self.wordList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    FBZWord *currentWord = [self.wordList objectAtIndex:indexPath.row];
    cell.textLabel.text = currentWord.word;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)addWord;
{
    // Pop up the modal conference adder view
    UIAlertView *addWordAlertView = [[UIAlertView alloc] initWithTitle:@"Add Buzzword" message:@"What have you overheard today?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    addWordAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [addWordAlertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Add"]) {
        UITextField *wordTextField = [alertView textFieldAtIndex:0];
        NSString *word = wordTextField.text;
        if (![word isEqualToString:@""]) {
            NSString *screenName = [NSString stringWithFormat:@"@%@", [self.currentConference.twitter objectForKey:@"screen_name"]];
            Firebase *ref = [[[[[[Firebase alloc] initWithUrl:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FBZFirebaseURL"]] childByAppendingPath:@"conferences"] childByAppendingPath:screenName] childByAppendingPath:@"words" ] childByAppendingPath:word];
            // TODO: change this to pushing on a new child, set the value as the adding users screen name, then use childrenCount on the way out
            [ref setValue:[NSNumber numberWithInt:1]];
        }
    }
}

@end
