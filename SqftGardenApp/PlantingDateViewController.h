//
//  PlantingDateViewController.h
//  GrowSquared
//
//  Created by Matthew Helm on 11/18/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIkit.h>
#import <Google/Analytics.h>
#import <CoreLocation/CoreLocation.h>
#import "DateSelectView.h"
#import "ZoneSelectView.h"

@interface PlantingDateViewController : UIViewController <CLLocationManagerDelegate>
@property (nonatomic) UILabel *zoneView;
@property (nonatomic) UILabel *frostView;
@property (nonatomic) UILabel *zoneButton;
@property (nonatomic) UILabel *frostButton;
@property (nonatomic) UILabel *acceptButton;
@property (nonatomic) NSArray *zoneArray;
@property (nonatomic) BOOL datePickerIsOpen;
@property (nonatomic) BOOL zonePickerIsOpen;
@property (nonatomic) DateSelectView *datePickerView;
@property (nonatomic) ZoneSelectView *zonePickerView;

-(void) showDatePickerView;
-(void) showZonePickerView;
@end