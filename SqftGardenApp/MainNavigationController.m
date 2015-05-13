//
//  MainNavigationController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/13/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "MainNavigationController.h"
#import "BedDetailViewController.h"

@interface MainNavigationController()

@end

@implementation MainNavigationController


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Nav Controller Prepare Segue without changing anything");
    if([segue.identifier isEqualToString:@"showBedDetail"])
    {
        BedDetailViewController *bedDetail = (BedDetailViewController*)segue.destinationViewController;
        bedDetail.plantID = 69;
        
    }
}
@end