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


@interface SaveGardenViewController()

@end

@implementation SaveGardenViewController{
    ApplicationGlobals *appGlobals;
    DBManager *dbManager;
    NSMutableArray *saveBedJson;
    UIColor *tabColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    dbManager = [DBManager getSharedDBManager];
    //self.navigationItem.title = appGlobals.appTitle;
    tabColor = [appGlobals colorFromHexString: @"#74aa4a"];
    
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView setDelegate:self];
    
    float width = self.view.frame.size.width;
    //float height = self.view.frame.size.height;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake((headerView.frame.size.width/2)-75, 0, 150, 50)];
    //add cancel button
    PlantIconView *cancelBtn = [[PlantIconView alloc]
                                initWithFrame:CGRectMake(self.view.frame.size.width - 55, 1, 44,44) withPlantUuid: @"cancel" isIsometric:NO];
    
    cancelBtn.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleCancelSingleTap:)];
    [cancelBtn addGestureRecognizer:singleFingerTap];
    
    
    [headerView addSubview:labelView];
    [headerView addSubview:cancelBtn];
    labelView.text = @"Save Garden";
    labelView.textAlignment = NSTextAlignmentCenter;
    [labelView setFont:[UIFont boldSystemFontOfSize:18]];
    headerView.layer.backgroundColor = [UIColor whiteColor].CGColor;

    self.tableView.tableHeaderView = headerView;

    saveBedJson = [dbManager getBedSaveList];
    if(saveBedJson == nil){
        saveBedJson = [[NSMutableArray alloc]init];
    }
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"saveBedViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int i = (int)saveBedJson.count + 1;
    return i;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    UITableViewCell *cell;
    UITextView *label;
    UILabel *border;
    UILabel *textLabel;
    UILabel *dateLabel;
    
    if(cell == nil){
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
        label = [[UITextView alloc]
                 initWithFrame:CGRectMake(20,0,160,cell.frame.size.height)];
        label.tag = 3;
        border = [[UILabel alloc]
                  initWithFrame:CGRectMake(-20,0,self.view.frame.size.width, cell.frame.size.height)];
        border.tag = 4;
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,4,self.view.frame.size.width, cell.frame.size.height)];
        textLabel.tag = 5;
        
        dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, 150, 20)];
        dateLabel.tag = 6;
        
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:border];
        [cell.contentView addSubview:textLabel];
        [cell.contentView addSubview:dateLabel];
        
    }else{
        label = (UITextView*)[cell.contentView viewWithTag:3];
        border = (UILabel*)[cell.contentView viewWithTag:4];
        textLabel = (UILabel*)[cell.contentView viewWithTag:5];
        dateLabel = (UILabel*)[cell.contentView viewWithTag:6];
    }
    
    if([indexPath row] == 0){
        [[cell.contentView viewWithTag:5]removeFromSuperview];
        //NSNumber *index = [NSNumber numberWithInt:0];
        //[label setLocalIndex:index];
        [label setFont:[UIFont boldSystemFontOfSize:14]];
        [label setDelegate: (id <UITextViewDelegate>) self];
        [label setText:@"*New File"];
        border.layer.borderColor = [UIColor lightGrayColor].CGColor;
        border.layer.borderWidth = .5;
        border.layer.cornerRadius = 15;
        [cell addSubview:label];
        [cell addSubview:border];
        [label setReturnKeyType:UIReturnKeyDone];
        [label setSpellCheckingType:UITextSpellCheckingTypeNo];
        [label setAutocorrectionType:UITextAutocorrectionTypeNo];
        return cell;
    }
    
    [textLabel setFont:[UIFont boldSystemFontOfSize:14]];
    textLabel.userInteractionEnabled = NO;
    label.userInteractionEnabled = NO;

    CGRect fm = CGRectMake(20,4,self.view.frame.size.width, cell.frame.size.height);
    border.frame = fm;
    border.layer.borderColor = [UIColor lightGrayColor].CGColor;
    border.layer.borderWidth = 1;
    border.layer.cornerRadius = 15;
    border.clipsToBounds = YES;
    border.backgroundColor = [tabColor colorWithAlphaComponent:.05];

    [dateLabel setFont:[UIFont systemFontOfSize:11]];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    
    NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
    int i = (int)[indexPath row] - 1;
    //if(i < 0)i = 0;
    if(saveBedJson.count > 0)json = saveBedJson[i];
    else return cell;
    
    NSString *name = [json objectForKey:@"name"];
    NSString *timestamp = [json objectForKey:@"timestamp"];
    NSNumber *startTime = [NSNumber numberWithInt:timestamp.intValue];
    NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
    [inFormat setDateFormat:@"MMM dd, yyyy HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[startTime doubleValue]];
    NSString *dateStr = [inFormat stringFromDate:date];
    [textLabel setText:[NSString stringWithFormat:@"%i || %@", (int)[indexPath row], name]];
    [dateLabel setText:[NSString stringWithFormat:@"Saved: %@", dateStr]];

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"didSelectRow Called at index: %i", (int)[indexPath row]);
    NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
    int i = (int)[indexPath row] - 1;
    if(saveBedJson.count > 0)json = saveBedJson[i];
    NSString *name = [json objectForKey:@"name"];
    NSString *local_id = [json objectForKey:@"local_id"];
    //NSNumber *index = [NSNumber numberWithInt:local_id.intValue];
    

    //create copy of global model
    NSDictionary *dict = [appGlobals.globalGardenModel compileSaveJson];
    self.tempModel = [[SqftGardenModel alloc]initWithDict:dict];
    
    //grab index, uuid for global model before saving
    self.tempModel.localId = local_id.intValue;
    self.tempModel.name = name;
    self.tempModel.uniqueId = [json objectForKey:@"unique_id"];
    [self showOverwriteAlertForFile: name atIndex: local_id.intValue];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    //Only cell at index 0 should have it's label set to allow user interaction
    //NSLog(@"Begin editing");
    if(appGlobals.globalGardenModel == nil){
        [self showNullModelAlert];
    }
    textView.text = @"";
}


- (void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    if(textView.text.length < 1){
        return;
    }
    

}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqual:@"\n"]) {
        [textView resignFirstResponder];
        [appGlobals.globalGardenModel assignNewUUID];
        appGlobals.globalGardenModel.name = textView.text;
        int newId = [dbManager getTableRowCount:@"saves"]+1;
        appGlobals.globalGardenModel.localId = newId;
        [appGlobals.globalGardenModel saveModelWithOverWriteOption:NO];
        [self showWriteSuccessAlertForFile:textView.text atIndex: -1];
        return NO;
    }
    return YES;
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {

    return YES;
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    
    if ([textView.superview.superview isKindOfClass:[UITableViewCell class]]){
        UITableViewCell *cell = (UITableViewCell*)textView.superview.superview;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
    return YES;
}
- (void) viewDidAppear:(BOOL)animated {
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
        self.view.alpha = 0.0;
        [self.navigationController performSegueWithIdentifier:@"showMain" sender:self.navigationController];

    }
    if (buttonIndex == 1) {

        //grab index, uuid for global model before saving
        appGlobals.globalGardenModel = self.tempModel;
        
        
        [appGlobals.globalGardenModel saveModelWithOverWriteOption:YES]; //true on overwrite arg
        [self.navigationController performSegueWithIdentifier:@"showMain" sender:self.navigationController];
    }
    if (buttonIndex == 2) {

    }
}
- (void)handleCancelSingleTap:(UITapGestureRecognizer *)recognizer {
    [self.navigationController performSegueWithIdentifier:@"showMain" sender:self.navigationController];
    return;
}

@end

