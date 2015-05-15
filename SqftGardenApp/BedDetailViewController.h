//
//  BedDetailViewController.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/13/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BedDetailViewController : UIViewController
@property int plantID;
@property(nonatomic) UIView *bedFrameView;
@property(nonatomic) UIView *selectPlantView;
@property(nonatomic) int bedRowCount;
@property(nonatomic) int bedColumnCount;
@property(nonatomic) int bedCellCount;
@property(nonatomic) NSMutableArray *bedViewArray;
@property(nonatomic) NSMutableArray *selectPlantArray;

@end
