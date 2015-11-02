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
            appGlobals.showPlantNumberTokens = YES;
            appGlobals.hasShownLaunchScreen = NO;
        }
        //NSLog(@"%s", __PRETTY_FUNCTION__);
    }
    return appGlobals;
}

// Assumes input like "#00FF00" (#RRGGBB).
- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

//Appglobals gets another Util method
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (SqftGardenModel *)getCurrentGardenModel{
    //NSLog(@"getmodel called in app globals");
    return self.globalGardenModel;
}

- (void) setCurrentGardenModel:(SqftGardenModel *)currentGardenModel{
    //NSLog(@"APP GLOBALS MODEL INFO: %@", self.globalGardenModel);
    self.globalGardenModel = currentGardenModel;
    //NSLog(@"APP GLOBALS MODEL INFO: %@", self.globalGardenModel);
    //[self.globalGardenModel showModelInfo];
    return;
}

- (void) clearCurrentGardenModel{
    self.globalGardenModel = nil;
}

@end
