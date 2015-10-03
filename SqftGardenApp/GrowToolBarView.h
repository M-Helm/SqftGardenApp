//
//  GrowToolBarView.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/28/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface GrowToolBarView : UIToolbar

- (id)initWithFrame:(CGRect)frame andViewController:(UIViewController*)controller;
- (void) showToolBar;
- (void) hideToolBar;
- (void) enableToolBar;
- (void) enableMenuButton:(bool)enabled;
- (void) enableBackButton:(bool)enabled;

@property(nonatomic) UIView *dateIconView;
@property(nonatomic) UIView *saveIconView;
@property(nonatomic) UIView *dataPresentIconView;
@property(nonatomic) UIView *isoIconView;
@property(nonatomic) UIView *menuIconView;
@property(nonatomic) UIView *backButtonIconView;
@property(nonatomic) int toolBarTag;
@property(nonatomic) bool toolBarIsPinned;
@property(nonatomic) bool toolBarIsEnabled;
@property(nonatomic) bool enableBackButton;
@property(nonatomic) bool enableMenuButton;


@end
