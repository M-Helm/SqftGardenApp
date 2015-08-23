//
//  MainNavigationController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/13/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "MainNavigationController.h"
#import "BedDetailViewController.h"
#import "ApplicationGlobals.h"

@interface MainNavigationController()

@end

@implementation MainNavigationController
ApplicationGlobals *appGlobals;

- (void)viewDidLoad {
    [super viewDidLoad];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showBedDetail"])
    {
        //BedDetailViewController *bedDetail = (BedDetailViewController*)segue.destinationViewController;
    }
}
@end