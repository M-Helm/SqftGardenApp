//
//  DataPresentationTableViewController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/22/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import "DataPresentationTableViewController.h"
#import "DBManager.h"
#import "ApplicationGlobals.h"
#import "PresentTableCell.h"

@interface DataPresentationTableViewController()

@end

@implementation DataPresentationTableViewController

DBManager *dbManager;
ApplicationGlobals *appGlobals;
static NSString *CellIdentifier = @"CellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    dbManager = [DBManager getSharedDBManager];
    appGlobals = [ApplicationGlobals getSharedGlobals];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PresentTableCell *cell;
    //UILabel *mainLabel;
    
    if(cell == nil){
        cell = [[PresentTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.mainLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0,200,20)];
        cell.mainLabel.text = @"This is the main label";
    }else{
        
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}


@end
