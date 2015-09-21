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
#import "UITextView+FileProperties.h"
#import "DeleteButtonView.h"


@interface OpenBedViewController ()

@end

@implementation OpenBedViewController


static NSString *CellIdentifier = @"CellIdentifier";
DBManager *dbManager;
ApplicationGlobals *appGlobals;
NSMutableArray *saveBedJson;
UIColor *tabColor;

- (void)viewDidLoad {
    [super viewDidLoad];
    dbManager = [DBManager getSharedDBManager];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    saveBedJson = [dbManager getBedSaveList];
    //self.navigationItem.title = appGlobals.appTitle;
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
    int i = (int)saveBedJson.count + 1;
    if(i<2)i=1;
    return i;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *cellTextView = [[UILabel alloc]initWithFrame:CGRectMake(25,2,self.view.frame.size.width-20, 22)];
    NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
    [cellTextView setFont:[UIFont boldSystemFontOfSize:14]];
    int index = (int)[indexPath row];
    CGRect fm = CGRectMake(20,0,self.view.frame.size.width, cell.frame.size.height);
    UILabel *border = [[UILabel alloc] initWithFrame:fm];
    border.layer.borderColor = [UIColor lightGrayColor].CGColor;
    border.layer.borderWidth = .5;
    border.layer.cornerRadius = 15;
    border.clipsToBounds = YES;
    border.backgroundColor = [tabColor colorWithAlphaComponent:.05];
    //cellTextView.editable = NO;
    //cellTextView.userInteractionEnabled = YES;

    
    if(index == 0){
        CGRect leftFrame = CGRectMake(-20,0,self.view.frame.size.width, cell.frame.size.height);
        border.frame = leftFrame;
        border.backgroundColor = [UIColor clearColor];
        [cellTextView setText:[NSString stringWithFormat:@"Cancel"]];
        [cell addSubview:cellTextView];
        [cell addSubview:border];
        return cell;
    }
    if(saveBedJson.count > 0){
        index = index - 1;
        if(index < 0)index = 0;
        json = saveBedJson[index];
        NSString *name = [json objectForKey:@"name"];
        NSString *timestamp = [json objectForKey:@"timestamp"];
        //NSString *local_id = [json objectForKey:@"local_id"];
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:timestamp.intValue];
        
        UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, 150, 20)];
        [dateLabel setFont:[UIFont systemFontOfSize:11]];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
        [inFormat setDateFormat:@"MMM dd, yyyy HH:mm"];
        
        NSString *dateStr = [inFormat stringFromDate:date];
        [dateLabel setText:[NSString stringWithFormat:@"Saved: %@", dateStr]];
        dateLabel.backgroundColor = [UIColor blueColor];
        
        [cell addSubview: dateLabel];
        
        NSString *str = [json objectForKey:@"local_id"];
        NSNumber *cellIndex = [[NSNumber alloc]initWithInt:str.intValue];
        //deleteButton.localId = cellIndex;
        
        //UIview has been subclassed to hold an index value
        DeleteButtonView *deleteButton = [[DeleteButtonView alloc] initWithFrame:CGRectMake(self.view.frame.size.width -44, 11, 44, 44) withPositionIndex:(int)cellIndex];
        
        //UITextView *deleteButton = [self deleteButton];
        //deleteButton.userInteractionEnabled = YES;
        
        
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleDeleteSelect:)];
        
        [deleteButton addGestureRecognizer:singleFingerTap];
         
         
        
        [cellTextView setText: [NSString stringWithFormat:@"%i || %@ ", index, name]];
        [cell addSubview:cellTextView];
        [cell addSubview:border];
        [cell addSubview:deleteButton];
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


- (void) showDeleteAlertForFile : (NSString *)fileName atIndex: (int) index{
    NSString *alertStr = [NSString stringWithFormat:@"Delete %@?", fileName];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:appGlobals.appTitle
                                                    message: alertStr
                                                   delegate:self
                                          cancelButtonTitle:@"NO"
                                          otherButtonTitles:@"YES", nil];
    [alert show];
}
-(void) handleDeleteSelect:(UITapGestureRecognizer *)recognizer{
    NSLog(@"Delete button selected");
    //DeleteButtonView *btn = (DeleteButtonView*)recognizer.view;
    //[self showDeleteAlertForFile:@"none" atIndex:btn.localId];
}


@end