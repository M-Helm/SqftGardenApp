//
//  MainViewController.h
//  SqftGardenApp
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/Analytics.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "SqftGardenModel.h"
#import "SelectPlantView.h"
#import "DateSelectView.h"
#import "IsometricView.h"
#import "GrowToolBarView.h"


@interface EditBedViewController : UIViewController <FBSDKSharingDelegate>
@property(nonatomic) SqftGardenModel *currentGardenModel;
@property(nonatomic) DateSelectView *datePickerView;
@property(nonatomic) SelectPlantView *selectPlantView;
@property(nonatomic) GrowToolBarView *toolBar;
@property(nonatomic) IsometricView *isoView;

@property(nonatomic) bool datePickerIsOpen;
@property(nonatomic) bool isoViewIsOpen;
@property(nonatomic) bool toolBarIsOpen;
@property(nonatomic) bool showTouches;

@property(nonatomic) int topOffset;
@property(nonatomic) int sideOffset;
@property(nonatomic) int cellHorizontalPadding;
@property(nonatomic) float heightMultiplier;
@property(nonatomic) int bedRowCount;
@property(nonatomic) int bedColumnCount;
@property(nonatomic) int bedCellCount;
@property(nonatomic) NSMutableArray *bedViewArray;
@property(nonatomic) NSMutableArray *selectPlantArray;

@property(nonatomic) UIView *bedFrameView;
@property(nonatomic) UIView *selectMessageView;
@property(nonatomic) UILabel *selectMessageLabel;
@property(nonatomic) UIView *titleView;

@property(nonatomic) UIView *toolBarContainer;
@property(nonatomic) UIImageView *touchIcon;
@property(nonatomic) UIImageView *shareButton;



- (void) updatePlantBeds : (int)updatedCell : (NSString *)plantUuid;
- (void) updatePlantingDate : (NSDate *)date;
- (void) initViews;
- (void) unwindIsoView;
- (CGRect)calculateBedFrame;
- (void) showWriteSuccessAlertForFile: (NSString *)fileName atIndex: (int) index;
- (void) showDatePickerView;
- (void) hideSelectView;
- (void) showSelectView;
- (void) makeShareButton;

@end




