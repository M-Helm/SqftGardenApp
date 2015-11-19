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
#import "PlantingDateViewController.h"

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
    if(selectedDate == nil){
        selectedDate = [self getInitialDate];
    }
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
    if([viewController class] == [PlantingDateViewController class]){
        PlantingDateViewController *dateVC = (PlantingDateViewController *)viewController;
        //[dateVC setDatePickerIsOpen:NO];
        [dateVC showDatePickerView];
    }
    [self removeFromSuperview];
}

- (void)dismissDatePicker:(id)sender {
    if(selectedDate == nil){
        selectedDate = [self getInitialDate];
    }
    appGlobals.globalGardenModel.frostDate = selectedDate;
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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,34,320,44)];
    [label setFont: [UIFont boldSystemFontOfSize:18]];
    label.textColor = [UIColor blackColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.3];
    label.text = @"Estimate the date of the last frost:";
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];

    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.bounds.size.height+44, 320, 216)];
    datePicker.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.6];
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

}
- (NSDate *)getInitialDate{
    NSDate *compareDate = [[NSDate alloc]initWithTimeIntervalSince1970:2000];
    if([appGlobals.globalGardenModel.frostDate compare:compareDate] == NSOrderedAscending) {
        //no date selected return may 1 next year as standard date
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setDay:1];
        [comps setMonth:5];
        [comps setYear:2016];
        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];
        return date;
    }else{
        //a date is selected
        return appGlobals.globalGardenModel.frostDate;
    }
}



@end