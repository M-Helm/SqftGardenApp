//
//  MainViewController.h
//  SqftGardenApp
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuDrawerViewController;

@interface MenuViewController : UITableViewController
@property(nonatomic, weak) MenuDrawerViewController* menuDrawerViewController;

@end