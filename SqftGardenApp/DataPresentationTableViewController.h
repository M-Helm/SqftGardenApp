//
//  DataPresentationTableViewController.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/22/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import<UIKit/UIKit.h>
#import <Google/Analytics.h>
#import "DateSelectView.h"

@interface DataPresentationTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic) bool datePickerIsOpen;
@property(nonatomic) DateSelectView *datePickerView;
- (void) showDatePickerView;



@end
