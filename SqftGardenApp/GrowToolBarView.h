//
//  GrowToolBarView.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/28/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Google/Analytics.h>
#import "GrowLocationManager.h"

@interface GrowToolBarView : UIToolbar

- (id)initWithFrame:(CGRect)frame andViewController:(UIViewController*)controller;
- (void) showToolBar;
- (void) hideToolBar;
- (void) enableToolBar;
- (void) enableMenuButton:(bool)enabled;
- (void) enableBackButton:(bool)enabled;
- (void) enableDateButton:(bool)enabled;
- (void) enableIsoButton:(bool)enabled;
- (void) enableSaveButton:(bool)enabled;
- (void) enableDateOverride:(bool)canOverrideDate;

@property(nonatomic) UIView *dateIconView;
@property(nonatomic) UIView *saveIconView;
@property(nonatomic) UIView *dataPresentIconView;
@property(nonatomic) UIView *isoIconView;
@property(nonatomic) UIView *menuIconView;
@property(nonatomic) UIView *backButtonIconView;
@property(nonatomic) GrowLocationManager *locationManager;
@property(nonatomic) int toolBarTag;
@property(nonatomic) bool toolBarIsPinned;
@property(nonatomic) bool toolBarIsEnabled;
@property(nonatomic) bool dateSelected;
@property(nonatomic) bool enableBackButton;
@property(nonatomic) bool enableMenuButton;
@property(nonatomic) bool enableDateButton;
@property(nonatomic) bool enableIsoButton;
@property(nonatomic) bool enableSaveButton;
@property(nonatomic) bool canOverrideDate;
@property(nonatomic) bool isoViewIsOpen;


@end
