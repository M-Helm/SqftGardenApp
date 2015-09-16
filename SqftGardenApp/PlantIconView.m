//
//  PlantIcon.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/13/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "PlantIconView.h"
#import "DBManager.h"
#import "ApplicationGlobals.h"

@implementation PlantIconView
const int PLANT_ICON_DEFAULT_BORDER = 0;
const int PLANT_ICON_DEFAULT_CORNER = 10;
const int PLANT_ICON_PADDING = 7;
NSString * const PLANT_DEFAULT_ICON = @"ic_cereal_wheat_256.png";
ApplicationGlobals *appGlobals;

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
    appGlobals = [ApplicationGlobals getSharedGlobals];
    //NSLog(@"PLANT VIEW ID TO DB: %i", self.index);
    
    NSDictionary *json = [dbManager getPlantDataById:self.plantId];
    
    self.plantName = [json objectForKey:@"name"];
    self.iconResource = [json objectForKey:@"icon"];
    self.photoResource = [json objectForKey:@"photo"];
    if([self.iconResource isEqualToString:@"na"])self.iconResource = PLANT_DEFAULT_ICON;
    NSString *str = [json objectForKey:@"maturity"];
    NSString *population = [json objectForKey:@"population"];
    self.population = population.intValue;
    self.maturity = str.intValue;
    self.plantClass = [json objectForKey:@"class"];
    if(self.plantClass == nil)self.plantClass = self.plantName;
    self.plantDescription = [json objectForKeyedSubscript:@"description"];
    self.plantScientificName = [json objectForKey:@"scientific_name"];
    self.plantYield = [json objectForKey:@"yield"];
    
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
}

- (void) setLayoutGrid : (int) cellCount{
    if(cellCount < 1)return;
    if(appGlobals.showPlantNumberTokens){
        [self setImageGrid:1 :1];
        [self setNumberTokenImage];
        return;
    }
    if(cellCount == 5)cellCount = 4;
    if(cellCount == 7)cellCount = 6;
    if(self.isIcon){
        [self setImageGrid:1 :1];
        return;
    }
    if(cellCount % 4 == 0){
        if(self.population == 4){
            [self setImageGrid: 2 : 2];
            return;
        }
        if(self.population == 8){
            [self setImageGrid: 4 : 2];
            return;
        }
        if(self.population == 12)[self setImageGrid: 3 : 4];
        else[self setImageGrid: 4 : 4];
        return;
    }
    if(cellCount % 3 == 0){
        if(self.population == 3){
        [   self setImageGrid: 1 : 3];
            return;
        }
        if(self.population == 6){
            [self setImageGrid: 3 : 2];
        }
        else[self setImageGrid: 3 : 3];
        return;
    }
    if(cellCount % 2 == 0){
        [self setImageGrid: 1 : 2];
        return;
    }
    [self setImageGrid:1 :1];

}
-(void) setImageGrid : (int) rowCount : (int) columnCount{
    int rowNumber = 0;
    int columnNumber = 0;
    int cell = 0;
    int cellCount = rowCount * columnCount;
    float iconSize = self.bounds.size.width / (cellCount / columnCount);
    float padding = PLANT_ICON_PADDING / (rowCount);
    float xFrameAdjuster = 0;
    float yFrameAdjuster = 0;
    float centerAdjuster = 0;
    if(cellCount == 2){
        iconSize = self.bounds.size.width / 2;
        yFrameAdjuster = (self.frame.size.width / 2)-(iconSize / 2);
    }
    if(cellCount == 6){
        centerAdjuster = iconSize / 2;
        xFrameAdjuster = (self.frame.size.height / 4)-(iconSize / 2);
        
    }
    if(cellCount == 8){
        xFrameAdjuster = (self.frame.size.height / 4) - (iconSize / 2);
        centerAdjuster = iconSize;
    }
    for(int i=0; i<rowCount; i++){
        while(columnNumber < columnCount){
            UIImage *icon = [UIImage imageNamed: self.iconResource];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
            imageView.frame = CGRectMake(padding + (iconSize * columnNumber) + xFrameAdjuster + (columnNumber * centerAdjuster),
                                         padding + (iconSize * rowNumber) + yFrameAdjuster,
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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, height - 10, width, 9)];
    [label setFont:[UIFont boldSystemFontOfSize:11]];
    label.textColor = [UIColor blackColor];
    if(self.population > 3)label.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    if(appGlobals.showPlantNumberTokens)label.backgroundColor = [UIColor clearColor];
    label.text = self.plantName;
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
}
-(void)setNumberTokenImage{
    if(self.population < 2)return;
    UIImage *icon = [UIImage imageNamed: @"asset_circle_token_512px.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    float iconDimension = self.frame.size.width / 3.5;
    
    imageView.frame = CGRectMake(self.frame.size.width - iconDimension - 3,(iconDimension/4)+3,iconDimension,iconDimension);
    [self addSubview:imageView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((iconDimension - 12)/2,(iconDimension - 12)/2,12,12)];
    NSString *str = [NSString stringWithFormat:@"%i", self.population];
    label.text = str;
    label.textAlignment = NSTextAlignmentCenter;
    [label setFont:[UIFont boldSystemFontOfSize:10]];
    [imageView addSubview:label];
}



@end
