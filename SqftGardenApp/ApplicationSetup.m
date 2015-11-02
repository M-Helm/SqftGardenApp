//
//  ApplicationSetup.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 7/28/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "ApplicationSetup.h"
#import "DBManager.h"
#import "SqftGardenModel.h"

@interface ApplicationSetup()

@end

@implementation ApplicationSetup

DBManager *dbManager;

-(BOOL)createDB{
    //NSLog(@"createDB");
    dbManager = [DBManager getSharedDBManager];
    //[dbManager dropTable:@"plants"];
    //[dbManager dropTable:@"saves"];
    //[dbManager dropTable:@"plant_classes"];
    
    if(![dbManager checkTableExists:@"plants"]){
        //NSLog(@"Create plants %i", [dbManager checkTableExists:@"plants"]);
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
        [dbManager addColumn:@"plants" : @"iso_icon" : @"char"];
        [dbManager addColumn:@"plants" : @"planting_delta" : @"int"];
        [dbManager addColumn:@"plants" : @"is_tall" : @"int"];
        [dbManager addColumn:@"plants" : @"uuid" : @"char"];
        [dbManager addColumn:@"plants" : @"square_feet" : @"int"];
        [dbManager addColumn:@"plants" : @"tip_json" : @"char"];
        [dbManager addColumn:@"plants" : @"start_seed" : @"int"];
        [dbManager addColumn:@"plants" : @"start_inside" : @"int"];
        [dbManager addColumn:@"plants" : @"start_inside_delta" : @"int"];
        [dbManager addColumn:@"plants" : @"transplant_delta" : @"int"];
    //new columns since version 1.0.0
    }
    
    if([dbManager checkTableExists:@"plants"]){
        NSLog(@"init plants");
        [dbManager getInitPlants];
    }
    
    if([dbManager checkTableExists:@"plant_classes"] == false){
        NSLog(@"Create classes");
        [dbManager createTable:@"plant_classes"];
        [dbManager addColumn:@"plant_classes" : @"name" :@"char(50)"];
        [dbManager addColumn:@"plant_classes" : @"timestamp" : @"int"];
        [dbManager addColumn:@"plant_classes" : @"icon" : @"char(150)"];
        [dbManager addColumn:@"plant_classes" : @"maturity" : @"int"];
        [dbManager addColumn:@"plant_classes" : @"population" : @"int"];
    }
    
    if([dbManager checkTableExists:@"plant_classes"]){
        [dbManager getInitPlantClasses];
    }
    
    if([dbManager checkTableExists:@"saves"] == false){
        NSLog(@"create saves");
        [dbManager createTable:@"saves"];
        [dbManager addColumn:@"saves" : @"rows" : @"int"];
        [dbManager addColumn:@"saves" : @"columns" : @"int" ];
        [dbManager addColumn:@"saves" : @"bedstate" : @"varchar" ];
        [dbManager addColumn:@"saves" : @"timestamp" : @"int"];
        [dbManager addColumn:@"saves" : @"name" : @"char(140)"];
        [dbManager addColumn:@"saves" : @"unique_id" : @"char"];
        [dbManager addColumn:@"saves" : @"planting_date" : @"char"];
        [self createSampleGarden];
    }
    return YES;
}

-(BOOL)createSampleGarden{
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *filePath = [path stringByAppendingPathComponent:@"sampleGarden.txt"];
    NSString *contentStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: &e];
    NSDictionary *dict = [jsonArray objectAtIndex:0];
    SqftGardenModel *model = [[SqftGardenModel alloc]initWithDict:dict];
    [model saveModelWithOverWriteOption:YES];
    return YES;
}

@end