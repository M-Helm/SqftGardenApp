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
@property(nonatomic) UIView* startInsideView;
@property(nonatomic) UIView* plantView;
@property(nonatomic) UIView* growingView;
@property(nonatomic) UIView* frostView;
@property(nonatomic) UIView* springView;
@property(nonatomic) UIView* summerView;
@property(nonatomic) UIView* autumnView;
@property(nonatomic) UIImageView* icon;
@property(nonatomic) NSDate *startInsideDate;
@property(nonatomic) NSDate *transplantDate;
@property(nonatomic) NSDate *plantingDate;
@property(nonatomic) NSDate *harvestFromPlantingDate;
@property(nonatomic) NSDate *harvestFromTransplantDate;


@end
