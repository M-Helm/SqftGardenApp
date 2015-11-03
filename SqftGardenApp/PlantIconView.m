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

- (id)initWithFrame:(CGRect)frame withPlantUuid: (NSString *)plantUuid isIsometric:(bool)isIsometric{
    self.plantUuid = plantUuid;
    self.isIsometric = isIsometric;
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
    if([self.plantUuid isEqualToString:@"cancel"]){
        [self setAsCancelIcon];
        return;
    }
    DBManager *dbManager = [DBManager getSharedDBManager];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    
    NSDictionary *json = [dbManager getPlantDataByUuid:self.plantUuid];
    
    self.plantUuid = [json objectForKey:@"uuid"];
    self.plantName = [json objectForKey:@"name"];
    self.plantClass = [json objectForKey:@"class"];
    if(self.plantClass == nil)self.plantClass = self.plantName;
    
    self.iconResource = [json objectForKey:@"icon"];
    self.photoResource = [json objectForKey:@"photo"];
    self.plantDescription = [json objectForKeyedSubscript:@"description"];
    self.plantScientificName = [json objectForKey:@"scientific_name"];
    self.plantYield = [json objectForKey:@"yield"];
    self.isoIcon =[json objectForKey:@"isoIcon"];
    NSString *str = [json objectForKey:@"maturity"];
    self.maturity = str.intValue;
    NSString *population = [json objectForKey:@"population"];
    self.population = population.intValue;
    NSString *tall = [json objectForKey:@"isTall"];
    self.isTall = tall.intValue;
    NSString *delta = [json objectForKey:@"plantingDelta"];
    self.plantingDelta = delta.intValue;
    NSString *seed = [json objectForKey:@"start_seed"];
    self.startSeed = seed.intValue;
    NSString *inside = [json objectForKey:@"start_inside"];
    self.startInside = inside.intValue;
    NSString *insideDelta = [json objectForKey:@"start_inside_delta"];
    self.startInsideDelta = insideDelta.intValue;
    NSString *transDelta = [json objectForKey:@"transplant_delta"];
    self.transplantDelta = transDelta.intValue;
    NSString *sqFeet = [json objectForKey:@"square_feet"];
    self.squareFeet = sqFeet.intValue;
    
    NSString *jsonString = [json objectForKey:@"tip_json"];
    self.tipJsonArray = [jsonString componentsSeparatedByString:@"{"];
    //NSStringEncoding  encoding;
    //NSData * jsonData = [jsonString dataUsingEncoding:encoding];
    //self.tipJson = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    
    if([self.iconResource isEqualToString:@"na"])self.iconResource = PLANT_DEFAULT_ICON;
    [self setLayoutGrid:population.intValue];
    [self updateLabel];
    [self setDefaultParameters];
}

- (void) setDefaultParameters {
    self.color = [UIColor clearColor];
    self.fillColor = [self.color colorWithAlphaComponent:0.25];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = PLANT_ICON_DEFAULT_BORDER;
    self.layer.cornerRadius = PLANT_ICON_DEFAULT_CORNER;
}

- (void) setLayoutGrid : (int) cellCount {
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
- (void) setImageGrid : (int) rowCount : (int) columnCount {
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
            if(self.isIsometric)imageView.alpha = 0.0;
            [self addSubview:imageView];
            columnNumber++;
            cell++;
        }
        columnNumber = 0;
        rowNumber++;
    }
}
-(void) setViewAsIcon:(bool)isIcon {
    self.isIcon = isIcon;
    for(UIView* subview in self.subviews) {
        if([subview class] == [UIImageView class])[subview removeFromSuperview];
    }
    self.population = 1;
    [self setImageGrid:1 :1];
    [self updateLabel];
}
-(void) updateLabel {
    for(UIView* subview in self.subviews) {
        if([subview class] == [UILabel class])[subview removeFromSuperview];
    }
    float height = self.bounds.size.height;
    float width = self.bounds.size.width;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, height - 11, width, 11)];
    [label setFont:[UIFont boldSystemFontOfSize:10]];
    label.textColor = [UIColor blackColor];
    if(self.population > 3)label.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    if(appGlobals.showPlantNumberTokens)label.backgroundColor = [UIColor clearColor];
    label.text = self.plantName;
    if(self.isIsometric)label.text = @"";
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
}
-(void) setNumberTokenImage {
    if(self.isIsometric)return;
    //if(self.population < 2)return;
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

// Coordinate utilities
- (CGPoint) offsetPointToParentCoordinates: (CGPoint) aPoint{
    return CGPointMake(aPoint.x + self.center.x,
                       aPoint.y + self.center.y);
}

- (CGPoint) pointInViewCenterTerms: (CGPoint) aPoint{
    return CGPointMake(aPoint.x - self.center.x,
                       aPoint.y - self.center.y);
}

- (CGPoint) pointInTransformedView: (CGPoint) aPoint{
    CGPoint offsetItem = [self pointInViewCenterTerms:aPoint];
    CGPoint updatedItem = CGPointApplyAffineTransform(
                                                      offsetItem, self.transform);
    CGPoint finalItem =
    [self offsetPointToParentCoordinates:updatedItem];
    return finalItem;
}

- (CGRect) originalFrame{
    CGAffineTransform currentTransform = self.transform;
    self.transform = CGAffineTransformIdentity;
    CGRect originalFrame = self.frame;
    self.transform = currentTransform;
    
    return originalFrame;
}

// These four methods return the positions of view elements
// with respect to the current transform

- (CGPoint) transformedTopLeft{
    CGRect frame = self.originalFrame;
    CGPoint point = frame.origin;
    return [self pointInTransformedView:point];
}

- (CGPoint) transformedTopRight{
    CGRect frame = self.originalFrame;
    CGPoint point = frame.origin;
    point.x += frame.size.width;
    return [self pointInTransformedView:point];
}

- (CGPoint) transformedBottomRight{
    CGRect frame = self.originalFrame;
    CGPoint point = frame.origin;
    point.x += frame.size.width;
    point.y += frame.size.height;
    return [self pointInTransformedView:point];
}

- (CGPoint) transformedBottomLeft{
    CGRect frame = self.originalFrame;
    CGPoint point = frame.origin;
    point.y += frame.size.height;
    return [self pointInTransformedView:point];
}
- (CGPoint) transformedCenter{
    CGRect frame = self.originalFrame;
    CGPoint point;
    point.x = frame.origin.x - (frame.size.width/2);
    point.y = frame.origin.y - (frame.size.height/2);
    return [self pointInTransformedView:point];
}



@end
