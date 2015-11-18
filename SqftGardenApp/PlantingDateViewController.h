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

@interface PlantingDateViewController : UIViewController <CLLocationManagerDelegate>
@property (nonatomic) UILabel *zoneView;
@property (nonatomic) NSArray *zoneArray;
@end