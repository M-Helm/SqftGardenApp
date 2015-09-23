//
//  ApplicationSetup.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 7/28/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "ApplicationSetup.h"
#import "DBManager.h"

@interface ApplicationSetup()

@end

@implementation ApplicationSetup

DBManager *dbManager;

-(BOOL)createDB{
    dbManager = [DBManager getSharedDBManager];
    [dbManager dropTable:@"plants"];
    //[dbManager dropTable:@"saves"];
    [dbManager dropTable:@"plant_classes"];
    
    
    [dbManager createTable:@"plants"];
    [dbManager addColumn:@"plants" : @"name" : @"char(50)"];
    [dbManager addColumn:@"plants" : @"timestamp" : @"int"];
    [dbManager addColumn:@"plants" : @"icon" : @"char(150)"];
    [dbManager addColumn:@"plants" : @"maturity" : @"int"];
    [dbManager addColumn:@"plants" : @"population" : @"int"];
    [dbManager addColumn:@"plants" : @"class" : @"char(50)"];
    [dbManager addColumn:@"plants" : @"description" : @"char"];
    [dbManager addColumn:@"plants" : @"scientific_name" : @"char"];
    [dbManager addColumn:@"plants" : @"photo" : @"char(150)"];
    [dbManager addColumn:@"plants" : @"yield" : @"char"];
    
    if([dbManager checkTableExists:@"plants"]){
        [dbManager getInitPlants];
    }
    
    [dbManager createTable:@"plant_classes"];
    [dbManager addColumn:@"plant_classes" : @"name" :@"char(50)"];
    [dbManager addColumn:@"plant_classes" : @"timestamp" : @"int"];
    [dbManager addColumn:@"plant_classes" : @"icon" : @"char(150)"];
    [dbManager addColumn:@"plant_classes" : @"maturity" : @"int"];
    [dbManager addColumn:@"plant_classes" : @"population" : @"int"];
    
    if([dbManager checkTableExists:@"plant_classes"]){
        [dbManager getInitPlantClasses];
    }
    
    if([dbManager checkTableExists:@"saves"] == false){
        NSLog(@"no saves table exists");
        [dbManager createTable:@"saves"];
        [dbManager addColumn:@"saves" : @"rows" : @"int"];
        [dbManager addColumn:@"saves" : @"columns" : @"int" ];
        [dbManager addColumn:@"saves" : @"bedstate" : @"varchar" ];
        [dbManager addColumn:@"saves" : @"timestamp" : @"int"];
        [dbManager addColumn:@"saves" : @"name" : @"char(140)"];
        [dbManager addColumn:@"saves" : @"unique_id" : @"char"];
        [dbManager addColumn:@"saves" : @"planting_date" : @"char"];
    }
    return YES;
}

@end