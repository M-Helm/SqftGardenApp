//
//  ClassIconView.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/9/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "ClassIconView.h"
#import "DBManager.h"

@implementation ClassIconView
const int ICON_DEFAULT_BORDER = 3;
const int ICON_DEFAULT_CORNER = 30;
NSString * const DEFAULT_ICON = @"ic_cereal_wheat_256.png";


- (id)initWithFrame:(CGRect)frame : (int)classIndex{
    self.index = classIndex;
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
    self.backgroundColor = [UIColor blackColor];
    DBManager *dbManager = [DBManager getSharedDBManager];
    
    NSDictionary *json = [dbManager getClassDataById:self.index];
    
    self.className = [json objectForKey:@"name"];
    self.iconResource = [json objectForKey:@"icon"];
    if([self.iconResource isEqualToString:@"na"])self.iconResource = DEFAULT_ICON;
    NSString *str = [json objectForKey:@"maturity"];
    self.maturity = str.intValue;
    //self.plantClass = [json objectForKey:@"class"];
    //if(self.plantClass == nil)self.plantClass = self.plantName;
    
    float height = self.bounds.size.height;
    float width = self.bounds.size.width;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,height-15,width,15)];
    [label setFont:[UIFont systemFontOfSize:9]];
    label.backgroundColor = [UIColor clearColor];
    label.text = self.className;
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    [self setDefaultParameters];
}

- (void) setDefaultParameters{
    self.color = [UIColor blackColor];
    self.fillColor = [self.color colorWithAlphaComponent:0.25];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = ICON_DEFAULT_BORDER;
    //self.layer.cornerRadius = ICON_DEFAULT_CORNER;
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.backgroundColor = self.fillColor.CGColor;
}

@end