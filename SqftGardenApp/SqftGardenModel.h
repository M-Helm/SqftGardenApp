//
//  SqftGardenModel.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 8/17/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SqftGardenModel : NSObject

@property(nonatomic) int columns;
@property(nonatomic) int rows;
@property(nonatomic) NSString *name;
@property(nonatomic) int timestamp;
@property(nonatomic) NSString *bedStateArrayString;
@property(nonatomic) NSMutableDictionary *bedStateDictionary;
@property(nonatomic) int localId;
@property(nonatomic) NSString *uniqueId;

- (id)initWithDict:(NSDictionary*)dict;
- (void)clearCurrentBedState;
- (NSString *)getBedStateArrayString;
- (NSMutableDictionary *)getCurrentBedState;
- (void) setCurrentBedState:(NSMutableDictionary *)json;
- (void) setBedRows:(int) rows;
- (void) setBedColumns:(int) columns;
- (int) getPlantIdForCell:(int) cell;
- (void) setPlantIdForCell:(int) cell :(int) plant;
- (void) showModelInfo;
//- (NSString *)getUUID;

@end


