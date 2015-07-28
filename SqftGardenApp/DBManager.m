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

static DBManager *sharedDBManager = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;
static NSString *appName = @"sqftGardenApp";

@implementation DBManager

+(DBManager*)getSharedDBManager{
    if (!sharedDBManager) {
        sharedDBManager = [[super allocWithZone:NULL]init];
        [sharedDBManager createTable:@"defaults"];
        NSLog(@"%s", __PRETTY_FUNCTION__);
    }
    return sharedDBManager;
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
            NSLog(@"Failed to add column");
        }
        //sqlite3_finalize(statement);
        sqlite3_close(database);
        return  isSuccess;
    }
    return isSuccess;
}

-(BOOL)createTable:(NSString *)tableName{
    //NSLog(@"create facts table called");
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
        
        /*
        const char *sql_stmt =
        "create table if not exists APP_TABLE_NAME_GOES_HERE(local_id integer primary key autoincrement, "
        "timestamp int NOT NULL, "
        "altitude int, "
        "fact var_char(255))";
         */
        
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
        return  isSuccess;
    }
    return isSuccess;
}

/*
- (BOOL) saveFact:(NSDictionary *)msgJSON{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into facts (timestamp, altitude, fact) values(\"%@\", \"%@\", \"%@\")",
                               [msgJSON objectForKey:@"timestamp"],
                               [msgJSON objectForKey:@"alt"],
                               [msgJSON objectForKey:@"msg"]];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"fact saved to db");
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
 
 - (NSString *) getFact:(int) alt{
 int altBoundLo = alt - 51;
 int altBoundHi = alt + 51;
 //NSLog(@"getFact called %i %i", altBoundLo, altBoundHi);
 NSString *fact = @"Database error";
 const char *dbpath = [databasePath UTF8String];
 if (sqlite3_open(dbpath, &database) == SQLITE_OK)
 {
 NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM facts WHERE altitude BETWEEN %i and %i ORDER BY RANDOM() LIMIT 1", altBoundLo, altBoundHi];
 //NSString *querySQL = [NSString stringWithFormat:@"SELECT altitude FROM facts"];
 //NSLog(@"%@", querySQL);
 const char *query_stmt = [querySQL UTF8String];
 
 if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
 {
 NSLog(@"msg sql ok");
 while (sqlite3_step(statement) == SQLITE_ROW)
 {
 fact = [[NSString alloc] initWithUTF8String:
 (const char *) sqlite3_column_text(statement, 3)];
 }
 }
 sqlite3_finalize(statement);
 sqlite3_close(database);
 }
 //NSLog(@"... %@", fact);
 return fact;
 }
 

*/

- (BOOL) checkTableExists:(NSString *)tableName{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSLog(@"msg sql ok");
            if(sqlite3_step(statement) > 0){
                NSLog(@"step > 0 %i", sqlite3_step(statement));
            }
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                //nothing goes here yet
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    NSLog(@"Return Nil");
    return false;
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
        NSLog(@"count %i", count);
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
                    [docsDir stringByAppendingPathComponent: @"howhimi.db"]];
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
            sqlite3_close(database);
            return true;
        }
    }
    return false;
}


@end
