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

-(BOOL)setupApplication{
    dbManager = [DBManager getSharedDBManager];
    //[dbManager dropTable:@"plants"];
    //[dbManager dropTable:@"saves"];
    //[dbManager dropTable:@"plant_classes"];
    //[dbManager dropTable:@"version"];
    NSLog(@"plants exists %i rowCount %i", [dbManager checkTableExists:@"plants"], [dbManager getTableRowCount:@"plants"]);
    NSString *version = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSLog(@"check version: %@", version);
    [self initializeDB];
    
    return YES;
}

-(BOOL)initializeDB{

    //for some reason the app doesn't 'see' the db until we do a create
    //if not exists. hate it, but it's working for now...
    
    [self makePlantsTable];
    [self updatePlants];

    [self makeSavesTable];
    [self makeClassesTable];
    //[self moveSavedGardens];
    [self makeVersionTable];
    
    return YES;
}
-(BOOL)updatePlants{
    if([dbManager checkTableExists:@"plants"]){
        int plantCount = [dbManager getTableRowCount:@"plants"];
        
        //load the init plant list into an array
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *filePath = [path stringByAppendingPathComponent:dbManager.plantListName];
        NSString *contentStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSData *jsonData = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: &e];
        NSLog(@"plants in db %i plants in initList %i",plantCount, (int)jsonArray.count);
        
        //if we have more plants in the array, drop the old table and load the new list into the db
        if(plantCount < (int)jsonArray.count){
            [dbManager dropTable:@"plants"];
            [self makePlantsTable];
            
            [dbManager getInitPlants];
            NSLog(@"init plants");
        }
    }
    return YES;
}
-(BOOL)makeVersionTable{
    NSString *version = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    if([dbManager checkTableExists:@"version"] == false){
        [dbManager createTable:@"version"];
        [dbManager addColumn:@"version" :@"app_version" : @"char"];
    }
    else{
        NSDictionary *versionDict = [dbManager getAppVersion];
        NSLog(@"app version from db: %@", [versionDict objectForKey:@"version"]);
        //check versions and return if same
       
        if([@"version0" isEqualToString:[versionDict objectForKey:@"version"]])return YES;
        
        //move saves table
        [self moveSavedGardens];
        //update plants
        [dbManager dropTable:@"plants"];
        [self makePlantsTable];
        [self updatePlants];
        //update classes
        [dbManager dropTable:@"plant_classes"];
        [self makeClassesTable];
    }
    //update or create record for app version in db
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:@"1" forKey:@"id"];
    [dict setObject:version forKey:@"app_version"];
    [dbManager insertVersion:dict];
    NSLog(@"version table ct: %i",[dbManager getTableRowCount:@"version"]);
    NSDictionary *versionDict0 = [dbManager getAppVersion];
    NSLog(@"new app version from db: %@", [versionDict0 objectForKey:@"version"]);
    
    return YES;
}

-(BOOL)checkAppVersion{
    return true;
}

-(BOOL)makeClassesTable{
    if([dbManager checkTableExists:@"plant_classes"] == false){
        NSLog(@"Create classes");
        [dbManager createTable:@"plant_classes"];
        [dbManager addColumn:@"plant_classes" : @"name" :@"char(50)"];
        [dbManager addColumn:@"plant_classes" : @"timestamp" : @"int"];
        [dbManager addColumn:@"plant_classes" : @"icon" : @"char(150)"];
        [dbManager addColumn:@"plant_classes" : @"maturity" : @"int"];
        [dbManager addColumn:@"plant_classes" : @"population" : @"int"];
    }
    if([dbManager checkTableExists:@"plant_classes"] && [dbManager getTableRowCount:@"plant_classes"] < 2){
        [dbManager getInitPlantClasses];
    }
    return YES;
}

-(BOOL)makeSavesTable{
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
        
        //new cols for ver 1.1.1
        [dbManager addColumn:@"saves" : @"zone" : @"char"];
        [dbManager addColumn:@"saves" : @"override_zone" : @"int"];
        [dbManager addColumn:@"saves" : @"override_frost" : @"int"];
        
        [self createSampleGarden];
    }
    NSLog(@"saves count: %i", [dbManager getTableRowCount:@"saves"]);
    
    return YES;
}

-(BOOL)makePlantsTable{
    NSLog(@"makePlantsTable");
    if(![dbManager checkTableExists:@"plants"]){
        [dbManager createTable:@"plants"];
        NSLog(@"makePlantsTable -- 1");
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

-(BOOL)moveSavedGardens{
    NSLog(@"moving saves");
    //get all the saves
    NSArray *savesJson = [dbManager getBedSaveList];
    //drop the table
    [dbManager dropTable:@"saves"];
    //make a new table with the right columns
    [self makeSavesTable];
    //run through the array and re-save everything
    for(NSDictionary *dict in savesJson){
        SqftGardenModel *model = [[SqftGardenModel alloc]initWithDict:dict];
        [model saveModelWithOverWriteOption:YES];
    }
    return YES;
}

@end