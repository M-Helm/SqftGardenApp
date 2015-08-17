//
//  ApplicationGlobals.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/14/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "ApplicationGlobals.h"



@interface ApplicationGlobals()

@end

@implementation ApplicationGlobals

static ApplicationGlobals *applicationGlobals = nil;
static NSMutableDictionary *currentBedState = nil;

+ (id)getSharedGlobals {
    static ApplicationGlobals *appGlobals = nil;
    @synchronized(self) {
        if (appGlobals == nil){
            appGlobals = [[self alloc] init];
        }
        NSLog(@"%s", __PRETTY_FUNCTION__);
    }
    return appGlobals;
}

- (void) setCurrentBedState:(NSMutableDictionary *)json{
    NSLog(@"setCurrentBedState Called");
    
    if(currentBedState == nil){
        currentBedState = [[NSMutableDictionary alloc] init];
    }
    currentBedState = json;
    
    NSString *str = [currentBedState valueForKey:@"bedstate"];
    NSLog(@"temp string: %@", str);
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]
                                 initWithArray:[str componentsSeparatedByString:@","]];
    //NSMutableArray *tempArray = [str componentsSeparatedByString:@","];
    
    NSString *key = [NSString stringWithFormat:@"cell%i",0];
    int plantId = (int)[[currentBedState valueForKey:key] integerValue];
    NSLog(@"plant Id IN global set = %i", plantId);
    
}

- (NSMutableDictionary *) getCurrentBedState{
    if(currentBedState == nil){
        currentBedState = [[NSMutableDictionary alloc] init];
        
    }
    NSString *str = [currentBedState valueForKey:@"bedstate"];
    //trim the string of the leading and trailing [] chars
    str = [str substringWithRange:NSMakeRange(1, [str length]-1)];
    NSMutableArray *tempArray = [[NSMutableArray alloc]
                                 initWithArray:[str componentsSeparatedByString:@","]];
    
    for(int i=0;i<tempArray.count;i++){
        NSString *tempStr = tempArray[i];
        int plantId = (int)[tempArray[i] integerValue];
        NSLog(@"BEDSTATE plant ID %i, str: %@", plantId, tempStr);
        NSNumber *plant = [NSNumber numberWithInt:plantId];
        NSString *cell = [NSString stringWithFormat:@"cell%i",i];
        [currentBedState setValue:plant forKey:cell];
    }
    
    return currentBedState;
}
- (void) clearCurrentBedState{
    if(currentBedState != nil)[currentBedState removeAllObjects];
}
@end
