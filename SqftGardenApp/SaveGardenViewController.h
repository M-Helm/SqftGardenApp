//
//  SaveGardenViewController.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 8/18/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SqftGardenModel.h"

@interface SaveGardenViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
@property (nonatomic) SqftGardenModel *tempModel;


@end
