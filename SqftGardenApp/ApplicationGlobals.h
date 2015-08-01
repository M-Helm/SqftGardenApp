//
//  ApplicationGlobals.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/14/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PlantIconView.h"

@interface ApplicationGlobals : NSObject
+ (ApplicationGlobals*)getSharedGlobals;
@property (nonatomic) int selectedCell;
@property (nonatomic) PlantIconView* selectedPlant;
@property (nonatomic) int bedDimension;
@property (nonatomic) NSMutableArray* bedLocationArray;

@end
