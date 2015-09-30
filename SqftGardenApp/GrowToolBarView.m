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
        [self commonInit];
    }
    return self;
}

-(void) commonInit{
    
    /*
    NSMutableArray *items = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexiableItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:nil];
    
    [items addObject:flexiableItem];
    [items addObject:item1];
    [items addObject:item2];
    
    [self setItems:items animated:YES];
    
    */
}


@end
