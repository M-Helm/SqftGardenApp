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

//static SqftGardenModel *currentBedModel = nil;

+ (id)getSharedGlobals {
    static ApplicationGlobals *appGlobals = nil;
    @synchronized(self) {
        if (appGlobals == nil){
            appGlobals = [[self alloc] init];
            appGlobals.appTitle = @"Grow\u00B2";
        }
        //NSLog(@"%s", __PRETTY_FUNCTION__);
    }
    return appGlobals;
}

- (SqftGardenModel *)getCurrentGardenModel{
    //NSLog(@"getmodel called in app globals");
    return self.globalGardenModel;
}

- (void) setCurrentGardenModel:(SqftGardenModel *)currentGardenModel{
    //NSLog(@"APP GLOBALS MODEL INFO: %@", self.globalGardenModel);
    self.globalGardenModel = currentGardenModel;
    //NSLog(@"APP GLOBALS MODEL INFO: %@", self.globalGardenModel);
    [self.globalGardenModel showModelInfo];
    return;
}

- (void) clearCurrentGardenModel{
    self.globalGardenModel = nil;
}

@end
