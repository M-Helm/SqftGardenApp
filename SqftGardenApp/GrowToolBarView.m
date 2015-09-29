//
//  GrowToolBarView.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/28/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import "GrowToolBarView.h"
#import "EditBedViewController.h"

@interface GrowToolBarView()

@end

@implementation GrowToolBarView

EditBedViewController *editBedVC;

- (id)initWithFrame:(CGRect)frame andEditBedVC:(UIViewController*)editBed{
    
    self = [super initWithFrame:frame];
    if (self) {
        editBedVC = (EditBedViewController*)editBed;
        //[self commonInit];
    }
    return self;
}



@end
