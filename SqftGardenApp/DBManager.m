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
        //NSLog(@"%s", __PRETTY_FUNCTION__);
    }
    return sharedDBManager;
}

-(NSArray*)getInitPlants{
    NSLog(@"pop PLANT Table");
    //[self createTable:@"plants"];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *filePath = [path stringByAppendingPathComponent:initPlantListName];
    NSString *contentStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSData *jsonData = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%i",(int)[jsonData length]);
    
    NSError *e = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: &e];
    NSLog(@"PLant Array Length = %lu", (unsigned long)jsonArray.count);
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
    NSLog(@"pop Table");
    //[self createTable:@"plants"];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *filePath = [path stringByAppendingPathComponent:initClassListName];
    NSString *contentStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSData *jsonData = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"%i",(int)[jsonData length]);
    
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
            //NSLog(@"Failed to add column");
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
            //NSString *msg = [NSString stringWithFormat:@"%s", errMsg];
            //NSLog(msg);
            NSLog(@"Failed to open/create database");
        }
        //sqlite3_finalize(statement);
        sqlite3_close(database);
        NSLog(@"CREATE TABLE %@ isSuccess: %i", tableName, isSuccess);
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
            NSLog(@"class saved to db");
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
    NSLog(@"PLANT SAVE CALLED");
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into plants (name, timestamp, icon, maturity, population, class) values(\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                               [msgJSON objectForKey:@"name"],
                               [msgJSON objectForKey:@"timestamp"],
                               [msgJSON objectForKey:@"icon"],
                               [msgJSON objectForKey:@"maturity"],
                               [msgJSON objectForKey:@"population"],
                               [msgJSON objectForKey:@"class"]];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"plant saved to db");
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
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT or REPLACE into saves (local_id, rows, columns, bedstate, timestamp, name, unique_id) values(\"%@\", \"%@\",\"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                            [msgJSON objectForKey:@"local_id"],
                            [msgJSON objectForKey:@"rows"],
                            [msgJSON objectForKey:@"columns"],
                            [msgJSON objectForKey:@"bedstate"],
                            [msgJSON objectForKey:@"timestamp"],
                            [msgJSON objectForKey:@"name"],
                            [msgJSON objectForKey:@"unique_id"]];
                               
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"bed saved to db");
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
- (int) saveGarden:(NSDictionary *)msgJSON{
    int lastRow = 0;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT or REPLACE into saves (rows, columns, bedstate, timestamp, name, unique_id) values(\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                               [msgJSON objectForKey:@"rows"],
                               [msgJSON objectForKey:@"columns"],
                               [msgJSON objectForKey:@"bedstate"],
                               [msgJSON objectForKey:@"timestamp"],
                               [msgJSON objectForKey:@"name"],
                               [msgJSON objectForKey:@"unique_id"]];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"Bed saved to db");
            NSInteger lastRowId = (int)sqlite3_last_insert_rowid(database);
            lastRow = (int)lastRowId;
            NSLog(@"Last Insert Row: %i", lastRow);
            
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return lastRow;
        }
        else{
            NSLog(@"Error while inserting data. '%s'", sqlite3_errmsg(database));
            sqlite3_close(database);
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

- (NSMutableArray *) getPlantIdsForClass:(NSString *)class{
    NSLog(@"msg sql outter class name: %@", class);
    NSMutableArray *list = [[NSMutableArray alloc] init];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"SELECT local_id FROM plants WHERE class = \"%@\"", class];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            //NSLog(@"msg sql for plant data ok");
            while (sqlite3_step(statement) == SQLITE_ROW){
                NSString *plantId = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 0)];
                NSLog(@"msg sql class name: %@", class);
                //NSLog(@"msg sql: %@", plantMaturity);
                //int index = plantId.intValue;
                [list addObject:plantId];
                NSLog(@"msg sql count: %lu",(unsigned long)list.count);
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
                NSString *plantIcon = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 3)];
                NSString *plantMaturity = [[NSString alloc] initWithUTF8String:
                                           (const char *) sqlite3_column_text(statement, 4)];
                NSString *plantPopulation = [[NSString alloc] initWithUTF8String:
                                           (const char *) sqlite3_column_text(statement, 5)];
                //NSLog(@"msg sql name: %@", plantName);
                //NSLog(@"msg sql: %@", plantIcon);
                //NSLog(@"msg sql: %@", plantMaturity);
                [plantData setObject:plantName forKey:@"name"];
                [plantData setObject:plantIcon forKey:@"icon"];
                [plantData setObject:plantMaturity forKey:@"maturity"];
                [plantData setObject:local_id forKey:@"plant_id"];
                [plantData setObject:plantPopulation forKey:@"population"];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return plantData;
}

 - (NSDictionary *) getPlantDataByName:(NSString *) name{
     NSMutableDictionary *plantData = nil;
     const char *dbpath = [databasePath UTF8String];
     if (sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM plants WHERE name = '%@' LIMIT 1", name];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            NSLog(@"msg sql for plant data ok");
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
                [plantData setObject:plantName forKey:@"name"];
                [plantData setObject:plantIcon forKey:@"icon"];
                [plantData setObject:plantMaturity forKey:@"maturity"];
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
        NSString *querySQL = [NSString stringWithFormat:@"SELECT timestamp, name, bedstate, rows, columns, unique_id FROM %@ WHERE local_id = %i", tableName, index];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSLog(@"msg sql ok");
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
                NSString *indexStr = [NSString stringWithFormat:@"%i", index];
                [dict setObject:saveName forKey:@"name"];
                [dict setObject:saveTS forKey:@"timestamp"];
                [dict setObject:saveState forKey:@"bedstate"],
                [dict setObject:rows forKey:@"rows"],
                [dict setObject:columns forKey:@"columns"],
                [dict setObject:uniqueId forKey:@"unique_id"];
                [dict setObject:indexStr forKey:@"local_id"];
                //NSLog(@"name %@, ts %@, uniqueID %@", saveName, saveTS, uniqueId);

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
        NSString *querySQL = [NSString stringWithFormat:@"SELECT timestamp, name, bedstate, rows, columns, local_id FROM %@ WHERE unique_id = %@", tableName, uuid];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSLog(@"msg sql ok");
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
                [dict setObject:saveName forKey:@"name"];
                [dict setObject:saveTS forKey:@"timestamp"];
                [dict setObject:saveState forKey:@"bedstate"],
                [dict setObject:rows forKey:@"rows"],
                [dict setObject:columns forKey:@"columns"],
                [dict setObject:localId forKey:@"local_id"],
                [dict setObject:uuid forKey:@"unique_id"];
                //NSLog(@"name %@, ts %@, uniqueID %@", saveName, saveTS, uniqueId);
                
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
        NSString *querySQL = [NSString stringWithFormat:@"SELECT local_id, timestamp, name, bedstate, rows, columns, unique_id FROM %@", tableName];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSLog(@"msg sql ok");
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
                [json setObject:saveName forKey:@"name"];
                [json setObject:saveTS forKey:@"timestamp"];
                [json setObject:saveId forKey:@"local_id"];
                [json setObject:saveState forKey:@"bedstate"],
                [json setObject:rows forKey:@"rows"],
                [json setObject:columns forKey:@"columns"],
                [json setObject:uniqueId forKey:@"unique_id"],
                [returnJson addObject:json];
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
