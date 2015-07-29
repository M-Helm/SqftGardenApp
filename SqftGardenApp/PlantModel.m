//
//  PlantModel.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/12/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "PlantModel.h"
#import "DBManager.h"

@implementation PlantModel

DBManager *dbManager;

- (id)initWithName : (NSString *)plantName {
    self = [super init];
    if (self) {
        dbManager = [DBManager getSharedDBManager];
        NSDictionary *json = [dbManager getPlantDataByName:plantName];
        _iconResource = [json objectForKey:@"icon"];
        _name = [json objectForKey:@"name"];
        NSString *str = [json objectForKey:@"maturity"];
        _maturity = str.intValue;
        
    }
    return self;
}
- (id)initWithId : (int)plantID {
    self = [super init];
    if (self) {
        dbManager = [DBManager getSharedDBManager];
        
        NSDictionary *json = [dbManager getPlantDataById:plantID];
        _iconResource = [json objectForKey:@"icon"];
        _name = [json objectForKey:@"name"];
        NSString *str = [json objectForKey:@"maturity"];
        _maturity = str.intValue;
        
    }
    return self;
}

@end