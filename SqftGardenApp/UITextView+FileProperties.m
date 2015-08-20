//
//  UIText+FileProperties.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 8/19/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "UITextView+FileProperties.h"
#import <objc/runtime.h>


static void *MyClassResultKey;
@implementation UITextView (FileProperties)

- (NSNumber *)localId {
    NSNumber *index = objc_getAssociatedObject(self, &MyClassResultKey);
    if (index == nil) {
        index = [NSNumber numberWithInt:0];
        objc_setAssociatedObject(self, &MyClassResultKey, index, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return index;
}

- (void)setLocalId : (NSNumber *) localId{
    
}

- (void) setLocalIndex:(NSNumber *)index{
    NSLog(@"INDEX GIVEN = %i", (int)index);
    self.localId = index;
    objc_setAssociatedObject(self, &MyClassResultKey, index, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end