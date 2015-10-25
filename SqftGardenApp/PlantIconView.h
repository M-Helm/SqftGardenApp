//
//  PlantIcon.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/13/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlantIconView : UIView
@property (nonatomic) UIColor* color;
@property (nonatomic) UIColor* fillColor;
@property (nonatomic) NSString* plantUuid;
@property (nonatomic) NSString *plantName;
@property (nonatomic) NSString *iconResource;
@property (nonatomic) NSString *isoIcon;
@property (nonatomic) NSString *photoResource;
@property (nonatomic) NSString *plantYield;
@property (nonatomic) NSString *plantClass;
@property (nonatomic) NSString *plantDescription;
@property (nonatomic) NSString *plantScientificName;
@property (nonatomic) NSArray *tipJsonArray;
@property (nonatomic) int position;
@property (nonatomic) int squareFeet;
@property (nonatomic) int maturity;
@property (nonatomic) int population;
@property (nonatomic) int plantingDelta;
@property (nonatomic) int startInsideDelta;
@property (nonatomic) int transplantDelta;

@property (nonatomic) bool startSeed;
@property (nonatomic) bool startInside;
@property (nonatomic) bool isIcon;
@property (nonatomic) bool isIsometric;
@property (nonatomic) bool isTall;

- (id)initWithFrame:(CGRect)frame withPlantUuid: (NSString *)plantUuid isIsometric:(bool)isIsometric;
- (void) setViewAsIcon: (bool)isIcon;
- (CGPoint) transformedTopLeft;
- (CGPoint) transformedTopRight;
- (CGPoint) transformedCenter;
@end