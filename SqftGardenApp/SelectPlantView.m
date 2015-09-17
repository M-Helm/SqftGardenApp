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
float viewStartX = 0;
float viewStartY = 0;
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
    //self.backgroundColor = [UIColor clearColor];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    dbManager = [DBManager getSharedDBManager];
    [self setDefaultParameters];
    [self setScrollView];
}

- (void) setDefaultParameters{
    self.color = [UIColor blueColor];
    [self setBackgroundColor: [self.color colorWithAlphaComponent:0.05]];
    //self.backgroundColor = [self.color colorWithAlphaComponent:0.95];
    //self.layer.backgroundColor = [UIColor blueColor].CGColor;
    //self.layer.borderColor = [self.color colorWithAlphaComponent:0.25].CGColor;
    //self.layer.borderWidth = 100;
    //self.layer.cornerRadius = 15;
    self.layer.masksToBounds = NO;
}

- (void) setScrollView{
    // Adjust scroll view content size
    self.contentSize = CGSizeMake(self.frame.size.width * 3, appGlobals.bedDimension);
    self.pagingEnabled= YES;

    //self.backgroundColor = [UIColor clearColor];
}


- (NSMutableArray *)buildPlantSelectArray : (NSString *)class{
    NSMutableArray *selectArray = [[NSMutableArray alloc] init];

    int frameDimension = appGlobals.bedDimension - 5;
    //if((self.view.frame.size.width / frameDimension) > 6)frameDimension = self.view.frame.size.width / 6;
    //if((self.view.frame.size.width / frameDimension) < 3)frameDimension = self.view.frame.size.width / 3;
    
    //add cancel button
    PlantIconView *cancelBtn = [[PlantIconView alloc]
                                initWithFrame:CGRectMake(6 + (frameDimension*0), 2, frameDimension,frameDimension) : -1];
    [selectArray addObject:cancelBtn];
    
    //int rowCount = [dbManager getTableRowCount:@"plants"];
    NSArray *list = [dbManager getPlantIdsForClass:class];
    for(int i=0; i<list.count; i++){
        NSString *index = list[i];
        PlantIconView *plantIcon = [[PlantIconView alloc]
                                    initWithFrame:CGRectMake(6 + (frameDimension*(i+1)), 2, frameDimension,frameDimension) : index.intValue];
        [plantIcon setViewAsIcon:true];
        //NSLog(@"LIST VALUE COMING OUT OF DB: %i", index.intValue);
       // UIImage *icon = [UIImage imageNamed: plantIcon.iconResource];
       // UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
        plantIcon.layer.borderWidth = 0;

        plantIcon.position = i+1;
        //[plantIcon addSubview:imageView];
        [selectArray addObject:plantIcon];
        self.editBedVC.selectMessageLabel.text = @"Drag a plant to a square";
    }
    // Adjust scroll view content size
    //self.contentSize = CGSizeMake(appGlobals.bedDimension *  selectArray.count + (self.frame.size.width/4), appGlobals.bedDimension);
    return selectArray;
}

- (NSMutableArray *)buildClassSelectArray{
    NSMutableArray *selectArray = [[NSMutableArray alloc] init];
    self.editBedVC.selectMessageLabel.text = @"Select A Class Of Plants";
    int frameDimension = appGlobals.bedDimension - 5;
    int rowCount = [dbManager getTableRowCount:@"plant_classes"];
    for(int i=0; i<rowCount; i++){
        ClassIconView *classIcon = [[ClassIconView alloc]
                                    initWithFrame:CGRectMake(6 + (frameDimension*i), 2, frameDimension,frameDimension) : i+1];
        classIcon.index = i+1;
        [selectArray addObject:classIcon];
    }
    // Adjust scroll view content size
    //self.contentSize = CGSizeMake(appGlobals.bedDimension *  selectArray.count + (self.frame.size.width/4), appGlobals.bedDimension);
    return selectArray;
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(appGlobals.isMenuDrawerOpen == YES){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyButtonPressed" object:self];
        return;
    }
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
        self.selectedClass = classView.className;
        NSArray *array = [self buildPlantSelectArray : self.selectedClass];
        [self setContentOffset:(CGPointMake(0, 0))];
        for(int i=0;i<array.count;i++){
            [self addSubview:array[i]];
        }
        AudioServicesPlaySystemSound(1103);
        return;
    }
    
    if ([touchedView class] == [PlantIconView class]){
        PlantIconView *plantView = (PlantIconView*)touchedView;
        if(plantView.plantId == -1){
            [self cancelSelectPlant];
            return;
        }
        CGPoint location = [touch locationInView:self.mainView];
        
        //test the page bounds, if too close to edge, return
        float clipValue = self.frame.size.width - ((appGlobals.bedDimension-5)*.40);
        if(location.x > clipValue){
            NSLog(@"CLIPPED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            //reset everything in plant select to avoid errant planticons floating about
            for(UIView *subview in self.subviews){
                [subview removeFromSuperview];
            }
            NSArray *array = [self buildPlantSelectArray : self.selectedClass];

            for(int i=0;i<array.count;i++){
                [self addSubview:array[i]];
            }
            return;
        }
        
        startX = location.x - touchedView.center.x;
        startY = location.y - touchedView.center.y;
        viewStartX = touchedView.center.x;
        viewStartY = touchedView.center.y;
        AudioServicesPlaySystemSound(1103);
    }
}

-(void) cancelSelectPlant{
    for(UIView *subview in self.subviews){
        [subview removeFromSuperview];
    }
    NSArray *array = [self buildClassSelectArray];
    for(int i=0;i<array.count;i++){
        [self addSubview:array[i]];
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
        CGPoint location = [touch locationInView:self.mainView];
        location.x = location.x - startX;
        location.y = location.y - startY;
        touchedView.center = location;
        touchedView.alpha = .5;
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
        
        float endingDeltaY = fabs(viewStartY - touchedView.center.y);
        
        NSLog(@"TOUCHED DELTA = %f", endingDeltaY);
        if(fabs(endingDeltaY) < 55){
            touchedView.alpha = 1;
            CGPoint location;
            location.x = viewStartX;
            location.y = viewStartY;
            touchedView.center = location;
            return;
        }
        float xCo = 0;
        float yCo = 0;
        
        float pageSize = (self.mainView.frame.size.width / touchedView.frame.size.width);
        if(plantView.position >= pageSize){
            xCo = (self.mainView.frame.size.width + (plantView.position*2)) * -1;
        }
        if(plantView.position >= pageSize - .5){
            xCo = (self.mainView.frame.size.width + (plantView.position*2)) * -1;
        }
        if(plantView.position >= pageSize * 2){
            xCo = ((self.mainView.frame.size.width + (plantView.position*2))* 2) * -1;
        }
        
        float selectMessageViewHeight = 26.00;
        float navBarHeight = self.editBedVC.navigationController.navigationBar.frame.size.height * 1;
        yCo = fabs(self.mainView.frame.size.height + touchedView.center.y + selectMessageViewHeight - (navBarHeight*1));
        xCo = fabs(xCo + touchedView.center.x);
        NSLog(@"XCordinate: %f  screenWidth: %f", xCo, self.mainView.frame.size.width);
        int i = 0;
        float leastSquare = 500000;
        float deltaSquare = 500000;
        int targetCell = -1;
        for(UIView *subview in self.mainView.subviews){
            CGPoint location = subview.center;
            float bedX = fabs(location.x);
            float bedY = fabs(location.y);
            float deltaX = fabs(xCo - bedX);
            float deltaY = fabs(yCo - bedY);
            deltaSquare = (deltaX * deltaX) + (deltaY * deltaY);
            if(leastSquare > deltaSquare){
                leastSquare = deltaSquare;
                targetCell = i;
            }
            i++;
        }
        NSLog(@"squares reports at D: %f , LOS: %f", deltaSquare, leastSquare);
        NSLog(@"return value is %i",(appGlobals.bedDimension * appGlobals.bedDimension)*2);
        //if we're far from a bedview just return
        if(leastSquare > (appGlobals.bedDimension * appGlobals.bedDimension)*2){
            touchedView.alpha = 1;
            CGPoint location;
            location.x = viewStartX;
            location.y = viewStartY;
            touchedView.center = location;
            return;
        }
        
        [self.editBedVC updatePlantBeds:targetCell:plantView.plantId];
        AudioServicesPlaySystemSound(1105);

    }
}
    
@end
