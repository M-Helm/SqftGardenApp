//
//  PlantIcon.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/13/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlantIconView : UIView
- (id)initWithFrame:(CGRect)frame : (int)plantIndex;
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, strong) UIColor* fillColor;
@property (nonatomic) int index;
@property (nonatomic)NSString *plantName;
@property (nonatomic)NSString *iconResource;
@property (nonatomic)int maturity;
@property (nonatomic)int population;
@property (nonatomic)int plantId;

@end