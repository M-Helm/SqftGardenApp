//
//  ApplicationGlobals.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/14/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "ApplicationGlobals.h"


@interface ApplicationGlobals()
+ applicationGlobals;

@end

@implementation ApplicationGlobals

static ApplicationGlobals *applicationGlobals = nil;

+ (id) applicationGlobals {
    if (! applicationGlobals) {
        
        applicationGlobals = [[ApplicationGlobals alloc] init];
    }
    return applicationGlobals;
}

- (id) init {
    if (! applicationGlobals) {
        
        applicationGlobals = [super init];
        // NSLog(@"%s", __PRETTY_FUNCTION__);
    }
    return applicationGlobals;
}

@end
