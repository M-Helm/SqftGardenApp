//
//  IsomorphicViewController.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/25/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IsomorphicViewController : UIViewController
@property(nonatomic) int bedRowCount;
@property(nonatomic) int bedColumnCount;
@property(nonatomic) int bedCellCount;
@property(nonatomic) NSMutableArray *bedViewArray;
@property(nonatomic) UIView *bedFrameView;

@end
