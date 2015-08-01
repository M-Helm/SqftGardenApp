//
//  MainViewController.h
//  SqftGardenApp
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EditBedViewController : UIViewController
@property(nonatomic) int bedRowCount;
@property(nonatomic) int bedColumnCount;
@property(nonatomic) int bedCellCount;
@property(nonatomic) NSMutableArray *bedViewArray;
@property(nonatomic) NSMutableDictionary *bedStateDict;
@property(nonatomic) NSMutableArray *selectPlantArray;
@property(nonatomic) UIView *bedFrameView;
@property(nonatomic) UIView *selectMessageView;
- (void) updatePlantBeds : (int)updatedCell : (int)plantId;

@end




