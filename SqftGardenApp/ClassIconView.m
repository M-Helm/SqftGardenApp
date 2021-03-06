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
const int ICON_DEFAULT_BORDER = 0;
const int ICON_DEFAULT_CORNER = 10;
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
    float height = self.bounds.size.height;
    float width = self.bounds.size.width;
    
    UIImage *icon = [UIImage imageNamed: self.iconResource];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    imageView.frame = CGRectMake(5,
                                 5,
                                 self.bounds.size.width -10,
                                 self.bounds.size.height -10);
    [self addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,height-10,width,12)];
    [label setFont:[UIFont boldSystemFontOfSize:11]];
    label.backgroundColor = [UIColor clearColor];
    label.text = self.className;
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    [self setDefaultParameters];
}

- (void) setDefaultParameters{
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = ICON_DEFAULT_BORDER;
    self.layer.cornerRadius = ICON_DEFAULT_CORNER;
    self.layer.backgroundColor = self.fillColor.CGColor;
}

@end