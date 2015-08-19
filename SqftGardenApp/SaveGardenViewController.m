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

@implementation SaveGardenViewController

static NSString *CellIdentifier = @"CellIdentifier";
ApplicationGlobals *appGlobals;
DBManager *dbManager;


- (void)viewDidLoad {
    [super viewDidLoad];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    dbManager = [DBManager getSharedDBManager];
    
    
    
    self.tableView.separatorColor = [UIColor whiteColor];
    //self.messageTF.layoutMargins = UIEdgeInsetsMake(155.0, 85.0, 255.0, 85.0);
    self.saveTextView.delegate = self;
    [self.saveTextView setReturnKeyType:UIReturnKeyDone];
    //[self.messageTextView setBackgroundColor:[UIColor lightGrayColor]];
    self.saveTextView.layer.borderColor = [UIColor blackColor].CGColor;
    self.saveTextView.layer.borderWidth  = 1.0;
    self.saveTextView.layer.cornerRadius = 5.0;
    
    self.saveTextView.text = @"File Name";
    self.saveTextView.textColor = [UIColor blackColor];
    
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
    self.tableView.tableFooterView = self.saveTextView;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int i = 1;
    return i;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //UILabel *label = (UILabel *)[cell.contentView viewWithTag:10];
    //label.numberOfLines = 0;
    //UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:9];
    //imageView.layer.cornerRadius = imageView.bounds.size.width / 2.0;
    //imageView.layer.masksToBounds = YES;
    //imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //imageView.layer.borderWidth = 1.0;
    //label.font=[label.font fontWithSize:15];
    
    //[self tableView:self.tableView numberOfRowsInSection:0];
    //if([messageBucket count] < 1)return cell;
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSString *user_fb = [defaults objectForKey:@"fb_id"];
    //json = [messageBucket objectAtIndex:[indexPath row]];
    //NSString *sender_fb = [json objectForKey:@"sender_fb"];
    //UIImage *image;
    //if([sender_fb isEqualToString:user_fb])image = [appGlobals getUserImage];
    //else image = targetImage;
    //imageView.image = image;
    //[label setText:[NSString stringWithFormat:@"%@", [json objectForKey:@"text"]]];
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

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSLog(@"Begin editing");
    textView.hidden = NO;
    textView.text = @"";
    //[textView becomeFirstResponder];
    [self.saveTextView becomeFirstResponder];
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

