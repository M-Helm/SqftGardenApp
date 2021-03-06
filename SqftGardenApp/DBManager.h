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
- (BOOL) insertVersion:(NSDictionary *)msgJSON;
- (int) getTableRowCount:(NSString *)tableName;
- (NSArray*) getInitPlants;
- (NSArray*) getInitPlantClasses;
- (NSDictionary *) getClassDataById:(int) classID;
- (NSDictionary *) getPlantDataById:(int) plantID;
- (NSDictionary *) getPlantDataByUuid:(NSString *) uuid;
- (BOOL) overwriteSavedGarden:(NSDictionary *)msgJSON;
- (NSMutableArray *) getBedSaveList;
- (NSMutableDictionary *) getGardenByLocalId : (int) index;
- (int) saveGarden:(NSDictionary *)msgJSON;
- (BOOL) deleteGardenWithId:(int)localId;
- (NSMutableDictionary *) getGardenByUniqueId : (NSString *) uuid;
- (NSMutableArray *) getPlantUuidsForClass:(NSString *)class;
- (NSMutableDictionary *) getAppVersion;

@property(nonatomic) int bedRowCount;
@property(nonatomic) NSString *plantListName;
@property(nonatomic) NSString *classListName;

@end
