//
//  DBManager.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/21/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject
{
    NSString *databasePath;
}

+ (DBManager*)getSharedDBManager;
- (BOOL) createTable:(NSString *)tableName;
- (BOOL) checkTableExists:(NSString *)tableName;
- (BOOL) dropTable:(NSString*)table;
- (BOOL) savePlantData:(NSDictionary *)msgJSON;
- (BOOL) addColumn:(NSString *)tableName : (NSString *)columnName : (NSString *) columnType;
- (int) getTableRowCount:(NSString *)tableName;
- (NSArray*) getInitPlants;
- (NSDictionary *) getPlantDataByName:(NSString *) name;
- (NSDictionary *) getPlantDataById:(int) plantID;
- (BOOL) saveBed:(NSDictionary *)msgJSON;

@end
