//
//  SizeBedViewController.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 8/23/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Google/Analytics.h>
#include <AudioToolbox/AudioToolbox.h>
#import "SqftGardenModel.h"


@interface SizeBedViewController : UIViewController
@property(nonatomic) int bedRowCount;
@property(nonatomic) int bedColumnCount;
@property(nonatomic) int bedCellCount;
@property(nonatomic) int maxRowCount;
@property(nonatomic) int maxColumnCount;
@property(nonatomic)SqftGardenModel *currentGardenModel;
@property(nonatomic) UIView *bedFrameView;
@property(nonatomic) UILabel *sizeLabel;
@property(nonatomic) UIView *titleView;
@property(nonatomic) UIImageView *touchIcon;

@property(nonatomic) int topOffset;
@property(nonatomic) int sideOffset;
@property(nonatomic) float heightMultiplier;

@end
