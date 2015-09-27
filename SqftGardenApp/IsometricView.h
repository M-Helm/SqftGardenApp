//
//  IsometricView.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/26/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BedView.h"

@interface IsometricView : UIScrollView
@property(nonatomic) int bedRowCount;
@property(nonatomic) int bedColumnCount;
@property(nonatomic) int bedCellCount;
@property(nonatomic) NSMutableArray *bedViewArray;
@property(nonatomic) BedView *bedFrameView;

-(void) unwindIsoViewTransform;
- (id)initWithFrame:(CGRect)frame andEditBedVC:(UIViewController*)editBed;
@end
