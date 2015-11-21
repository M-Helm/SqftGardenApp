//
//  TimelineView.h
//  GrowSquared
//
//  Created by Matthew Helm on 11/20/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineView : UIView

@property(nonatomic)CGFloat pointsPerDay;
@property(nonatomic)int maxDays;

- (id)initWithFrame:(CGRect)frame withPlantUuid: (NSString *)plantUuid pointsPerDay: (CGFloat)pointsPerDay;

@end
