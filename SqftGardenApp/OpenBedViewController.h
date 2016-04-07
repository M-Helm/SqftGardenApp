//
//  OpenBedViewController.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 8/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/Analytics.h>
#import <Appirater.h>



@interface OpenBedViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic)NSMutableArray *savedBedJson;


@end