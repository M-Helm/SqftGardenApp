//
//  SaveGardenViewController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 8/18/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "SaveGardenViewController.h"
#import "DBManager.h"
#import "ApplicationGlobals.h"
#import "UITextView+FileProperties.h"

@interface SaveGardenViewController()

@end

@implementation SaveGardenViewController

static NSString *CellIdentifier = @"CellIdentifier";
ApplicationGlobals *appGlobals;
DBManager *dbManager;
NSMutableArray *saveBedJson;
UIColor *tabColor;


- (void)viewDidLoad {
    [super viewDidLoad];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    dbManager = [DBManager getSharedDBManager];
    //self.navigationItem.title = appGlobals.appTitle;
    tabColor = [appGlobals colorFromHexString: @"#74aa4a"];
    
    self.tableView.separatorColor = [UIColor clearColor];

    
    float width = self.view.frame.size.width;
    //float height = self.view.frame.size.height;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake((headerView.frame.size.width/2)-75, 0, 150, 50)];
    [headerView addSubview:labelView];
    labelView.text = @"Save Garden";
    labelView.textAlignment = NSTextAlignmentCenter;
    [labelView setFont:[UIFont boldSystemFontOfSize:18]];
    headerView.layer.backgroundColor = [UIColor whiteColor].CGColor;

    self.tableView.tableHeaderView = headerView;
    //self.tableView.tableFooterView = self.saveTextView;
    saveBedJson = [dbManager getBedSaveList];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int i = (int)saveBedJson.count + 1;
    //NSLog(@"cell count %i",i);
    //if(i<2)i=2;
    return i;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITextView *label = [[UITextView alloc]initWithFrame:CGRectMake(20,0,160,cell.frame.size.height)];
    [label setDelegate: (id <UITextViewDelegate>) self];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    
    if([indexPath row] == 0){
        CGRect fm = CGRectMake(-20,0,self.view.frame.size.width, cell.frame.size.height);
        UILabel *border = [[UILabel alloc] initWithFrame:fm];
        [label setText:@"*New File"];
        NSNumber *index = [NSNumber numberWithInt:0];
        [label setLocalIndex:index];
        border.layer.borderColor = [UIColor lightGrayColor].CGColor;
        border.layer.borderWidth = .5;
        border.layer.cornerRadius = 15;
        [cell addSubview:label];
        [cell addSubview:border];
        [label setReturnKeyType:UIReturnKeyDone];
        return cell;
    }
    CGRect fm = CGRectMake(20,4,self.view.frame.size.width, cell.frame.size.height);
    label.frame = fm;
    UILabel *border = [[UILabel alloc] initWithFrame:fm];
    border.layer.borderColor = [UIColor lightGrayColor].CGColor;
    border.layer.borderWidth = 1;
    border.layer.cornerRadius = 15;
    border.clipsToBounds = YES;
    border.backgroundColor = [tabColor colorWithAlphaComponent:.05];
    
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, 150, 20)];
    [dateLabel setFont:[UIFont systemFontOfSize:11]];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    
    NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
    int i = (int)[indexPath row] - 1;
    if(saveBedJson.count > 0)json = saveBedJson[i];
    else return cell;

    NSString *name = [json objectForKey:@"name"];
    NSString *timestamp = [json objectForKey:@"timestamp"];
    NSString *local_id = [json objectForKey:@"local_id"];
    NSNumber *index = [NSNumber numberWithInt:local_id.intValue];
    
    [label setLocalIndex: index];
    
    NSNumber *startTime = [NSNumber numberWithInt:timestamp.intValue];
    NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
    [inFormat setDateFormat:@"MMM dd, yyyy HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[startTime doubleValue]];
    NSString *dateStr = [inFormat stringFromDate:date];
    [label setText:[NSString stringWithFormat:@"%@ || %@", local_id, name]];
    [dateLabel setText:[NSString stringWithFormat:@"Saved: %@", dateStr]];
    [cell addSubview:label];
    [cell addSubview: dateLabel];
    
    if((int)saveBedJson.count + 1 > 2)
        [cell addSubview:border];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    //NSLog(@"Begin editing");
    if(appGlobals.globalGardenModel == nil){
        [self showNullModelAlert];
    }
    
    NSString *fileName = @"";
    int index = [[textView localId]intValue];
    if(index < 1){
        textView.text = @"";
    }else{
        textView.tintColor = [UIColor clearColor];
        textView.hidden = NO;
        [textView resignFirstResponder];
        for(int i = 0;i<saveBedJson.count;i++){
            NSDictionary *dict = saveBedJson[i];
            NSString *tempIndex = [dict objectForKey:@"local_id"];
            if([[textView localId]intValue] == tempIndex.intValue){
                fileName = [dict objectForKey:@"name"];
                break;
            }
        }
        [self showOverwriteAlertForFile: fileName atIndex: index];
    }
}


- (void)textViewDidEndEditing:(UITextView *)textView{
    NSLog(@"DidEndEditing");
    NSLog(@"TEXTVIEW TEXT: %@", textView.text);
    if(textView.text.length < 1){
        return;
    }
    

}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqual:@"\n"]) {
        [textView resignFirstResponder];
        [appGlobals.globalGardenModel assignNewUUID];
        appGlobals.globalGardenModel.name = textView.text;
        appGlobals.globalGardenModel.localId = 7;
        [appGlobals.globalGardenModel saveModel:false]; //false on overwrite arg
        [self showWriteSuccessAlertForFile:textView.text atIndex: -1];
        return NO;
    }
    return YES;
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    NSLog(@"Should Begin editing");
    return YES;
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    
    if ([textView.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        UITableViewCell *cell = (UITableViewCell*)textView.superview.superview;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
    return YES;
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:YES];
    }
}

- (void) showOverwriteAlertForFile : (NSString *)fileName atIndex: (int) index{
    NSString *alertStr = [NSString stringWithFormat:@"Overwrite %@", fileName];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:appGlobals.appTitle
                                                    message: alertStr
                                                   delegate:self
                                          cancelButtonTitle:@"NO"
                                          otherButtonTitles:@"YES", nil];
    [alert show];
}

- (void) showWriteSuccessAlertForFile: (NSString *)fileName atIndex: (int) index{
    NSString *alertStr = [NSString stringWithFormat:@"File Saved as %@", fileName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:appGlobals.appTitle
                                                    message: alertStr
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}
- (void) showNullModelAlert {
    NSString *alertStr = @"There is no data in the garden model";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:appGlobals.appTitle
                                                    message: alertStr
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 0) {
        [self.navigationController performSegueWithIdentifier:@"showMain" sender:self.navigationController];
        NSLog(@"Btn0");
    }
    if (buttonIndex == 1) {
        NSLog(@"Btn1");
        [appGlobals.globalGardenModel saveModel:true]; //true on overwrite arg
        [self.navigationController performSegueWithIdentifier:@"showMain" sender:self.navigationController];
    }
    if (buttonIndex == 2) {
        NSLog(@"Btn2");
    }
}

@end

