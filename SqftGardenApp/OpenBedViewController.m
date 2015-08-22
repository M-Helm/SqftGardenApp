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
#import "SqftGardenModel.h"


@interface OpenBedViewController ()

@end

@implementation OpenBedViewController


static NSString *CellIdentifier = @"CellIdentifier";
DBManager *dbManager;
ApplicationGlobals *appGlobals;
NSMutableArray *saveBedJson;

- (void)viewDidLoad {
    [super viewDidLoad];
    dbManager = [DBManager getSharedDBManager];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    saveBedJson = [dbManager getBedSaveList];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int i = (int)saveBedJson.count + 1;
    if(i<2)i=1;
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
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:10];
    NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
    int index = (int)[indexPath row];
    if(index == 0){
        [label setText:[NSString stringWithFormat:@"Cancel"]];
        return cell;
    }
    if(saveBedJson.count > 0){
        index = index - 1;
        if(index < 0)index = 0;
        json = saveBedJson[index];
        NSString *name = [json objectForKey:@"name"];
        NSString *timestamp = [json objectForKey:@"timestamp"];
        [label setText: [NSString stringWithFormat:@"%i %@ %@", index, name, timestamp]];
    }
    return cell;
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
        //returns us to the main main as "0" is the cancel button position
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyButtonPressed" object:self];
        return;
    }
    //set the current bed json pkg
    NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
    if(saveBedJson.count > [indexPath row] - 1)json = saveBedJson[[indexPath row] - 1];
    [appGlobals clearCurrentGardenModel];
    SqftGardenModel *model = [[SqftGardenModel alloc] initWithDict:json];
    [appGlobals setCurrentGardenModel:model];
    
    [self.navigationController performSegueWithIdentifier:@"showMain" sender:self.navigationController];

}

-(SqftGardenModel *)compileJSONToModel : (NSMutableDictionary *)dict{
    SqftGardenModel *model = [[SqftGardenModel alloc] initWithDict: dict];
    return model;
}



@end