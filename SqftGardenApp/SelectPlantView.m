//
//  PlantSelectView.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/12/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "SelectPlantView.h"
#import "PlantIconView.h"
#import "ApplicationGlobals.h"
#import "BedView.h"


@implementation SelectPlantView
ApplicationGlobals *appGlobals;
float startX = 0;
float startY = 0;
PlantIconView *touchedIcon;


- (id)initWithFrame:(CGRect)frame {
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
    //NSLog(@"selectPlantViewcreated");
    self.backgroundColor = [UIColor whiteColor];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    [self setDefaultParameters];
    [self setScrollView];
}

- (void) setDefaultParameters{
    self.color = [UIColor lightGrayColor];
    self.fillColor = [self.color colorWithAlphaComponent:0.25];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 3;
    self.layer.cornerRadius = 15;
    self.layer.masksToBounds = NO;
}

- (void) setScrollView{
    // Adjust scroll view content size
    self.contentSize = CGSizeMake(self.frame.size.width * 3, appGlobals.bedDimension);
    self.pagingEnabled=YES;
    self.backgroundColor = [UIColor clearColor];
}
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"TOUCHES BEGAN");
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [PlantIconView class]){
        CGPoint location = [touch locationInView:self.mainView];
        startX = location.x - touchedView.center.x;
        startY = location.y - touchedView.center.y;
    }
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [PlantIconView class]){
        self.scrollEnabled = NO;
        //touchedIcon = (PlantIconView*)touchedView;
        //[self.mainView addSubview: touchedIcon];
        //[self addSubview: touchedIcon];
        CGPoint location = [touch locationInView:self.mainView];
        location.x = location.x - startX;
        location.y = location.y - startY;
        touchedView.center = location;
    }
    self.scrollEnabled = YES;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [PlantIconView class]){
        PlantIconView *plantView = (PlantIconView*)touchedView;
        float xCo = 0;
        float yCo = 0;
        //NSLog(@"TOUCHES ENDED");
        //NSLog(@"LOCATION END: x: %f y: %f", touchedView.center.x, touchedView.center.y);
        if(plantView.plantId > 3){
            xCo = (self.mainView.frame.size.width + 0) * -1;
        }
        if(plantView.plantId > 6){
            xCo = ((self.mainView.frame.size.width)* 2 + 0) * -1;
        }
        
        //NSLog(@"MainView Y: %f, %f, %f", self.mainView.frame.size.height, self.frame.origin.y, self.frame.size.height);
        //NSLog(@"xCO equation = %f + %f", touchedView.center.x, xCo);
        
        float selectMessageViewHeight = 26.00;
        //float yCo = (self.frame.origin.y - self.frame.size.height + touchedView.center.y);
        yCo = fabs(self.mainView.frame.size.height + touchedView.center.y + selectMessageViewHeight);
        xCo = fabs(touchedView.center.x + xCo);
        //NSLog(@"Adjusted END: x: %f y: %f",  xCo, yCo);
        int i = 0;
        float leastSquare = 500000;
        int targetCell = -1;
        for(UIView *subview in self.mainView.subviews){
            CGPoint location = subview.center;
            float bedX = fabs(location.x);
            float bedY = fabs(location.y);
            float deltaX = fabs(xCo - bedX);
            float deltaY = fabs(yCo - bedY);
            float deltaSquare = (deltaX * deltaX) + (deltaY * deltaY);
            if(leastSquare > deltaSquare){
                leastSquare = deltaSquare;
                targetCell = i;
            }
            i++;
        }
        //int plantId = plantView.plantId;
        //NSLog(@"delta squared: %f, %i, %i", leastSquare, targetCell, plantId);
        //NSNumber *selectedId = [NSNumber numberWithInt:plantId];
        //NSString *key = [NSString stringWithFormat:@"cell%i",targetCell];
        //[self.editBedVC.bedStateDict setValue:selectedId forKey: key];
        [self.editBedVC updatePlantBeds:targetCell:plantView.plantId];
    }
}
    
@end
