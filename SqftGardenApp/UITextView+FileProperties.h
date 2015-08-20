//
//  UIText+FileProperties .h
//  SqftGardenApp
//
//  Created by Matthew Helm on 8/19/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UITextView (FileProperties)

@property(nonatomic) NSNumber * localId;
- (void) setLocalIndex:(NSNumber *)localId;
- (NSNumber *) localId;

@end
