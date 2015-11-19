//
//  ZoneSelectView.h
//  GrowSquared
//
//  Created by Matthew Helm on 11/18/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import<UIKit/UIKit.h>


@interface ZoneSelectView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property(nonatomic) NSArray *zoneArray;
- (void)createZonePicker:(id)sender;

@end