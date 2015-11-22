//
//  PlantIcon.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/13/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlantModel.h"

@interface PlantIconView : UIView
@property (nonatomic) NSString* plantUuid;
@property (nonatomic) PlantModel* model;
@property (nonatomic) UIColor* color;
@property (nonatomic) UIColor* fillColor;

@property (nonatomic) bool isIcon;
@property (nonatomic) bool isIsometric;


- (id)initWithFrame:(CGRect)frame withPlantUuid: (NSString *)plantUuid isIsometric:(bool)isIsometric;
- (void) setViewAsIcon: (bool)isIcon;
- (void) setImageGrid : (int) rowCount : (int) columnCount;
- (CGPoint) transformedTopLeft;
- (CGPoint) transformedTopRight;
- (CGPoint) transformedCenter;
@end