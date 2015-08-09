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
    if(currentBedState == nil){
        currentBedState = [[NSMutableDictionary alloc] init];
    }
    currentBedState = json;
    
    NSString *str = [currentBedState valueForKey:@"bedstate"];
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
    return currentBedState;
}
@end
