//
//  TermsScreenViewController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/16/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "TermsScreenViewController.h"

@interface TermsScreenViewController()

@end

@implementation TermsScreenViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"";
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    float navBarHeight = self.navigationController.navigationBar.frame.size.height * 1.5;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15,navBarHeight,width-30, 20)];
    titleLabel.text = @"GrowSquared Privacy Policy";
    [self.view addSubview:titleLabel];
    UITextView *legalStuff = [[UITextView alloc] initWithFrame:CGRectMake(15,navBarHeight + 21, width - 30, height - navBarHeight - 21)];
    legalStuff.text = @"Long bunch of text goes here.";
    legalStuff.editable = NO;
    
    NSString* fileName = @"growPrivacyPolicy.txt";
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    
    NSString *myText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    legalStuff.text  = myText;
    
    [self.view addSubview:legalStuff];
    
}

@end
