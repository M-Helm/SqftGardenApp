//
//  DateSelectViewController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/18/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DateSelectViewController.h"

@interface DateSelectViewController()

@end

@implementation DateSelectViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    //[self createDatePicker:self.navigationController];
}
- (void)changeDate:(UIDatePicker *)sender {
    NSLog(@"New Date: %@", sender.date);
}

- (void)removeViews:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
}

- (void)dismissDatePicker:(id)sender {
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:9].alpha = 0;
    [self.view viewWithTag:10].frame = datePickerTargetFrame;
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
}

- (void)createDatePicker:(id)sender {
    if ([self.view viewWithTag:9]) {
        return;
    }
    float topOffset = self.navigationController.navigationBar.frame.size.height * 1.5;
    CGRect toolbarTargetFrame = CGRectMake(0,topOffset, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0,topOffset + 44, 320, 216);
    
    UIView *lightView = [[UIView alloc] initWithFrame:self.view.bounds];
    lightView.alpha = 0;
    lightView.backgroundColor = [UIColor whiteColor];
    lightView.tag = 9;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)];
    [lightView addGestureRecognizer:tapGesture];
    [self.view addSubview:lightView];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
    datePicker.tag = 10;
    datePicker.datePickerMode = UIDatePickerModeDate;
    //datePicker.layer.borderWidth = 3;
    //datePicker.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datePicker];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)];
    toolBar.tag = 11;
    toolBar.barStyle = UIBarStyleDefault;
    //toolBar.layer.borderWidth = 2;
    //toolBar.layer.borderColor = [UIColor greenColor].CGColor;
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePicker:)];
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
    [self.view addSubview:toolBar];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    toolBar.frame = toolbarTargetFrame;
    datePicker.frame = datePickerTargetFrame;
    lightView.alpha = 0.5;
    [UIView commitAnimations];
}


@end