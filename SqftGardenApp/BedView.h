//
//  BedView.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlantIconView.h"

@interface BedView : UIView
- (id)initWithFrame:(CGRect)frame isIsometric:(bool)isIso;
@property (nonatomic)bool isIso;
- (CGPoint) transformedTopLeft;
- (CGPoint) transformedTopRight;
- (CGPoint) transformedCenter;

@end