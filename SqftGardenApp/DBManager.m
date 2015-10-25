//
//  DBManager.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/21/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

//
//  DBManager.m
//  howhimi
//
//  Created by Matthew Helm on 4/11/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "DBManager.h"

@interface DBManager()

@end

//static DBManager *sharedDBManager = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;
static NSString *appName = @"sqftGardenApp";
NSString* const initPlantListName = @"init_plants.txt";
NSString* const initClassListName = @"init_plant_classes.txt";

@implementation DBManager

+ (id)getSharedDBManager {
    static DBManager *sharedDBManager = nil;
    @synchronized(self) {
        if (sharedDBManager == nil)
            sharedDBManager = [[self alloc] init];
    }
    return sharedDBManager;
}

-(NSArray*)getInitPlants{
    //[self createTable:@"plants"];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *filePath = [path stringByAppendingPathComponent:initPlantListName];
    NSString *contentStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSData *jsonData = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: &e];
    //check if data exists in table and return the array w/o saving if so.
    if([self getTableRowCount:@"plants"] > 1)return jsonArray;
    int i = 0;
    while (i < [jsonArray count]){
        NSMutableDictionary *json = [jsonArray objectAtIndex:i];
        json[@"timestamp"] = @0;
        [self savePlantData:json];
        i++;
    }
    return jsonArray;
}
-(NSArray*)getInitPlantClasses{
    //[self createTable:@"plants"];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *filePath = [path stringByAppendingPathComponent:initClassListName];
    NSString *contentStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSData *jsonData = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *e = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: &e];
    //check if data exists in table and return the array w/o saving if so.
    if([self getTableRowCount:@"plant_classes"] > 1)return jsonArray;
    int i = 0;
    while (i < [jsonArray count]){
        NSMutableDictionary *json = [jsonArray objectAtIndex:i];
        json[@"timestamp"] = @0;
        [self saveClassData:json];
        i++;
    }
    return jsonArray;
}

-(BOOL) addColumn:(NSString *)tableName : (NSString *)columnName : (NSString *) columnType {
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: appName]];
    BOOL isSuccess = NO;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        isSuccess = YES;
        char *errMsg;
        NSString *sql_str = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", tableName, columnName, columnType];
        const char *sql_stmt = [sql_str UTF8String];
        
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
            != SQLITE_OK)
        {
            isSuccess = NO;

        }
        //sqlite3_finalize(statement);
        sqlite3_close(database);
        return  isSuccess;
    }
    return isSuccess;
}

-(BOOL)createTable:(NSString *)tableName{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: appName]];
    BOOL isSuccess = NO;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        isSuccess = YES;
        char *errMsg;
        NSString *sql_str = [NSString stringWithFormat:@"create table if not exists %@ (local_id integer primary key autoincrement)", tableName];
        const char *sql_stmt = [sql_str UTF8String];
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
            != SQLITE_OK)
        {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
        //sqlite3_finalize(statement);
        sqlite3_close(database);
        return  isSuccess;
    }
    return isSuccess;
}
- (BOOL) saveClassData:(NSDictionary *)msgJSON{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into plant_classes (name, timestamp, icon, maturity, population) values(\"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                               [msgJSON objectForKey:@"name"],
                               [msgJSON objectForKey:@"timestamp"],
                               [msgJSON objectForKey:@"icon"],
                               [msgJSON objectForKey:@"maturity"],
                               [msgJSON objectForKey:@"population"]];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE){
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return true;
        }
        else{
            NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(database));
            sqlite3_close(database);
            return false;
        }
    }
    sqlite3_close(database);
    NSLog(@"failed to save message");
    return false;
}

- (BOOL) savePlantData:(NSDictionary *)msgJSON{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into plants (name, timestamp, icon, maturity, population, class, description, scientific_name, photo, yield, iso_icon, planting_delta, is_tall, uuid, square_feet, tip_json, start_seed, start_inside, start_inside_delta, transplant_delta) values(\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                            [msgJSON objectForKey:@"name"],
                            [msgJSON objectForKey:@"timestamp"],
                            [msgJSON objectForKey:@"icon"],
                            [msgJSON objectForKey:@"maturity"],
                            [msgJSON objectForKey:@"population"],
                            [msgJSON objectForKey:@"class"],
                            [msgJSON objectForKey:@"description"],
                            [msgJSON objectForKey:@"scientific_name"],
                            [msgJSON objectForKey:@"photo"],
                            [msgJSON objectForKey:@"yield"],
                            [msgJSON objectForKey:@"iso_icon"],
                            [msgJSON objectForKey:@"planting_delta"],
                            [msgJSON objectForKey:@"is_tall"],
                            [msgJSON objectForKey:@"uuid"],
                            [msgJSON objectForKey:@"square_feet"],
                            [msgJSON objectForKey:@"tip_json"],
                            [msgJSON objectForKey:@"start_seed"],
                            [msgJSON objectForKey:@"start_inside"],
                            [msgJSON objectForKey:@"start_inside_delta"],
                            [msgJSON objectForKey:@"transplant_delta"]];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"plant saved to db with Delta property: %@", [msgJSON objectForKey:@"start_inside_delta"]);
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return true;
        }
        else{
            NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(database));
            sqlite3_close(database);
            return false;
        }
    }
    sqlite3_close(database);
    NSLog(@"failed to save message");
    return false;
}

- (BOOL) overwriteSavedGarden:(NSDictionary *)msgJSON{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT or REPLACE into saves (local_id, rows, columns, bedstate, timestamp, name, unique_id, planting_date) values(\"%@\", \"%@\",\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                            [msgJSON objectForKey:@"local_id"],
                            [msgJSON objectForKey:@"rows"],
                            [msgJSON objectForKey:@"columns"],
                            [msgJSON objectForKey:@"bedstate"],
                            [msgJSON objectForKey:@"timestamp"],
                            [msgJSON objectForKey:@"name"],
                            [msgJSON objectForKey:@"unique_id"],
                            [msgJSON objectForKey:@"planting_date"]];
                               
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE){
            //NSLog(@"bed saved to db");
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return true;
        }
        else{
            NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(database));
            sqlite3_close(database);
            return false;
        }
    }
    sqlite3_close(database);
    NSLog(@"failed to save message");
    return false;
}
- (BOOL) deleteGardenWithId:(int)localId{
    BOOL success = NO;
    const char *dbpath = [databasePath UTF8String];
    
    NSLog(@"DELETING RECORD # %i", localId);
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *deleteSQL = [NSString stringWithFormat:@"delete from saves where local_id='%i'", localId];

        
        const char *delete_stmt = [deleteSQL UTF8String];
        char *errMsg;
        //if(sqlite3_prepare_v2(database, delete_stmt,-1, &statement, NULL) == SQLITE_OK){
        sqlite3_exec(database, delete_stmt, NULL, NULL, &errMsg);
            /*
            sqlite3_finalize(statement);
            sqlite3_close(database);
            NSLog(@"record deleted");
            success = YES;
        }else{
            NSLog(@"Error while deleting data. '%s'", sqlite3_errmsg(database));
            sqlite3_close(database);
        }
             */
    }
    sqlite3_close(database);
    return success;
}

- (int) saveGarden:(NSDictionary *)msgJSON{
    int lastRow = 0;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT or REPLACE into saves (rows, columns, bedstate, timestamp, name, unique_id, planting_date) values(\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                               [msgJSON objectForKey:@"rows"],
                               [msgJSON objectForKey:@"columns"],
                               [msgJSON objectForKey:@"bedstate"],
                               [msgJSON objectForKey:@"timestamp"],
                               [msgJSON objectForKey:@"name"],
                               [msgJSON objectForKey:@"unique_id"],
                               [msgJSON objectForKey:@"planting_date"]];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE){
            //NSLog(@"Bed saved to db");
            NSInteger lastRowId = (int)sqlite3_last_insert_rowid(database);
            lastRow = (int)lastRowId;
            //NSLog(@"Last Insert Row: %i", lastRow);
            
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return lastRow;
        }
        else{
            NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(database));
            sqlite3_close(database);
            lastRow = -1;
            return lastRow;
        }
    }
    sqlite3_close(database);
    NSLog(@"failed to save message");
    //return false;
    return lastRow;
}

- (NSDictionary *) getClassDataById:(int) classID{
    NSMutableDictionary *classData = [[NSMutableDictionary alloc] init];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM plant_classes WHERE local_id = %i LIMIT 1", classID];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            //NSLog(@"msg sql for class data ok");
            while (sqlite3_step(statement) == SQLITE_ROW){
                NSString *plantName = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 1)];
                NSString *plantIcon = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 3)];
                NSString *plantMaturity = [[NSString alloc] initWithUTF8String:
                                           (const char *) sqlite3_column_text(statement, 4)];
                //NSLog(@"msg sql name: %@", plantName);
                //NSLog(@"msg sql: %@", plantIcon);
                //NSLog(@"msg sql: %@", plantMaturity);
                [classData setObject:plantName forKey:@"name"];
                [classData setObject:plantIcon forKey:@"icon"];
                [classData setObject:plantMaturity forKey:@"maturity"];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return classData;
}

- (NSMutableArray *) getPlantUuidsForClass:(NSString *)class{
    NSLog(@"msg sql outter class name: %@", class);
    NSMutableArray *list = [[NSMutableArray alloc] init];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"SELECT uuid FROM plants WHERE class = \"%@\"", class];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            //NSLog(@"msg sql for plant data ok");
            while (sqlite3_step(statement) == SQLITE_ROW){
                NSString *plantUuid = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 0)];
                //NSLog(@"msg sql class name: %@", class);
                //NSLog(@"msg sql: %@", plantMaturity);
                //int index = plantId.intValue;
                [list addObject:plantUuid];
                //NSLog(@"msg sql count: %lu",(unsigned long)list.count);
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    NSLog(@"msg sql return list count: %lu",(unsigned long)list.count);
    return list;
}


- (NSDictionary *) getPlantDataById:(int) plantID{
    NSMutableDictionary *plantData = [[NSMutableDictionary alloc] init];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM plants WHERE local_id = %i LIMIT 1", plantID];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            //NSLog(@"msg sql for plant data ok");
            while (sqlite3_step(statement) == SQLITE_ROW){
                NSString *local_id = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 0)];
                NSString *plantName = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 1)];
                NSString *timestamp = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 2)];
                NSString *plantIcon = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 3)];
                NSString *plantMaturity = [[NSString alloc] initWithUTF8String:
                                           (const char *) sqlite3_column_text(statement, 4)];
                NSString *plantPopulation = [[NSString alloc] initWithUTF8String:
                                           (const char *) sqlite3_column_text(statement, 5)];
                NSString *plantClass = [[NSString alloc] initWithUTF8String:
                                             (const char *) sqlite3_column_text(statement, 6)];
                NSString *plantDescription = [[NSString alloc] initWithUTF8String:
                                             (const char *) sqlite3_column_text(statement, 7)];
                NSString *plantScienceName = [[NSString alloc] initWithUTF8String:
                                              (const char *) sqlite3_column_text(statement, 8)];
                NSString *plantPhoto = [[NSString alloc] initWithUTF8String:
                                              (const char *) sqlite3_column_text(statement, 9)];
                NSString *plantYield = [[NSString alloc] initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 10)];
                NSString *isoIcon = [[NSString alloc] initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 11)];
                NSString *plantingDelta = [[NSString alloc] initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 12)];
                NSString *isTall = [[NSString alloc] initWithUTF8String:
                                     (const char *) sqlite3_column_text(statement, 13)];
                NSString *uuid = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 14)];
                NSString *squareFeet = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 15)];
                NSString *tipJson = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 16)];
                NSString *startSeed = [[NSString alloc] initWithUTF8String:
                                     (const char *) sqlite3_column_text(statement, 17)];
                NSString *startInside = [[NSString alloc] initWithUTF8String:
                                     (const char *) sqlite3_column_text(statement, 18)];
                NSString *startInsideDelta = [[NSString alloc] initWithUTF8String:
                                     (const char *) sqlite3_column_text(statement, 19)];
                NSString *transplantDelta = [[NSString alloc] initWithUTF8String:
                                     (const char *) sqlite3_column_text(statement, 20)];
                



                [plantData setObject:local_id forKey:@"plant_id"];
                [plantData setObject:plantName forKey:@"name"];
                [plantData setObject:timestamp forKey:@"timestamp"];
                [plantData setObject:plantIcon forKey:@"icon"];
                [plantData setObject:plantMaturity forKey:@"maturity"];
                [plantData setObject:plantPopulation forKey:@"population"];
                [plantData setObject:plantClass forKey:@"class"];
                [plantData setObject:plantDescription forKey:@"description"];
                [plantData setObject:plantScienceName forKey:@"scientific_name"];
                [plantData setObject:plantPhoto forKey:@"photo"];
                [plantData setObject:plantYield forKey:@"yield"];
                [plantData setObject:isoIcon forKey:@"isoIcon"];
                [plantData setObject:isTall forKey:@"isTall"];
                [plantData setObject:plantingDelta forKey:@"plantingDelta"];
                [plantData setObject:uuid forKey:@"uuid"];
                [plantData setObject:squareFeet forKey:@"square_feet"];
                [plantData setObject:tipJson forKey:@"tip_json"];
                [plantData setObject:startSeed forKey:@"start_seed"];
                [plantData setObject:startInside forKey:@"start_inside"];
                [plantData setObject:startInsideDelta forKey:@"start_inside_delta"];
                [plantData setObject:transplantDelta forKey:@"transplant_delta"];
                

                //NSLog(@"PLANTING DELTA = %@",startInsideDelta);
                //NSLog(@"UUID = %@",uuid);
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return plantData;
}

- (NSDictionary *) getPlantDataByUuid:(NSString *) uuid{
    NSMutableDictionary *plantData = [[NSMutableDictionary alloc] init];
    if(uuid.length < 5)return plantData;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM plants WHERE uuid = '%@' LIMIT 1", uuid];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            //NSLog(@"msg sql for plant data ok");
            while (sqlite3_step(statement) == SQLITE_ROW){
                NSString *local_id = [[NSString alloc] initWithUTF8String:
                                      (const char *) sqlite3_column_text(statement, 0)];
                NSString *plantName = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 1)];
                NSString *timestamp = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 2)];
                NSString *plantIcon = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 3)];
                NSString *plantMaturity = [[NSString alloc] initWithUTF8String:
                                           (const char *) sqlite3_column_text(statement, 4)];
                NSString *plantPopulation = [[NSString alloc] initWithUTF8String:
                                             (const char *) sqlite3_column_text(statement, 5)];
                NSString *plantClass = [[NSString alloc] initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 6)];
                NSString *plantDescription = [[NSString alloc] initWithUTF8String:
                                              (const char *) sqlite3_column_text(statement, 7)];
                NSString *plantScienceName = [[NSString alloc] initWithUTF8String:
                                              (const char *) sqlite3_column_text(statement, 8)];
                NSString *plantPhoto = [[NSString alloc] initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 9)];
                NSString *plantYield = [[NSString alloc] initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 10)];
                NSString *isoIcon = [[NSString alloc] initWithUTF8String:
                                     (const char *) sqlite3_column_text(statement, 11)];
                NSString *plantingDelta = [[NSString alloc] initWithUTF8String:
                                           (const char *) sqlite3_column_text(statement, 12)];
                NSString *isTall = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 13)];
                NSString *uuid = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 14)];
                NSString *squareFeet = [[NSString alloc] initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 15)];
                NSString *tipJson = [[NSString alloc] initWithUTF8String:
                                     (const char *) sqlite3_column_text(statement, 16)];
                NSString *startSeed = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 17)];
                NSString *startInside = [[NSString alloc] initWithUTF8String:
                                         (const char *) sqlite3_column_text(statement, 18)];
                NSString *startInsideDelta = [[NSString alloc] initWithUTF8String:
                                              (const char *) sqlite3_column_text(statement, 19)];
                NSString *transplantDelta = [[NSString alloc] initWithUTF8String:
                                             (const char *) sqlite3_column_text(statement, 20)];
                
                [plantData setObject:local_id forKey:@"plant_id"];
                [plantData setObject:plantName forKey:@"name"];
                [plantData setObject:timestamp forKey:@"timestamp"];
                [plantData setObject:plantIcon forKey:@"icon"];
                [plantData setObject:plantMaturity forKey:@"maturity"];
                [plantData setObject:plantPopulation forKey:@"population"];
                [plantData setObject:plantClass forKey:@"class"];
                [plantData setObject:plantDescription forKey:@"description"];
                [plantData setObject:plantScienceName forKey:@"scientific_name"];
                [plantData setObject:plantPhoto forKey:@"photo"];
                [plantData setObject:plantYield forKey:@"yield"];
                [plantData setObject:isoIcon forKey:@"isoIcon"];
                [plantData setObject:isTall forKey:@"isTall"];
                [plantData setObject:plantingDelta forKey:@"plantingDelta"];
                [plantData setObject:uuid forKey:@"uuid"];
                [plantData setObject:squareFeet forKey:@"square_feet"];
                [plantData setObject:tipJson forKey:@"tip_json"];
                [plantData setObject:startSeed forKey:@"start_seed"];
                [plantData setObject:startInside forKey:@"start_inside"];
                [plantData setObject:startInsideDelta forKey:@"start_inside_delta"];
                [plantData setObject:transplantDelta forKey:@"transplant_delta"];
                //NSLog(@"local_id = %@",local_id);
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return plantData;
}


- (NSMutableDictionary *) getGardenByLocalId : (int) index{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    const char *dbpath = [databasePath UTF8String];
    NSString *tableName = @"saves";
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT timestamp, name, bedstate, rows, columns, unique_id, planting_date FROM %@ WHERE local_id = %i", tableName, index];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            //NSLog(@"msg sql ok");
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                int sqlRows = sqlite3_column_int(statement, 0);
                NSLog(@"SQLite Rows: %i", sqlRows);
                NSString *saveName = [[NSString alloc] initWithUTF8String:
                                      (const char *) sqlite3_column_text(statement, 1)];
                NSString *saveTS = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 0)];
                NSString *saveState = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 2)];
                NSString *rows = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 3)];
                NSString *columns = [[NSString alloc] initWithUTF8String:
                                     (const char *) sqlite3_column_text(statement, 4)];
                NSString *uniqueId = [[NSString alloc] initWithUTF8String:
                                      (const char *) sqlite3_column_text(statement, 5)];
                NSString *plantingDate = [[NSString alloc] initWithUTF8String:
                                      (const char *) sqlite3_column_text(statement, 6)];
                NSString *indexStr = [NSString stringWithFormat:@"%i", index];
                [dict setObject:saveName forKey:@"name"];
                [dict setObject:saveTS forKey:@"timestamp"];
                [dict setObject:saveState forKey:@"bedstate"],
                [dict setObject:rows forKey:@"rows"],
                [dict setObject:columns forKey:@"columns"],
                [dict setObject:uniqueId forKey:@"unique_id"];
                [dict setObject:indexStr forKey:@"local_id"];
                [dict setObject:plantingDate forKey:@"planting_date"];
                NSLog(@"MODEL BY ID state %@, ts %@, uniqueID %@, plantingDate %@", saveState, saveTS, uniqueId, plantingDate);

            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return dict;
}

- (NSMutableDictionary *) getGardenByUniqueId : (NSString *) uuid{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    const char *dbpath = [databasePath UTF8String];
    NSString *tableName = @"saves";
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT timestamp, name, bedstate, rows, columns, local_id, planting_date FROM %@ WHERE unique_id = %@", tableName, uuid];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            //NSLog(@"msg sql ok");
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                int sqlRows = sqlite3_column_int(statement, 0);
                NSLog(@"SQLite Rows: %i", sqlRows);
                NSString *saveName = [[NSString alloc] initWithUTF8String:
                                      (const char *) sqlite3_column_text(statement, 1)];
                NSString *saveTS = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 0)];
                NSString *saveState = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 2)];
                NSString *rows = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 3)];
                NSString *columns = [[NSString alloc] initWithUTF8String:
                                     (const char *) sqlite3_column_text(statement, 4)];
                NSString *localId = [[NSString alloc] initWithUTF8String:
                                      (const char *) sqlite3_column_text(statement, 5)];
                NSString *plantingDate = [[NSString alloc] initWithUTF8String:
                                          (const char *) sqlite3_column_text(statement, 6)];
                [dict setObject:saveName forKey:@"name"];
                [dict setObject:saveTS forKey:@"timestamp"];
                [dict setObject:saveState forKey:@"bedstate"],
                [dict setObject:rows forKey:@"rows"],
                [dict setObject:columns forKey:@"columns"],
                [dict setObject:localId forKey:@"local_id"],
                [dict setObject:plantingDate forKey:@"planting_date"];
                [dict setObject:uuid forKey:@"unique_id"];
                //NSLog(@"name %@, ts %@, uniqueID %@", saveName, saveTS, uniqueId);
                NSLog(@"MODEL BY UUID: name %@, ts %@, uniqueID %@, plantingDate %@", saveName, saveTS, uuid, plantingDate);
                
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return dict;
}




- (NSMutableArray *) getBedSaveList{
    const char *dbpath = [databasePath UTF8String];
    NSString *tableName = @"saves";
    NSMutableArray *returnJson = [[NSMutableArray alloc]init];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT local_id, timestamp, name, bedstate, rows, columns, unique_id, planting_date FROM %@", tableName];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            //NSLog(@"msg sql ok");
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                //int sqlRows = sqlite3_column_int(statement, 0);
                NSMutableDictionary *json = [[NSMutableDictionary alloc]init];
                NSString *saveName = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 2)];
                NSString *saveTS = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 1)];
                NSString *saveId = [[NSString alloc] initWithUTF8String:
                                           (const char *) sqlite3_column_text(statement, 0)];
                NSString *saveState = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 3)];
                NSString *rows = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 4)];
                NSString *columns = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 5)];
                NSString *uniqueId = [[NSString alloc] initWithUTF8String:
                                     (const char *) sqlite3_column_text(statement, 6)];
                NSString *planting_date = [[NSString alloc] initWithUTF8String:
                                      (const char *) sqlite3_column_text(statement, 7)];
                [json setObject:saveName forKey:@"name"];
                [json setObject:saveTS forKey:@"timestamp"];
                [json setObject:saveId forKey:@"local_id"];
                [json setObject:saveState forKey:@"bedstate"],
                [json setObject:rows forKey:@"rows"],
                [json setObject:columns forKey:@"columns"],
                [json setObject:uniqueId forKey:@"unique_id"],
                [json setObject:planting_date forKey:@"planting_date"],
                [returnJson addObject:json];
                //NSLog(@"json data: %@ %@ %@", saveId, saveName, saveTS);
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return returnJson;
}

- (BOOL) checkTableExists:(NSString *)tableName{
    const char *dbpath = [databasePath UTF8String];
    BOOL exists = false;
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            //NSLog(@"msg sql ok");
            exists = true;
            /*
            if(sqlite3_step(statement) > 0){
                NSLog(@"step > 0 %i", sqlite3_step(statement));
                exists = YES;
            }
             */
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                //nothing goes here yet
                //int rows = sqlite3_column_int(statement, 0);
                //NSLog(@"SQLite Rows in %@: %i", tableName, rows);
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    //NSLog(@"Return Nil");
    return exists;
}

- (int) getTableRowCount:(NSString *)tableName {
    int count = 0;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *sql_str = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
        const char *sqlStatement = [sql_str UTF8String];
        sqlite3_stmt *statement;
        if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                count = sqlite3_column_int(statement, 0);
            }
        }
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        //NSLog(@"count %i", count);
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return count;
}

-(BOOL) dropTable:(NSString*)tableName{
    NSString *docsDir;
    NSString *sql_str = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", tableName];
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: appName]];
    const char *dbpath = [databasePath UTF8String];
    const char *drop_stmt = [sql_str UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        char *errMsg;
        //const char *drop_stmt = "Drop Table matches";
        if (sqlite3_exec(database, drop_stmt, NULL, NULL, &errMsg)!= SQLITE_OK){
            NSString *msg = [NSString stringWithFormat:@"%s", errMsg];
            NSLog(@"Failed to drop table: %@", msg);
            sqlite3_close(database);
            return false;
        }else{
            NSLog(@"dropped %@ table", tableName);
            sqlite3_close(database);
            return true;
        }
    }
    NSLog(@"Failed to DROP");
    return false;
}


@end
