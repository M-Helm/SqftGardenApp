//
//  MainViewController.h
//  SqftGardenApp
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface MenuDrawerViewController : UIViewController

@property(nonatomic, weak) UIViewController* content;
+ (id) getSharedMenuDrawer;
//- (void) showEditView;

@end