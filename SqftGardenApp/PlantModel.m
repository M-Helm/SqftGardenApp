//
//  PlantModel.m
//  GrowSquared
//
//  Created by Matthew Helm on 11/22/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import "PlantModel.h"
#import "DBManager.h"

@interface PlantModel()

@end

@implementation PlantModel

NSString * const PLANT_DEFAULT_ICON = @"ic_cereal_wheat_256.png";
NSDictionary *json;

- (id) initWithUUID:(NSString *)uuid {
    self = [super init];
    DBManager *dbManager = [DBManager getSharedDBManager];
    json = [dbManager getPlantDataByUuid:uuid];
    [self commonInit];
    return self;
}

- (void) commonInit{
    self.plantUuid = [json objectForKey:@"uuid"];
    self.plantName = [json objectForKey:@"name"];
    self.plantClass = [json objectForKey:@"class"];
    if(self.plantClass == nil)self.plantClass = self.plantName;
    self.iconResource = [json objectForKey:@"icon"];
    self.photoResource = [json objectForKey:@"photo"];
    self.plantDescription = [json objectForKeyedSubscript:@"description"];
    self.plantScientificName = [json objectForKey:@"scientific_name"];
    self.plantYield = [json objectForKey:@"yield"];
    NSString *str = [json objectForKey:@"maturity"];
    self.maturity = str.intValue;
    NSString *population = [json objectForKey:@"population"];
    self.population = population.intValue;

    NSString *delta = [json objectForKey:@"plantingDelta"];
    self.plantingDelta = delta.intValue;
    NSString *seed = [json objectForKey:@"start_seed"];
    self.startSeed = seed.intValue;
    NSString *inside = [json objectForKey:@"start_inside"];
    self.startInside = inside.intValue;
    NSString *insideDelta = [json objectForKey:@"start_inside_delta"];
    self.startInsideDelta = insideDelta.intValue;
    NSString *transDelta = [json objectForKey:@"transplant_delta"];
    self.transplantDelta = transDelta.intValue;
    NSString *sqFeet = [json objectForKey:@"square_feet"];
    self.squareFeet = sqFeet.intValue;
    
    NSString *jsonString = [json objectForKey:@"tip_json"];
    self.tipJsonArray = [jsonString componentsSeparatedByString:@"{"];
    
    self.isoIcon =[json objectForKey:@"isoIcon"];
    
    NSString *tall = [json objectForKey:@"isTall"];
    self.isTall = tall.intValue;
    
}

@end