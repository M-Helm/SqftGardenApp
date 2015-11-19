//
//  ZoneSelectView.m
//  GrowSquared
//
//  Created by Matthew Helm on 11/18/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import "ZoneSelectView.h"
#import "ApplicationGlobals.h"
#import "PlantingDateViewController.h"

@interface ZoneSelectView()

@end

@implementation ZoneSelectView

ApplicationGlobals *appGlobals;
UIViewController *viewController;
NSString *selectedZone;


- (void)createZonePicker:(id)sender{
    [self buildZoneArray];
    self.userInteractionEnabled = YES;
    viewController = sender;
    appGlobals = [ApplicationGlobals getSharedGlobals];
    //if(appGlobals.globalGardenModel.zone != nil)selectedZone=appGlobals.globalGardenModel.zone;
    
    UIPickerView *pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 300, 216)];
    //pickerView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:pickerView];
    [pickerView setDataSource: self];
    [pickerView setDelegate: self];
    pickerView.showsSelectionIndicator = YES;
    [pickerView selectRow:8 inComponent:0 animated:NO];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    toolBar.barStyle = UIBarStyleDefault;
    toolBar.userInteractionEnabled = YES;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelZonePicker:)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissZonePicker:)];
    [spacer setWidth:self.frame.size.width/3];
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton, spacer, doneButton, nil]];
    [self addSubview:toolBar];
}

- (void) removeView{
    if([viewController class] == [PlantingDateViewController class]){
        PlantingDateViewController *dateVC = (PlantingDateViewController *)viewController;
        [dateVC showZonePickerView];
    }
    [self removeFromSuperview];
}

- (void) cancelZonePicker:(id)sender{
    [self removeView];
}
- (void) dismissZonePicker:(id)sender{
    if(selectedZone == nil)selectedZone = @"5a";
    appGlobals.globalGardenModel.zone = selectedZone;
    NSLog(@"zone on dismiss: %@", selectedZone);
    [self removeView];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (void)pickerView:(UIPickerView *)view didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSDictionary *dict = [self.zoneArray objectAtIndex:row];
    selectedZone = [dict objectForKey:@"zone"];
    NSLog(@"selected zone: %@", [dict objectForKey:@"zone"]);
    
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.zoneArray.count;
}

-(NSArray *)buildZoneArray{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *filePath = [path stringByAppendingPathComponent:@"frost_dates.txt"];
    NSString *contentStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    self.zoneArray = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: &e];
    return self.zoneArray;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary *dict = [self.zoneArray objectAtIndex:row];
    NSString *title = [NSString stringWithFormat:@"Zone: %@",[dict objectForKey:@"zone"]];
    return title;
    
}

@end
