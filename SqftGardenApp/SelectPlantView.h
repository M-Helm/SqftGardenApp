//
//  PlantSelectView.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/12/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//


#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>
//#import "EditBedViewController.h"

@interface SelectPlantView : UIScrollView
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, strong) UIColor* fillColor;
//@property (nonatomic) UIView* mainView;
//@property (nonatomic) EditBedViewController* editBedVC;
@property (nonatomic) NSString *selectedClass;
@property(nonatomic) int topOffset;
@property(nonatomic) int sideOffset;
@property(nonatomic) float heightMultiplier;
- (id)initWithFrame:(CGRect)frame andEditBedVC:(UIViewController*)editBed;
@property(nonatomic) bool datePickerIsOpen;
@property(nonatomic) bool isoViewIsOpen;


@end