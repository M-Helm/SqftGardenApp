//
//  PlantModel.h
//  GrowSquared
//
//  Created by Matthew Helm on 11/22/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlantModel : NSObject

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
@property (nonatomic) bool isTall;

- (id) initWithUUID:(NSString *)uuid;

@end