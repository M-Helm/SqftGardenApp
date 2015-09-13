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
const int PLANT_ICON_PADDING = 7;
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
-(void)setAsCancelIcon{
    self.plantName = @"Cancel";
    self.iconResource = @"ic_cancel_256px.png";
    [self setViewAsIcon:true];
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    if(self.plantId == -1){
        [self setAsCancelIcon];
        return;
    }
    DBManager *dbManager = [DBManager getSharedDBManager];
    //NSLog(@"PLANT VIEW ID TO DB: %i", self.index);
    
    NSDictionary *json = [dbManager getPlantDataById:self.plantId];
    
    self.plantName = [json objectForKey:@"name"];
    self.iconResource = [json objectForKey:@"icon"];
    if([self.iconResource isEqualToString:@"na"])self.iconResource = PLANT_DEFAULT_ICON;
    NSString *str = [json objectForKey:@"maturity"];
    NSString *population = [json objectForKey:@"population"];
    self.population = population.intValue;
    self.maturity = str.intValue;
    self.plantClass = [json objectForKey:@"class"];
    //NSString *str2 = [json objectForKey:@"plant_id"];
    //self.plantId = str2.intValue;
    if(self.plantClass == nil)self.plantClass = self.plantName;
    
    [self setLayoutGrid:population.intValue];
    [self updateLabel];
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

- (void) setLayoutGrid : (int) cellCount{
    if(cellCount < 1)return;
    if(self.isIcon){
        [self setImageGrid:1 :1];
        return;
    }
    
    if(cellCount % 4 == 0){
        [self setImageGrid: 4 : 4];
        //self.label.backgroundColor = [UIColor whiteColor];
        return;
    }
    if(cellCount % 3 == 0){
        [self setImageGrid: 3 : 3];
        //self.label.backgroundColor = [UIColor whiteColor];
        //self.label.text= @"THIS";
        return;
    }
    if(cellCount % 2 == 0){
        [self setImageGrid: 1 : 2];
        return;
    }
    [self setImageGrid:1 :1];

}
-(void) setImageGrid : (int) rowCount : (int) columnCount{
    //rowCount = 4;
    //columnCount = 4;
    int rowNumber = 0;
    int columnNumber = 0;
    int cell = 0;
    int cellCount = rowCount * columnCount;

    float iconSize = self.bounds.size.width / (cellCount / rowCount);
    float padding = PLANT_ICON_PADDING / (rowCount);
    float frameAdjuster = 0;
    if(cellCount == 2)frameAdjuster = (self.frame.size.width / 2)-(iconSize / 2);
    
    
    for(int i=0; i<rowCount; i++){
        while(columnNumber < columnCount){
            UIImage *icon = [UIImage imageNamed: self.iconResource];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
            imageView.frame = CGRectMake(padding + (iconSize * columnNumber),
                                         padding + (iconSize * rowNumber) + frameAdjuster,
                                         iconSize-(padding * 2),
                                         iconSize-(padding * 2));
            [self addSubview:imageView];
            columnNumber++;
            cell++;
        }
        columnNumber = 0;
        rowNumber++;
    }
}
-(void)setViewAsIcon:(bool)isIcon{
    self.isIcon = isIcon;
    for(UIView* subview in self.subviews){
        if([subview class] == [UIImageView class])[subview removeFromSuperview];
    }
    self.population = 1;
    [self setImageGrid:1 :1];
    [self updateLabel];
}
-(void)updateLabel{
    for(UIView* subview in self.subviews){
        if([subview class] == [UILabel class])[subview removeFromSuperview];
    }
    float height = self.bounds.size.height;
    float width = self.bounds.size.width;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, height - 9, width, 9)];
    [label setFont:[UIFont boldSystemFontOfSize:9]];
    label.textColor = [UIColor blackColor];
    if(self.population > 3)label.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    label.text = self.plantName;
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
}


@end
