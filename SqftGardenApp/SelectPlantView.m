//
//  PlantSelectView.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/12/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "SelectPlantView.h"
#import "PlantIconView.h"
#import "ClassIconView.h"
#import "ApplicationGlobals.h"
#import "BedView.h"
#import "DBManager.h"


@implementation SelectPlantView
ApplicationGlobals *appGlobals;
DBManager *dbManager;
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
    dbManager = [DBManager getSharedDBManager];
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


- (NSMutableArray *)buildPlantSelectArray : (NSString *)class{
    NSMutableArray *selectArray = [[NSMutableArray alloc] init];
    
    int frameDimension = appGlobals.bedDimension - 5;
    //if((self.view.frame.size.width / frameDimension) > 6)frameDimension = self.view.frame.size.width / 6;
    //if((self.view.frame.size.width / frameDimension) < 3)frameDimension = self.view.frame.size.width / 3;
    
    //int rowCount = [dbManager getTableRowCount:@"plants"];
    NSArray *list = [dbManager getPlantIdsForClass:class];
    for(int i=0; i<list.count; i++){
        NSString *index = list[i];
        PlantIconView *plantIcon = [[PlantIconView alloc]
                                    initWithFrame:CGRectMake(6 + (frameDimension*i), 2, frameDimension,frameDimension) : index.intValue];
        UIImage *icon = [UIImage imageNamed: plantIcon.iconResource];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
        plantIcon.layer.borderWidth = 0;
        imageView.frame = CGRectMake(plantIcon.bounds.size.width/4,
                                     plantIcon.bounds.size.height/4,
                                     plantIcon.bounds.size.width/2,
                                     plantIcon.bounds.size.height/2);
        plantIcon.index = i+1;
        [plantIcon addSubview:imageView];
        [selectArray addObject:plantIcon];
    }
    return selectArray;
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"TOUCHES BEGAN");
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [ClassIconView class]){
        ClassIconView *classView = (ClassIconView*)touchedView;
        for(UIView *subview in self.subviews){
            [subview removeFromSuperview];
        }
        NSString *class = classView.className;
        NSArray *array = [self buildPlantSelectArray : class];
        for(int i=0;i<array.count;i++){
            [self addSubview:array[i]];
        }
        return;
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
    if ([touchedView class] == [PlantIconView class] || [touchedView class] == [ClassIconView class]){
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
    if ([touchedView class] == [PlantIconView class] || [touchedView class] == [ClassIconView class]){
        PlantIconView *plantView = (PlantIconView*)touchedView;
        float xCo = 0;
        float yCo = 0;
        float pageSize = round(self.mainView.frame.size.width / touchedView.frame.size.width);
        if(plantView.index > pageSize){
            xCo = (self.mainView.frame.size.width + 0) * -1;
        }
        if(plantView.index > pageSize * 2){
            xCo = ((self.mainView.frame.size.width)* 2 + 0) * -1;
        }
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
        [self.editBedVC updatePlantBeds:targetCell:plantView.index];
    }
}
    
@end
