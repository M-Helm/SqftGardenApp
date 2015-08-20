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


- (void)viewDidLoad {
    [super viewDidLoad];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    dbManager = [DBManager getSharedDBManager];

    
    self.tableView.separatorColor = [UIColor whiteColor];
    //self.messageTF.layoutMargins = UIEdgeInsetsMake(155.0, 85.0, 255.0, 85.0);
    //self.saveTextView.delegate = self;
    //[self.saveTextView setReturnKeyType:UIReturnKeyDone];
    //[self.messageTextView setBackgroundColor:[UIColor lightGrayColor]];
    //self.saveTextView.layer.borderColor = [UIColor blackColor].CGColor;
    //self.saveTextView.layer.borderWidth  = 1.0;
    //self.saveTextView.layer.cornerRadius = 15.0;
    
    //self.saveTextView.text = @"File Name";
    //self.saveTextView.textColor = [UIColor blackColor];
    
    float width = self.view.frame.size.width;
    //float height = self.view.frame.size.height;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [headerView addSubview:imageView];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(51, 0, width, 50)];
    [headerView addSubview:labelView];
    labelView.text = @"Save Garden";
    headerView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    imageView.layer.cornerRadius = 15;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderWidth = 1.0;
    self.tableView.tableHeaderView = headerView;
    //self.tableView.tableFooterView = self.saveTextView;
    saveBedJson = [dbManager getBedSaveList];
    
    /*
    float xCo = self.view.frame.size.width - 15;
    //float yCo = self.view.frame.size.height - self.tableView.frame.size.height;
    float yCo = self.view.frame.size.height - 35;
    
    UITextView *textView =[[UITextView alloc]initWithFrame:CGRectMake(15,yCo,xCo,20)];
    [textView setDelegate: self];
    [textView setReturnKeyType:UIReturnKeyDone];
    [textView setTag:1];
    textView.layer.cornerRadius =5;
    textView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:textView];
    */
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int i = (int)saveBedJson.count;
    //NSLog(@"cell count %i",i);
    //if(i<2)i=2;
    return i;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UITextView *label = (UITextView *)[cell.contentView viewWithTag:10];
    [label setDelegate:self];
    
    //UILabel *label = (UILabel *)[cell.contentView viewWithTag:10];
    NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
    int i = [indexPath row];
    if(saveBedJson.count > 0)json = saveBedJson[i];
    else return cell;
    NSString *name = [json objectForKey:@"name"];
    NSString *timestamp = [json objectForKey:@"timestamp"];
    NSString *local_id = [json objectForKey:@"local_id"];
    NSNumber *index = [NSNumber numberWithInt:local_id.intValue];
    
    [label setLocalIndex: index];
    int label_id = [label.localId integerValue];
    NSLog(@"LABEL ID FROM GETTER: %i", label_id);
    
    NSNumber *startTime = [NSNumber numberWithInt:timestamp.integerValue];
    NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
    [inFormat setDateFormat:@"MMM dd, yyyy HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[startTime doubleValue]];
    NSString *dateStr = [inFormat stringFromDate:date];
    [label setText:[NSString stringWithFormat:@"%@ || %@ || saved: %@", local_id, name, dateStr]];
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSLog(@"Begin editing");
    int index = [[textView localId]intValue];
    NSString *fieldText = [NSString stringWithFormat:@"File ID: %i", index];
    
    textView.hidden = NO;
    textView.text = fieldText;
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    NSLog(@"DidEndEditing");

}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqual:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    NSLog(@"Should Begin editing");
    //CGPoint pointInTable = [textView.superview convertPoint:textView.frame.origin toView:self.tableView];
    //CGPoint contentOffset = self.tableView.contentOffset;

    //NSLog(@"contentOffset is: %@", NSStringFromCGPoint(contentOffset));
    
    //[self.tableView setContentOffset:contentOffset animated:YES];
    
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

@end

