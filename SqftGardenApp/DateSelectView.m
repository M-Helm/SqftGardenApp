//
//  DateSelectViewController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/18/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DateSelectView.h"
#import "EditBedViewController.h"
#import "ApplicationGlobals.h"
#import "DataPresentationTableViewController.h"

@interface DateSelectView()

@end

@implementation DateSelectView
UIViewController *viewController;
ApplicationGlobals *appGlobals;
NSDate* selectedDate;


- (void)changeDate:(UIDatePicker *)sender {
    //NSLog(@"New Date: %@", sender.date);
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormat stringFromDate:sender.date];
    NSDate *date = [dateFormat dateFromString:dateString];
    selectedDate = date;
}

- (void)removeViews:(id)object {
    if(selectedDate == nil)selectedDate = [[NSDate alloc]initWithTimeIntervalSince1970:0];
    for(UIView *subview in self.subviews){
        [subview removeFromSuperview];
    }

    
    if([viewController class] == [EditBedViewController class]){
        EditBedViewController *editVC = (EditBedViewController *)viewController;
        [editVC setDatePickerIsOpen:NO];
        [editVC updatePlantingDate:selectedDate];
        [editVC initViews];
        return;
    }
    if([viewController class] == [DataPresentationTableViewController class]){
        DataPresentationTableViewController *dataVC = (DataPresentationTableViewController *)viewController;
        [dataVC setDatePickerIsOpen:NO];
        [dataVC.tableView reloadData];
    }
    [self removeFromSuperview];
}

- (void)dismissDatePicker:(id)sender {
    if(selectedDate == nil){
        NSDate *date = [[NSDate alloc]initWithTimeIntervalSinceNow:0];
        selectedDate = date;
    }
    NSLog(@"New Date: %@", selectedDate);
    appGlobals.globalGardenModel.plantingDate = selectedDate;
    [appGlobals.globalGardenModel saveModelWithOverWriteOption:YES];
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self viewWithTag:9].alpha = 0;
    //[self viewWithTag:10].frame = datePickerTargetFrame;
    //[self viewWithTag:11].frame = toolbarTargetFrame;
    [self viewWithTag:10].alpha = 0;
    [self viewWithTag:11].alpha = 0;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
}
- (void)cancelDatePicker:(id)sender {
    //CGRect toolbarTargetFrame = CGRectMake(0, self.bounds.size.height, 320, 44);
    //CGRect datePickerTargetFrame = CGRectMake(0, self.bounds.size.height+44, 320, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self viewWithTag:9].alpha = 0;
    [self viewWithTag:10].alpha = 0;
    [self viewWithTag:11].alpha = 0;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
}

- (void)createDatePicker:(id)sender {
    self.userInteractionEnabled = YES;
    viewController = sender;
    appGlobals = [ApplicationGlobals getSharedGlobals];
    if ([self viewWithTag:9]) {
        return;
    }

    float width = self.frame.size.width;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,34,300,44)];
    [label setFont: [UIFont boldSystemFontOfSize:18]];
    label.textColor = [UIColor blackColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.3];
    label.text = @"Estimate the date of the last frost:";
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];

    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.bounds.size.height+44, 320, 216)];
    
    UIView *lightView = [[UIView alloc] initWithFrame:self.bounds];
    lightView.userInteractionEnabled = YES;
    lightView.alpha = 0;
    lightView.backgroundColor = [UIColor whiteColor];
    lightView.tag = 9;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)];
    [lightView addGestureRecognizer:tapGesture];
    [self addSubview:lightView];
    datePicker.tag = 10;
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.userInteractionEnabled = YES;
    
    [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:datePicker];
    datePicker.date = [self getInitialDate];

    toolBar.tag = 11;
    toolBar.barStyle = UIBarStyleDefault;
    toolBar.userInteractionEnabled = YES;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelDatePicker:)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePicker:)];
    
    [spacer setWidth:width/3];
    
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton, spacer, doneButton, nil]];
    [self addSubview:toolBar];
    [self addSubview:label];
    
    
    //toolBar.frame = toolbarTargetFrame;
    
    //[UIView beginAnimations:@"MoveIn" context:nil];
    //lightView.alpha = 0.5;
    //[UIView commitAnimations];
}
- (NSDate *)getInitialDate{
    NSDate *compareDate = [[NSDate alloc]initWithTimeIntervalSince1970:2000];
    if([appGlobals.globalGardenModel.plantingDate compare:compareDate] == NSOrderedAscending) {
        //no date selected
        int seconds = (24*60*60)*175;
        return [[NSDate alloc]initWithTimeIntervalSinceNow:seconds];
    }else{
        //a date is selected
        return appGlobals.globalGardenModel.plantingDate;
    }
}


@end