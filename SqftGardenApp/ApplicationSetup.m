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
    //[dbManager dropTable:@"plants"];
    //[dbManager dropTable:@"saves"];
    
    [dbManager createTable:@"plants"];
    [dbManager addColumn:@"plants" : @"name" : @"char(50)"];
    [dbManager addColumn:@"plants" : @"timestamp" : @"int"];
    [dbManager addColumn:@"plants" : @"icon" : @"char(150)"];
    [dbManager addColumn:@"plants" : @"maturity" : @"int"];
    [dbManager addColumn:@"plants" : @"population" : @"int"];
    
    if([dbManager checkTableExists:@"plants"]){
        [dbManager getInitPlants];
    }
    
    if([dbManager checkTableExists:@"saves"] == false){
        NSLog(@"no saves table exists");
        [dbManager createTable:@"saves"];
        [dbManager addColumn:@"saves" : @"rows" : @"int"];
        [dbManager addColumn:@"saves" : @"columns" : @"int" ];
        [dbManager addColumn:@"saves" : @"bedstate" : @"varchar" ];
        [dbManager addColumn:@"saves" : @"timestamp" : @"int"];
        [dbManager addColumn:@"saves" : @"name" : @"char(140)"];
    }
    
    return YES;
}

@end