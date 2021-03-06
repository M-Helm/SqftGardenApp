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
const int PLANT_ICON_DEFAULT_BORDER = 1;
const int PLANT_ICON_DEFAULT_CORNER = 10;
const int PLANT_ICON_PADDING = 7;

ApplicationGlobals *appGlobals;

- (id)initWithFrame:(CGRect)frame withPlantUuid: (NSString *)plantUuid isIsometric:(bool)isIsometric{
    self.plantUuid = plantUuid;
    self.isIsometric = isIsometric;
    self = [super initWithFrame:frame];
    if (self) {
        self.model = [[PlantModel alloc]initWithUUID:plantUuid];
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
    //self.model.plantName = @"Cancel";
    self.model.iconResource = @"ic_cancel_256px.png";
    [self setViewAsIcon:true];
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    if([self.plantUuid isEqualToString:@"cancel"]){
        [self setAsCancelIcon];
        return;
    }
    //DBManager *dbManager = [DBManager getSharedDBManager];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    
    //NSDictionary *json = [dbManager getPlantDataByUuid:self.plantUuid];
    




    //NSStringEncoding  encoding;
    //NSData * jsonData = [jsonString dataUsingEncoding:encoding];
    //self.tipJson = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    
    //if([self.iconResource isEqualToString:@"na"])self.iconResource = PLANT_DEFAULT_ICON;
    [self setLayoutGrid:self.model.population];
    [self updateLabel];
    [self setDefaultParameters];
}

- (void) setDefaultParameters {
    self.color = [UIColor clearColor];
    self.fillColor = [self.color colorWithAlphaComponent:0.25];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = PLANT_ICON_DEFAULT_BORDER;
    //if(self.model.isTall)self.layer.borderWidth = 0;
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
        if(self.model.population == 4){
            [self setImageGrid: 2 : 2];
            return;
        }
        if(self.model.population == 8){
            [self setImageGrid: 4 : 2];
            return;
        }
        if(self.model.population == 12)[self setImageGrid: 3 : 4];
        else[self setImageGrid: 4 : 4];
        return;
    }
    if(cellCount % 3 == 0){
        if(self.model.population == 3){
        [   self setImageGrid: 1 : 3];
            return;
        }
        if(self.model.population == 6){
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
    //remove old subviews
    for(UIView *subview in self.subviews){
        [subview removeFromSuperview];
    }
    
    int rowNumber = 0;
    int columnNumber = 0;
    int cell = 0;
    int cellCount = rowCount * columnCount;
    float iconOffset = self.bounds.size.width / (cellCount / columnCount);
    float iconSize = self.bounds.size.width / (cellCount / columnCount);
    //reset size if we're more than 1 sqft
    if(self.model.squareFeet > 1)iconSize = appGlobals.bedDimension-5;
    float padding = PLANT_ICON_PADDING / (rowCount);
    float xFrameAdjuster = 0;
    float yFrameAdjuster = 0;
    float centerAdjuster = 0;
    if(cellCount == 2){
        iconOffset = self.bounds.size.width / 2;
        yFrameAdjuster = (self.frame.size.width / 2)-(iconOffset / 2);
    }
    if(cellCount == 6){
        centerAdjuster = iconOffset / 2;
        xFrameAdjuster = (self.frame.size.height / 4)-(iconOffset / 2);
        
    }
    if(cellCount == 8){
        xFrameAdjuster = (self.frame.size.height / 4) - (iconOffset / 2);
        centerAdjuster = iconOffset;
    }
    for(int i=0; i<rowCount; i++){
        while(columnNumber < columnCount){
            UIImage *icon = [UIImage imageNamed: self.model.iconResource];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
            CGRect frame = CGRectMake(padding + (iconOffset * columnNumber) + xFrameAdjuster + (columnNumber * centerAdjuster),
                                         padding + (iconOffset * rowNumber) + yFrameAdjuster,
                                         iconSize-(padding * 2),
                                         iconSize-(padding * 2));
            //change origins if we're mutli sqft
            if(self.model.squareFeet > 1){
                frame = CGRectMake(padding + self.frame.size.width/2 - ((appGlobals.bedDimension -5) /2),
                                   padding + self.frame.size.height/2 - ((appGlobals.bedDimension -5) /2),
                                   iconSize-(padding*2),
                                   iconSize-(padding*2));
            }
            //extra steps if we're iso
            if(self.isIsometric){
                imageView.alpha = 0.0;
            }
            
            
            imageView.frame = frame;
            [self addSubview:imageView];
            if(self.model.squareFeet > 1 && self.isIcon == NO){
                [self updateLabel];
                [self setNumberTokenImage];
            }
            
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
    self.model.population = 1;
    [self setImageGrid:1 :1];
    [self updateLabel];
}
-(void) updateLabel {
    for(UIView* subview in self.subviews) {
        if([subview class] == [UILabel class])[subview removeFromSuperview];
    }
    float height = self.frame.size.height;
    float width = self.frame.size.width;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, height - 11, width, 11)];
    if(self.model.squareFeet > 1 && self.isIcon == NO){
        CGRect frame = CGRectMake(0,height-(appGlobals.bedDimension * .5), width, 11);
        label.frame = frame;
    }
    [label setFont:[UIFont boldSystemFontOfSize:10]];
    label.textColor = [UIColor blackColor];
    if(self.model.population > 3)label.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    if(appGlobals.showPlantNumberTokens)label.backgroundColor = [UIColor clearColor];
    label.text = self.model.plantName;
    if(self.isIsometric)label.text = @"";
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
}
-(void) setNumberTokenImage {
    
    //frame = CGRectMake(padding + self.frame.size.width/2 - ((appGlobals.bedDimension -5) /2),
    //                   padding + self.frame.size.height/2 - ((appGlobals.bedDimension -5) /2),
    //                   iconSize-(padding*2),
    //                   iconSize-(padding*2));
    
    
    if(self.isIsometric)return;
    //if(self.population < 2)return;
    UIImage *icon = [UIImage imageNamed: @"asset_circle_token_512px.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    float iconDimension = self.frame.size.width / 3.5;
    
    imageView.frame = CGRectMake(self.frame.size.width - iconDimension - 3,(iconDimension/4)+3,iconDimension,iconDimension);
    if(self.model.squareFeet > 1){
        CGRect frame = CGRectMake(((self.frame.size.width - (iconDimension/2) - 3)*.70),((iconDimension/2))*2,(iconDimension/2),(iconDimension/2));
        imageView.frame = frame;
    }
    
    
    [self addSubview:imageView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((iconDimension - 12)/2,(iconDimension - 12)/2,12,12)];
    if(self.model.squareFeet > 1){
        CGRect frame = CGRectMake(((iconDimension /2) - 12)/2,((iconDimension /2)- 12)/2,12,12);
        label.frame = frame;
    }
    NSString *str = [NSString stringWithFormat:@"%i", self.model.population];
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
