//
//  OpenBedViewController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 8/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "OpenBedViewController.h"
#import "DBManager.h"
#import "ApplicationGlobals.h"
#import "UITextView+FileProperties.h"
#import "DeleteButtonView.h"
#import "SqftGardenModel.h"


@interface OpenBedViewController ()

@end

@implementation OpenBedViewController


static NSString *CellIdentifier = @"CellIdentifier";
DBManager *dbManager;
ApplicationGlobals *appGlobals;
UIColor *tabColor;
int localIdOfSelected;


- (void)viewDidLoad {
    [super viewDidLoad];
    dbManager = [DBManager getSharedDBManager];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    tabColor = [appGlobals colorFromHexString: @"#74aa4a"];
    
    self.tableView.separatorColor = [UIColor clearColor];
    
    float width = self.view.frame.size.width;
    //float height = self.view.frame.size.height;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake((headerView.frame.size.width/2)-75, 0, 150, 50)];
    [headerView addSubview:labelView];
    labelView.text = @"Open Garden";
    labelView.textAlignment = NSTextAlignmentCenter;
    [labelView setFont:[UIFont boldSystemFontOfSize:18]];
    headerView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.tableView.tableHeaderView = headerView;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.savedBedJson = [dbManager getBedSaveList];
    int i = (int)self.savedBedJson.count + 1;
    if(i<2)i=1;
    return i;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell;
    UILabel *cellTextView;
    UILabel *border;
    UILabel *dateLabel;
    
    if (cell == nil) {
        // create the cell and empty views ready to take the content.
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        cellTextView = [[UILabel alloc]initWithFrame:CGRectMake(25,2,self.view.frame.size.width-20, 22)];
        cellTextView.tag = 3;
        
        [cell.contentView addSubview:cellTextView];
        
        border = [[UILabel alloc] initWithFrame:CGRectMake(20,0,self.view.frame.size.width, cell.frame.size.height)];
        border.tag = 4;
        [cell.contentView addSubview:border];
        
        UILabel *dateLabel = [self makeCellDateLabelWithWidth:self.view.frame.size.width andTimestamp:@"0"];
        dateLabel.tag = 5;
        [cell.contentView addSubview:dateLabel];
        
    } else {
        // get the views that have already been created
        cellTextView = (UILabel*)[cell.contentView viewWithTag:3];
        border = (UILabel*)[cell.contentView viewWithTag:4];
        dateLabel = (UILabel*)[cell.contentView viewWithTag:5];
    }
    
    
    NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
    [cellTextView setFont:[UIFont boldSystemFontOfSize:14]];
    int index = (int)[indexPath row];

    //create the border view

    border.layer.borderColor = [UIColor lightGrayColor].CGColor;
    border.layer.borderWidth = .5;
    border.layer.cornerRadius = 15;
    border.clipsToBounds = YES;
    border.backgroundColor = [tabColor colorWithAlphaComponent:.05];

    
    if(index == 0){
        //setup the cancel button in the first cell
        CGRect leftFrame = CGRectMake(-20,0,self.view.frame.size.width, cell.frame.size.height);
        border.frame = leftFrame;
        border.backgroundColor = [UIColor clearColor];
        [cellTextView setText:[NSString stringWithFormat:@"Cancel"]];
        [[cell.contentView viewWithTag:5]removeFromSuperview];
        return cell;
    }
    if(self.savedBedJson.count > 0){
        
        //get the proper dict from the array making sure to adjust index - cancel being 0
        index = index - 1;
        if(index < 0)index = 0;
        json = self.savedBedJson[index];
        
        NSString *str = [json objectForKey:@"local_id"];
        NSString *name = [json objectForKey:@"name"];
        NSString *timestamp = [json objectForKey:@"timestamp"];
        
        NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
        [inFormat setDateFormat:@"MMM dd, yyyy HH:mm"];
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:timestamp.intValue];
        NSString *dateStr = [inFormat stringFromDate:date];
        [dateLabel setText:[NSString stringWithFormat:@"Saved: %@", dateStr]];

        DeleteButtonView *deleteButton = [[DeleteButtonView alloc] initWithFrame:CGRectMake(self.view.frame.size.width -44, 11, 44, 44) withPositionIndex:str.intValue];
        [deleteButton setFileName:name];
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleDeleteSelect:)];
        [deleteButton addGestureRecognizer:singleFingerTap];

        [cellTextView setText: [NSString stringWithFormat:@"%i || %@ ", (int)[indexPath row], name]];

        [cell addSubview:deleteButton];
    }
    return cell;
}

-(UILabel*)makeCellDateLabelWithWidth:(float)width andTimestamp:(NSString *)timestamp{
    //make the date string
    NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
    [inFormat setDateFormat:@"MMM dd, yyyy HH:mm"];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:timestamp.intValue];
    NSString *dateStr = [inFormat stringFromDate:date];
    
    //make the label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(width/2,0,150,20)];
    label.textAlignment = NSTextAlignmentCenter;
    [label setFont:[UIFont systemFontOfSize:11]];
    [label setText:[NSString stringWithFormat:@"Saved: %@", dateStr]];
    label.backgroundColor = [UIColor clearColor];
    return label;
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
        [self.navigationController performSegueWithIdentifier:@"showMain" sender:self.navigationController];
        return;
    }
    //set the current bed json pkg
    NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
    if(self.savedBedJson.count > [indexPath row] - 1)json = self.savedBedJson[[indexPath row] - 1];
    [appGlobals clearCurrentGardenModel];
    SqftGardenModel *model = [[SqftGardenModel alloc] initWithDict:json];

    [appGlobals setCurrentGardenModel:model];
    [self.navigationController performSegueWithIdentifier:@"showMain" sender:self.navigationController];
}

-(SqftGardenModel *)compileJSONToModel : (NSMutableDictionary *)dict{
    SqftGardenModel *model = [[SqftGardenModel alloc] initWithDict: dict];
    return model;
}


- (void) showDeleteAlertForFile : (NSString *)fileName atIndex: (int) index{
    NSString *alertStr = [NSString stringWithFormat:@"Delete %@?", fileName];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:appGlobals.appTitle
                                                    message: alertStr
                                                   delegate:self
                                          cancelButtonTitle:@"NO"
                                          otherButtonTitles:@"YES", nil];
    [alert show];
}
- (void) showFailureAlertForFile : (NSString *)failMessage atIndex: (int) index{
    NSString *alertStr = [NSString stringWithFormat:@"%@", failMessage];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:appGlobals.appTitle
                                                    message: alertStr
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

-(
  void) handleDeleteSelect:(UITapGestureRecognizer *)recognizer{
    DeleteButtonView *btn = (DeleteButtonView*)recognizer.view;
    localIdOfSelected = btn.localId;
    if(btn.localId < 2)
        [self showFailureAlertForFile:@"Can't Delete AutoSave File" atIndex:0];
    else{
        [self showDeleteAlertForFile:btn.fileName atIndex:btn.localId];
    }
    
}
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 0) {
        //NSLog(@"Btn0");
    }
    if (buttonIndex == 1) {
        //NSLog(@"Btn1");
        for(UIView *subview in self.tableView.visibleCells){
            [subview removeFromSuperview];
        }
        [dbManager deleteGardenWithId:localIdOfSelected];
        self.savedBedJson = [dbManager getBedSaveList];
        [self.tableView reloadData];
    }
    if (buttonIndex == 2) {
        //NSLog(@"Btn2");
    }
}



@end