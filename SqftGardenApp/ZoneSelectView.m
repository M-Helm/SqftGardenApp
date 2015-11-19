//
//  ZoneSelectView.m
//  GrowSquared
//
//  Created by Matthew Helm on 11/18/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import "ZoneSelectView.h"
#import "ApplicationGlobals.h"

@interface ZoneSelectView()

@end

@implementation ZoneSelectView

ApplicationGlobals *appGlobals;
UIViewController *viewController;

- (void)createZonePicker:(id)sender{
    self.userInteractionEnabled = YES;
    viewController = sender;
    appGlobals = [ApplicationGlobals getSharedGlobals];
    UIPickerView *pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 216)];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (void)pickerView:(UIPickerView *)view didSelectRow:(NSInteger)row inComponent:(NSInteger)component{

}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 22;
}

@end
