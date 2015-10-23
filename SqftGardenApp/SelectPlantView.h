//
//  PlantSelectView.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/12/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//


#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>

@interface SelectPlantView : UIScrollView
@property(nonatomic) bool datePickerIsOpen;
@property(nonatomic) bool isoViewIsOpen;
@property(nonatomic) bool toolBarHidden;
@property(nonatomic) bool showTouches;

@property (nonatomic, strong) UIColor* color;
@property (nonatomic, strong) UIColor* fillColor;
@property(nonatomic) UIImageView *touchIcon;
@property (nonatomic) NSString *selectedClass;

@property(nonatomic) int topOffset;
@property(nonatomic) int sideOffset;
@property(nonatomic) float heightMultiplier;

- (id)initWithFrame:(CGRect)frame andEditBedVC:(UIViewController*)editBed;

@end