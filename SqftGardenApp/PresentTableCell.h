//
//  PresentTableCell.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/22/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PresentTableCell : UITableViewCell

@property(nonatomic) UILabel* mainLabel;
@property(nonatomic) UIView* harvestView;
@property(nonatomic) UIView* plantView;
@property(nonatomic) UIView* growingView;
@property(nonatomic) UIView* frostView;
//@property(nonatomic) UILabel* countLabel;
@property(nonatomic) UIImageView* icon;


@end
