//
//  SqftGardenModel.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 8/17/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "SqftGardenModel.h"
#import "DBManager.h"

@interface SqftGardenModel ()

@end

@implementation SqftGardenModel

DBManager *dbManager;


- (id) init{
    self = [super init];
    NSLog(@"INIT OVERRIDE Method called");
    [self commonInit];
    return self;
}

- (id) initWithDict:(NSDictionary*)dict
{
    self = [super init];
    
    if(self)
    {
        NSNumber *dRows = [NSNumber numberWithInt:(int)[[dict valueForKey:@"rows"]integerValue]];
        NSNumber *dColumns = [NSNumber numberWithInt:(int)[[dict valueForKey:@"columns"] integerValue]];
        NSString *ts = [dict valueForKey:@"timestamp"];
        NSString *localID = [dict valueForKey:@"local_id"];
        self.bedStateArrayString = [dict valueForKey:@"bedstate"];
        [self compileBedStateDictFromString:self.bedStateArrayString];
        self.name = [dict valueForKey:@"name"];
        self.uniqueId = [dict valueForKey:@"unique_id"];
        NSLog(@"UUID from DICT: %@", self.uniqueId);
        self.timestamp = ts.intValue;
        self.localId = localID.intValue;
        self.columns = (int)dRows;
        self.rows = (int)dColumns;
        if(self.columns < 1)self.columns = 3;
        if(self.rows < 1)self.rows = 3;
    }
    [self commonInit];
    return self;
}

- (void) commonInit{
    if(self.uniqueId.length < 8){
        NSLog(@"SHort UUID: %@", self.uniqueId);
        self.uniqueId = [self getUUID];
    }
    NSLog(@"UUID = %@", self.uniqueId);
}

- (NSString *)getUUID{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

- (void) setPlantIdForCell:(int) cell :(int) plant{
    if(self.bedStateDictionary == nil){
        self.bedStateDictionary = [[NSMutableDictionary alloc] init];
    }
    NSString *key = [NSString stringWithFormat:@"cell%i", cell];
    NSNumber *plantId = [NSNumber numberWithInt:plant];
    [self.bedStateDictionary setObject:plantId forKey:key];
    [self compileBedStateArrayString:self.bedStateDictionary];
    //NSString *tempStr = [self.bedStateDictionary objectForKey:key];
    //NSLog(@"temp string for set Plant Id: %@", tempStr);
    //NSLog(@"set plant info: %@ # %i STRING: %@" , key, (int)plantId.integerValue, self.bedStateArrayString);

}

- (int) getPlantIdForCell:(int) cell{
    NSString *key = [NSString stringWithFormat:@"cell%i", cell];
    int plantId = (int)[[self.bedStateDictionary valueForKey:key] integerValue];
    //NSLog(@"model get id method returns: %i", plantId);
    return plantId;
}

- (void) setBedRows:(int) rows{
    if(rows < 1)rows = 3;
    self.rows = rows;
}

-(void) setBedColumns:(int) columns{
    if(columns < 1)columns = 3;
    self.columns = columns;
}

- (void) setCurrentBedState:(NSMutableDictionary *)json{
    //NSLog(@"setCurrentBedState Called");
    if(self.bedStateDictionary == nil){
        self.bedStateDictionary = [[NSMutableDictionary alloc] init];
    }
    self.bedStateDictionary = json;
    self.bedStateArrayString = [self compileBedStateArrayString:json];
}

- (NSMutableDictionary *) getCurrentBedState{
    if(self.bedStateDictionary == nil){
        self.bedStateDictionary = [[NSMutableDictionary alloc] init];
    }
    NSString *str = [self.bedStateDictionary valueForKey:@"bedstate"];
    //temp trim the string of the leading and trailing [] chars soon to be array of dicts
    str = [str substringWithRange:NSMakeRange(1, [str length]-1)];
    NSMutableArray *tempArray = [[NSMutableArray alloc]
                                 initWithArray:[str componentsSeparatedByString:@","]];
    
    for(int i=0;i<tempArray.count;i++){
        int plantId = (int)[tempArray[i] integerValue];
        NSNumber *plant = [NSNumber numberWithInt:plantId];
        NSString *cell = [NSString stringWithFormat:@"cell%i",i];
        [self.bedStateDictionary setValue:plant forKey:cell];
    }
    
    return self.bedStateDictionary;
}

- (void) clearCurrentBedState{
    if(self.bedStateDictionary != nil)[self.bedStateDictionary removeAllObjects];
}

- (NSString *)compileBedStateArrayString : (NSDictionary *)bedJSON{
    //compile an array for the bedstate
    int cellCount = (self.rows * self.columns);
    NSString *tempArrayStr = @"";
    NSString *tempStr = @"";
    NSString *key = @"";
    for(int i=0; i<cellCount; i++){
        key = [NSString stringWithFormat:@"cell%i", i];
        int strId = (int)[[bedJSON valueForKey:key] integerValue];
        tempStr = [NSString stringWithFormat:@"%i", strId];
        if(i == 0)tempArrayStr = [NSString stringWithFormat:@"%@", tempStr];
        else tempArrayStr = [NSString stringWithFormat:@"%@,%@", tempArrayStr, tempStr];
    }
    tempArrayStr = [NSString stringWithFormat:@"[%@]",tempArrayStr];
    self.bedStateArrayString = tempArrayStr;
    return self.bedStateArrayString;
}

- (NSArray *)compileBedStateDictFromString : (NSString *)arrayString{
    //NSMutableArray *array = [[NSMutableArray alloc] init];
    //arrayString = [arrayString substringToIndex:[arrayString length] - 1];
    arrayString = [arrayString substringWithRange:NSMakeRange(1, [arrayString length] - 2)];
    //arrayString = [arrayString substringToIndex:[arrayString length] - 1];
    NSArray *array = [arrayString componentsSeparatedByString:@","];
    NSLog(@"TRIMMED STRING %@",arrayString);
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSString *key = @"";
    for(int i = 0; i < array.count;i++){
        key = [NSString stringWithFormat :@"cell%i",i];
        [dict setObject:array[i] forKey:key];
    }
    self.bedStateDictionary = dict;
    return array;
}

- (NSString *)getBedStateArrayString{
    if(self.bedStateArrayString != nil){
        return self.bedStateArrayString;
    }
    self.bedStateArrayString = @"[0,0,0,0,0,0,0,0,0]";
    return self.bedStateArrayString;
}

- (void) showModelInfo{
    NSLog(@"Rows: %i, Columns: %i, Array String: %@", self.rows, self.columns, [self getBedStateArrayString]);
    
}

- (BOOL) saveGarden{
    BOOL success = NO;
    if(dbManager == nil){
        dbManager = [DBManager getSharedDBManager];
    }
    if(self.uniqueId == nil){
        self.uniqueId = [self getUUID];
    }
    
    //temp magic #
    NSString *localIdStr = [NSString stringWithFormat:@"%i", self.localId];
    
    //get standard save info from arg
    long ts = (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970]);
    NSString *timestamp = [NSString stringWithFormat:@"%ld", ts];
    NSString *name = self.name;
    if(name == nil){
        name = @"autoSave";
        localIdStr = @"1";
    }
    NSNumber *rows = [NSNumber numberWithInt: self.rows];
    NSNumber *columns = [NSNumber numberWithInt: self.columns];
    
    //fail if cell structure is fucked
    if(rows.integerValue < 1)return false;
    if(columns.integerValue < 1 )return false;
    
    //create json pkg for db
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    [json setObject:localIdStr forKey:@"local_id"];
    [json setObject:rows forKey:@"rows"];
    [json setObject:columns forKey:@"columns"];
    [json setObject:timestamp forKey:@"timestamp"];
    [json setObject:name forKey:@"name"];
    [json setObject:self.uniqueId forKey:@"unique_id"];
    
    //compile an array for the bedstate
    NSString *tempArrayStr = [self getBedStateArrayString];
    [json setObject:tempArrayStr forKey:@"bedstate"];
    
    [dbManager saveBedAutoSave:json];
    return success;
}

@end