//
//  OpenGardenNavigationController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 8/18/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "OpenGardenNavigationController.h"
#import "EditBedViewController.h"

@interface OpenGardenNavigationController()

@end

@implementation OpenGardenNavigationController


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Nav Controller Prepare Segue to main with opened Garden Model");
    if([segue.identifier isEqualToString:@"showMain"])
    {
        NSLog(@"PREPARE CALLED....");
        //BedDetailViewController *bedDetail = (BedDetailViewController*)segue.destinationViewController;
    }
    //NSLog(@"Menu Prepare Segue");
    if([segue.identifier isEqualToString:@"embedMenu"])
    {
        EditBedViewController* editBedViewController = segue.destinationViewController;
        self.openedGardenModel = [[SqftGardenModel alloc] init];
        [self.openedGardenModel setRows:4];
        [self.openedGardenModel setColumns:4];
        editBedViewController.currentGardenModel = self.openedGardenModel;
    }
    
}
@end