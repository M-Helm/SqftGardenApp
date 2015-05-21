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
- (BOOL) checkTableExists:(NSString *)tableName;
- (int) getTableRowCount:(NSString *)tableName;
- (NSString *) getFact:(int) alt;
- (BOOL) dropTable:(NSString*)table;


@end
