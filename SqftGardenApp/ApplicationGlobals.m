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
    if(currentBedState != nil){
        currentBedState = [[NSMutableDictionary alloc] init];
    
    }
    currentBedState = json;
}
@end
