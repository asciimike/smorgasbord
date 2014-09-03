//
//  FBZMessagesViewController.m
//  NotificationTest
//
//  Created by Michael McDonald on 9/2/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FBZMessagesViewController.h"
#import "FBZMessage.h"

@interface FBZMessagesViewController ()

@end

@implementation FBZMessagesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.messagesArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Messages";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMessage)];
    
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://ios-chat-demo.firebaseio.com"];
    [ref observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        //Fire off local notification
        NSMutableDictionary *dict = [snapshot.value mutableCopy];
        [dict setObject:snapshot.name forKey:@"uid"];
        FBZMessage *message = [[FBZMessage alloc] initWithDictionary:dict];
        [self.messagesArray addObject:message];
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [dict objectForKey:@"data"];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        
        [UIApplication sharedApplication].applicationIconBadgeNumber++;
        
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
    return [self.messagesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    FBZMessage *currentMessage = [self.messagesArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = currentMessage.data;
    cell.detailTextLabel.text = currentMessage.author;
    
    return cell;
}

- (void)addMessage;
{
    UIAlertView *addMessageAlertView = [[UIAlertView alloc] initWithTitle:@"Add Message" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    addMessageAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [addMessageAlertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    NSString *buttonText = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonText isEqualToString:@"Add"]) {
        Firebase *ref = [[Firebase alloc] initWithUrl:@"https://ios-chat-demo.firebaseio.com"];
        NSString *data = [alertView textFieldAtIndex:0].text;
        FBZMessage *message = [[FBZMessage alloc] initWithId:@"" Author:@"Mike" Data:data];
        [[ref childByAutoId] setValue:message.toDictionary];
    } else {
        // Do nothing since the other option is cancel
    }
}

@end
