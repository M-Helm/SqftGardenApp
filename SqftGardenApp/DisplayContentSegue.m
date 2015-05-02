//
//  MainViewController.h
//  SqftGardenApp
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "DisplayContentSegue.h"
#import "MenuViewController.h"
#import "MenuDrawViewController.h"

@implementation DisplayContentSegue

-(void)perform
{
    MenuDrawerViewController* menuDrawerViewController = ((MenuViewController*)self.sourceViewController).menuDrawerViewController;
    menuDrawerViewController.content = self.destinationViewController;
}

@end