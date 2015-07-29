//
//  PlantModel.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/12/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "PlantIconView.h"


@interface PlantModel : NSObject

//@property (nonatomic, strong)PlantIconView *icon;
@property (nonatomic)NSString *name;
@property (nonatomic)NSString *iconResource;
@property (nonatomic)int maturity;
@property (nonatomic)int population;

@end