//
//  PlantIcon.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/13/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlantIconView : UIView
- (id)initWithFrame:(CGRect)frame withPlantUuid: (NSString *)plantUuid isIsometric:(bool)isIsometric;
@property (nonatomic) NSString* plantUuid;
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, strong) UIColor* fillColor;
@property (nonatomic) int position;
@property (nonatomic) NSString *plantName;
@property (nonatomic) NSString *iconResource;
@property (nonatomic) NSString *isoIcon;
@property (nonatomic) NSString *photoResource;
@property (nonatomic) NSString *plantYield;
@property (nonatomic) int maturity;
@property (nonatomic) int population;
//@property (nonatomic) int plantId;
@property (nonatomic) NSString *plantClass;
@property (nonatomic) NSString *plantDescription;
@property (nonatomic) NSString *plantScientificName;
@property (nonatomic) bool isIcon;
@property (nonatomic) NSString *tip0;
@property (nonatomic) NSString *tip1;
@property (nonatomic) NSString *tip2;
@property (nonatomic) NSString *tip3;
@property (nonatomic) NSString *tip4;
@property (nonatomic) NSString *tip5;
@property (nonatomic) NSString *tip6;
@property (nonatomic) bool isIsometric;
@property (nonatomic) bool isTall;
@property (nonatomic) int plantingDelta;
-(void)setViewAsIcon:(bool)isIcon;
- (CGPoint) transformedTopLeft;
- (CGPoint) transformedTopRight;
- (CGPoint) transformedCenter;
@end