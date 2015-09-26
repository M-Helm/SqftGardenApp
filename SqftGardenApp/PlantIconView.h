//
//  PlantIcon.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/13/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlantIconView : UIView
- (id)initWithFrame:(CGRect)frame withPlantId: (int)plantIndex isIsometric:(bool)isIsometric;
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, strong) UIColor* fillColor;
//@property (nonatomic) UILabel* label;
@property (nonatomic) int position;
@property (nonatomic) NSString *plantName;
@property (nonatomic) NSString *iconResource;
@property (nonatomic) NSString *isoIcon;
@property (nonatomic) NSString *photoResource;
@property (nonatomic) NSString *plantYield;
@property (nonatomic) int maturity;
@property (nonatomic) int population;
@property (nonatomic) int plantId;
@property (nonatomic) NSString *plantClass;
@property (nonatomic) NSString *plantDescription;
@property (nonatomic) NSString *plantScientificName;
@property (nonatomic) bool isIcon;
@property (nonatomic) bool isIsometric;
-(void)setViewAsIcon:(bool)isIcon;
- (CGPoint) transformedTopLeft;

@end