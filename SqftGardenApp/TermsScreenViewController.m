//
//  TermsScreenViewController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/16/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "TermsScreenViewController.h"

#define URLEMail @"mailto:info@growsquared.net?subject=title&body=content"

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
    
    UILabel *emailLabel = [[UILabel alloc]initWithFrame:CGRectMake(5,navBarHeight,self.view.frame.size.width - 10, 25)];
    emailLabel.text = @"Email Us: info@growsquared.net";
    emailLabel.textAlignment = NSTextAlignmentCenter;
    emailLabel.textColor = [UIColor blueColor];
    emailLabel.font = [UIFont systemFontOfSize: 15];
    emailLabel.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.75];
    emailLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleFingerTapOpen =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleEmailSingleTap)];
    [emailLabel addGestureRecognizer:singleFingerTapOpen];
    [self.view addSubview:emailLabel];
    
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15,navBarHeight + 30,width-30, 20)];
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

-(void) handleEmailSingleTap{
    NSString *url = [URLEMail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"termsViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

@end
