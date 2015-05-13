//
//  BedView.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BedView : UIView
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, strong) UIColor* fillColor;
@property (nonatomic) int index;
@property (nonatomic) int primaryPlant;
@property (nonatomic) int secondaryPlant;
@property (nonatomic) int tertiaryPlant;
@end