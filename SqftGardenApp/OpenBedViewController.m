//
//  OpenBedViewController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 8/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "OpenBedViewController.h"
#import "DBManager.h"
//#import "MenuDrawViewController.h"
#import "ApplicationGlobals.h"


@interface OpenBedViewController ()

@end

@implementation OpenBedViewController


static NSString *CellIdentifier = @"CellIdentifier";
DBManager *dbManager;
ApplicationGlobals *appGlobals;
//MenuDrawerViewController *sharedMenuDrawer;
//int table_rows = 2;
NSMutableArray *saveBedJson;

- (void)viewDidLoad {
    [super viewDidLoad];
    dbManager = [DBManager getSharedDBManager];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    //sharedMenuDrawer = [MenuDrawerViewController getSharedMenuDrawer];
    saveBedJson = [[NSMutableArray alloc]init];
    saveBedJson = [dbManager getBedSaveList];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int i = saveBedJson.count;
    NSLog(@"cell count %i",i);
    if(i<2)i=2;
    return i;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    NSString *string = @"";
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //NSLog(@"count: %d", (int)[matchBucket count]);
    //if([matchBucket count] < 1)return cell;
    //[self tableView:self.tableView numberOfRowsInSection:(int)[matchBucket count]];
    //json = [matchBucket objectAtIndex:[indexPath row]];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:10];
    //UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:9];
    //imageView.layer.cornerRadius = imageView.bounds.size.width / 2.0;
    //imageView.layer.masksToBounds = YES;
    //imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //imageView.layer.borderWidth = 1.0;
    NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
    if(saveBedJson.count > 0)json = saveBedJson[0];
    else return cell;
    NSString *name = [json objectForKey:@"name"];
    NSString *timestamp = [json objectForKey:@"timestamp"];
    [label setText: [NSString stringWithFormat:@"%@ %@", name, timestamp]];
    if([indexPath row] == 0){
        [label setText:[NSString stringWithFormat:@"Cancel"]];
    }
    //imageView.image = [self getTargetImage:[json objectForKey:@"pic_url"]];
    return cell;
}

- (UIImage *)getTargetImage:(NSString *)pic_url{
    NSURL *url = [NSURL URLWithString: pic_url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *targetImage = [[UIImage alloc] initWithData:data];
    return targetImage;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == 0){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyButtonPressed" object:self];
        return;
    }
    NSLog(@"ShowMain segue Called, %@", self.navigationController);
    [self.navigationController performSegueWithIdentifier:@"showMain" sender:self.navigationController];
    //[sharedMenuDrawer showEditView];
    //[self.view removeFromSuperview];
    
    //NSLog(@"%i", (int)indexPath.row);
    //json = [matchBucket objectAtIndex:[indexPath row]];
    //NSLog(@"%@", [json objectForKey:@"fb_id"]);
    //[appGlobals setMessagingUserFB_ID:[json objectForKey:@"fb_id"]];
    //[appGlobals setMessagingUser_Pic:[json objectForKey:@"pic_url"]];
    //[appGlobals setMessagingUser_screen_name:[json objectForKey:@"screen_name"]];
    //[self.navigationController performSegueWithIdentifier:@"showMessageDetail" sender:self];
}



@end