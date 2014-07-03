//
//  FBZAttendesTableViewController.m
//  Buzzword
//
//  Created by Michael McDonald on 7/3/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FBZAttendesTableViewController.h"
#import "FBZAppDelegate.h"

#import <Firebase/Firebase.h>

@interface FBZAttendesTableViewController ()

@end

@implementation FBZAttendesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.attendeeList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"exit3"] style:UIBarButtonItemStylePlain target:[[UIApplication sharedApplication] delegate] action:@selector(logout)];
    self.navigationItem.rightBarButtonItems = @[logoutItem];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    

}

- (void)viewWillAppear:(BOOL)animated;
{
    FBZAppDelegate *delegate = (FBZAppDelegate *)[[UIApplication sharedApplication] delegate];
    FBZConference *currentConference = [delegate getCurrentConference];
    
    [self.attendeeList removeAllObjects];
    
    [self initFirebaseCallbacks];
    
    Firebase *ref = [[[[[[Firebase alloc] initWithUrl:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FBZFirebaseURL"]] childByAppendingPath:@"conferences"] childByAppendingPath:currentConference.twitterID] childByAppendingPath:@"attendees"] childByAppendingPath:delegate.currentUser.uid];
//    NSString *pictureURL = delegate.currentUser.thirdPartyUserData[@"profile_image_url"];
//    [ref setValue:pictureURL];
    [ref setValue:delegate.currentUser.thirdPartyUserData];
}

//- (void)viewWillDisappear:(BOOL)animated;
//{
//    FBZAppDelegate *delegate = (FBZAppDelegate *)[[UIApplication sharedApplication] delegate];
//    FBZConference *currentConference = [delegate getCurrentConference];
//    
//    Firebase *ref = [[[[[[Firebase alloc] initWithUrl:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FBZFirebaseURL"]] childByAppendingPath:@"conferences"] childByAppendingPath:currentConference.twitterID] childByAppendingPath:@"attendees"] childByAppendingPath:delegate.currentUser.uid];
//    [ref removeValue];
//}

- (void)initFirebaseCallbacks;
{
    FBZAppDelegate *delegate = (FBZAppDelegate *)[[UIApplication sharedApplication] delegate];
    FBZConference *currentConference = [delegate getCurrentConference];
    
    Firebase *ref = [[[[[Firebase alloc] initWithUrl:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FBZFirebaseURL"]] childByAppendingPath:@"conferences"] childByAppendingPath:currentConference.twitterID] childByAppendingPath:@"attendees"];
    
    [ref observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [self.attendeeList addObject:@{snapshot.name: snapshot.value}];
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
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.attendeeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *dict = [self.attendeeList objectAtIndex:indexPath.row];
    NSString *key = [[dict allKeys] objectAtIndex:0];
//    NSString *key = [[self.attendeeList objectAtIndex:indexPath.row] key];
    NSDictionary *value = [[self.attendeeList objectAtIndex:indexPath.row] valueForKey:key];
    cell.textLabel.text = value[@"displayName"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@", value[@"screen_name"]];
    cell.textLabel.textColor = [UIColor colorWithRed:0.0 green:(153.0/255.0) blue:(102.0/255.0) alpha:1.0];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0 green:(153.0/255.0) blue:(102.0/255.0) alpha:0.5];
    
    // Download images in the background
    NSURL *url = [NSURL URLWithString:value[@"profile_image_url"]];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
