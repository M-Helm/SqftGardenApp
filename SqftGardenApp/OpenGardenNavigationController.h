//
//  OpenGardenNavigationController.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 8/18/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SqftGardenModel.h"

@interface OpenGardenNavigationController : UINavigationController
@property(nonatomic) SqftGardenModel * openedGardenModel;

@end
