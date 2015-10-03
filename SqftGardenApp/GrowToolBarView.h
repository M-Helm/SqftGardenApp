//
//  GrowToolBarView.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/28/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface GrowToolBarView : UIToolbar

- (id) initWithFrame:(CGRect)frame andEditBedVC:(UIViewController*)editBed;
- (void) showToolBar;
- (void) hideToolBar;

@property(nonatomic) UIView *dateIconView;
@property(nonatomic) UIView *saveIconView;
@property(nonatomic) UIView *dataPresentIconView;
@property(nonatomic) UIView *isoIconView;
@property(nonatomic) UIView *menuIconView;
@property(nonatomic) int toolBarTag;

@end
