//
//  ClassIconView.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/9/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassIconView : UIView
- (id)initWithFrame:(CGRect)frame : (int)classIndex;
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, strong) UIColor* fillColor;
@property (nonatomic) int index;
@property (nonatomic) NSString *className;
@property (nonatomic) NSString *iconResource;
@property (nonatomic) int maturity;
@property (nonatomic) int population;

@end