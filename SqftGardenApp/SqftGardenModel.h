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
@property(nonatomic) int local_id;
@property(nonatomic) NSMutableArray *bedStateArray;

@end


