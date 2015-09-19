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
    //NSLog(@"INIT OVERRIDE Method called");
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
        
        
        NSString *dateString = [dict valueForKey:@"planting_date"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        self.plantingDate = [dateFormatter dateFromString:dateString];

        //NSLog(@"UUID from DICT: %@", self.uniqueId);
        self.timestamp = ts.intValue;
        self.localId = localID.intValue;
        self.columns = dColumns.intValue;
        self.rows = dRows.intValue;
        if(self.columns < 1)self.columns = 3;
        if(self.rows < 1)self.rows = 3;
        if(self.localId < 2)self.localId = 1;
        //NSLog(@"Local ID On INIT = %i, ROWS on INIT = %i", self.localId, self.rows);
    }
    [self commonInit];
    return self;
}

- (void) commonInit{
    if(self.uniqueId.length < 8){
        self.uniqueId = [self getUUID];
    }
    if(self.plantingDate == nil){
        NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:0];
        self.plantingDate = date;
        NSLog(@"DATE ON MODEL = %@", date);
    }
}

- (NSString *)getUUID{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

- (void) assignNewUUID{
    NSString *uuid = [self getUUID];
    self.uniqueId = uuid;
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
    //NSLog(@"TRIMMED STRING %@",arrayString);
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
    NSLog(@"Rows: %i, Columns: %i, Array String: %@",self.rows, self.columns, [self getBedStateArrayString]);
}

- (NSMutableDictionary *)compileSaveJson{
    if(self.uniqueId == nil){
        self.uniqueId = [self getUUID];
    }
    //get standard save info from arg
    long ts = (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970]);
    NSString *timestamp = [NSString stringWithFormat:@"%ld", ts];
    NSString *name = self.name;
    NSNumber *rows = [NSNumber numberWithInt: self.rows];
    NSNumber *columns = [NSNumber numberWithInt: self.columns];
    NSString *localIdStr = [NSString stringWithFormat:@"%i", self.localId];
    NSString *autoStr = @"autoSave";
    if(self.localId < 1){
        self.name = autoStr;
        localIdStr = @"1";
        self.localId = 1;
    }
    if(name == nil){
        self.name = autoStr;
        localIdStr = @"1";
        self.localId = 1;
    }
    if([name isEqualToString:autoStr]){
        localIdStr = @"1";
        self.localId = 1;
    }
    if(self.localId == 1){
        if(![name isEqualToString:autoStr]){
            //do stuff??
        };
    }
    name = self.name;
    //create a string date for db
    NSDate *date = self.plantingDate;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormat stringFromDate:date];
    
    //create json pkg for db
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    [json setObject:localIdStr forKey:@"local_id"];
    [json setObject:rows forKey:@"rows"];
    [json setObject:columns forKey:@"columns"];
    [json setObject:timestamp forKey:@"timestamp"];
    [json setObject:name forKey:@"name"];
    [json setObject:self.uniqueId forKey:@"unique_id"];
    [json setObject:dateString forKey:@"planting_date"];
    
    //compile an array for the bedstate
    NSString *tempArrayStr = [self getBedStateArrayString];
    [json setObject:tempArrayStr forKey:@"bedstate"];
    return json;
}

- (BOOL) saveModel : (BOOL) overwrite{
    BOOL success = NO;
    if(dbManager == nil){
        dbManager = [DBManager getSharedDBManager];
    }
    /*
    //check uuid against the other saved files
    NSArray *array = [dbManager getBedSaveList];
    for(int i = 0;i<array.count;i++){
        NSDictionary *dict = array[i];
        NSString *uuid = [dict objectForKey:@"unique_id"];
        if([self.uniqueId isEqualToString:uuid]){
            localIdStr = [dict objectForKey:@"local_id"];
            NSString *checkStr = @"1";
            if([localIdStr isEqualToString:checkStr])continue;
            else{
                [json setObject:localIdStr forKey:@"local_id"];
                success = YES;
                NSLog(@"LOCAL ID = %i", self.localId);
                [dbManager overwriteSavedGarden:json];
                return success;
            }
        }
    }
    */
    NSMutableDictionary *json = [self compileSaveJson];
    if(self.localId == 1)[dbManager overwriteSavedGarden:json];
    if(overwrite)[dbManager overwriteSavedGarden:json];
    if(!overwrite)[dbManager saveGarden:json];

    //NSLog(@"LOCAL ID = %i", self.localId);
    
    return success;
}

-(BOOL)autoSaveModel{
    BOOL success = NO;
    if(dbManager == nil){
        dbManager = [DBManager getSharedDBManager];
    }
    //create json pkg for db
    NSMutableDictionary *json = [self compileSaveJson];
    NSString *localIdStr = [NSString stringWithFormat:@"%i", 1];
    NSString *autoStr = @"autoSave";
    [json setObject:localIdStr forKey:@"local_id"];
    [json setObject:autoStr forKey:@"name"];
    //save it to the auto save slot
    [dbManager overwriteSavedGarden:json];
    return success;
}


@end