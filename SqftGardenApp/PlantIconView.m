//
//  PlantIcon.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/13/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "PlantIconView.h"
#import "DBManager.h"

@implementation PlantIconView
const int PLANT_ICON_DEFAULT_BORDER = 0;
const int PLANT_ICON_DEFAULT_CORNER = 10;
NSString * const PLANT_DEFAULT_ICON = @"ic_cereal_wheat_256.png";
//int plantId;

- (id)initWithFrame:(CGRect)frame : (int)plantIndex{
    //self.index = plantIndex;
    self.plantId = plantIndex;
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [self commonInit];
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    DBManager *dbManager = [DBManager getSharedDBManager];
    //NSLog(@"PLANT VIEW ID TO DB: %i", self.index);
    
    NSDictionary *json = [dbManager getPlantDataById:self.plantId];
    
    self.plantName = [json objectForKey:@"name"];
    self.iconResource = [json objectForKey:@"icon"];
    if([self.iconResource isEqualToString:@"na"])self.iconResource = PLANT_DEFAULT_ICON;
    NSString *str = [json objectForKey:@"maturity"];
    NSString *population = [json objectForKey:@"population"];
    self.maturity = str.intValue;
    self.plantClass = [json objectForKey:@"class"];
    //NSString *str2 = [json objectForKey:@"plant_id"];
    //self.plantId = str2.intValue;
    if(self.plantClass == nil)self.plantClass = self.plantName;
    
    float height = self.bounds.size.height;
    float width = self.bounds.size.width;
    
    UIImage *icon = [UIImage imageNamed: self.iconResource];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    imageView.frame = CGRectMake(7,
                                 7,
                                 self.bounds.size.width-14,
                                 self.bounds.size.height-14);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, height - 9, width, 9)];
    //UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,height-15,width,15)];
    [label setFont:[UIFont systemFontOfSize:9]];
    label.backgroundColor = [UIColor clearColor];
    //NSString *msg = [NSString stringWithFormat:@"%@, Pop: %@", self.plantName, population];
    label.text = self.plantName;
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:imageView];
    [self addSubview:label];
    [self setDefaultParameters];
}

- (void) setDefaultParameters{
    self.color = [UIColor clearColor];
    self.fillColor = [self.color colorWithAlphaComponent:0.25];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = PLANT_ICON_DEFAULT_BORDER;
    self.layer.cornerRadius = PLANT_ICON_DEFAULT_CORNER;
    //self.layer.cornerRadius = self.frame.size.width / 2;
    //self.layer.backgroundColor = self.fillColor.CGColor;
}


@end
