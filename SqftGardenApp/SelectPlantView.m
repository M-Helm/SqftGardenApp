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
#import "EditBedViewController.h"
#import "ApplicationGlobals.h"
#import "BedView.h"
#import "DBManager.h"
#define amDebugging ((bool) YES)

@interface SelectPlantView()
@end


@implementation SelectPlantView
ApplicationGlobals *appGlobals;
DBManager *dbManager;
float startX = 0;
float startY = 0;
float viewStartX = 0;
float viewStartY = 0;
PlantIconView *touchedIcon;
EditBedViewController *editBedVC;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andEditBedVC:(UIViewController*)editBed{
    self = [super initWithFrame:frame];
    editBedVC = (EditBedViewController*)editBed;
    [self setDatePickerIsOpen:NO];
    [self setIsoViewIsOpen:NO];
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
    self.showTouches = NO;
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
    self.pagingEnabled= NO;

    //self.backgroundColor = [UIColor clearColor];
}


- (NSMutableArray *)buildPlantSelectArray : (NSString *)class{
    NSMutableArray *selectArray = [[NSMutableArray alloc] init];

    int frameDimension = appGlobals.bedDimension - 5;
    
    //add cancel button
    PlantIconView *cancelBtn = [[PlantIconView alloc]
                                initWithFrame:CGRectMake(6 + (frameDimension*0), 2, frameDimension,frameDimension) withPlantUuid: @"cancel" isIsometric:NO];
    [selectArray addObject:cancelBtn];
    
    NSArray *list = [dbManager getPlantUuidsForClass:class];
    //NSLog(@"list count = %i, %@", (int)list.count, [list objectAtIndex:0]);
    for(int i=0; i<list.count; i++){
        NSString *index = list[i];
        PlantIconView *plantIcon = [[PlantIconView alloc]
                                    initWithFrame:CGRectMake(6 + (frameDimension*(i+1)), 2, frameDimension,frameDimension) withPlantUuid: index isIsometric:NO];
        [plantIcon setViewAsIcon:true];
        //NSLog(@"PLant name %@", plantIcon.plantName);
        //NSLog(@"LIST VALUE COMING OUT OF DB: %i", index.intValue);
       // UIImage *icon = [UIImage imageNamed: plantIcon.iconResource];
       // UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
        plantIcon.layer.borderWidth = 0;

        plantIcon.model.position = i+1;
        //[plantIcon addSubview:imageView];
        [selectArray addObject:plantIcon];
        editBedVC.selectMessageLabel.text = @"Drag a plant to a square";
    }
    // Adjust scroll view content size
    self.contentSize = CGSizeMake(appGlobals.bedDimension *  selectArray.count + (self.frame.size.width/4), appGlobals.bedDimension);
    return selectArray;
}

- (NSMutableArray *)buildClassSelectArray{
    NSMutableArray *selectArray = [[NSMutableArray alloc] init];
    editBedVC.selectMessageLabel.text = @"Select A Class Of Plants";
    int frameDimension = appGlobals.bedDimension - 5;
    int rowCount = [dbManager getTableRowCount:@"plant_classes"];
    NSLog(@"class count = %i", rowCount);
    for(int i=0; i<rowCount; i++){
        ClassIconView *classIcon = [[ClassIconView alloc]
                                    initWithFrame:CGRectMake(6 + (frameDimension*i), 2, frameDimension,frameDimension) : i+1];
        classIcon.index = i+1;
        [selectArray addObject:classIcon];
    }
    // Adjust scroll view content size
    self.contentSize = CGSizeMake(appGlobals.bedDimension *  selectArray.count + (self.frame.size.width/4), appGlobals.bedDimension);
    return selectArray;
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
-(void)setPlantSelect: (UIView*)touchedView {
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

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if(self.isoViewIsOpen)return;
    if(appGlobals.isMenuDrawerOpen == YES){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyButtonPressed" object:self];
        return;
    }
    if(self.datePickerIsOpen)return;
    UITouch *touch = [[event allTouches] anyObject];
    
    UIView *touchedView;
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [ClassIconView class]){
        [self setPlantSelect:touchedView];
        return;
    }
    
    if ([touchedView class] == [PlantIconView class]){
        PlantIconView *plantView = (PlantIconView*)touchedView;
        if([plantView.plantUuid isEqualToString:@"cancel"]){
            [self cancelSelectPlant];
            return;
        }
        CGPoint location = [touch locationInView:editBedVC.bedFrameView];
        
        //test the page bounds, if too close to edge, return
        float clipValue = self.frame.size.width - ((appGlobals.bedDimension-5)*.40);
        if(location.x > clipValue){
            
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



- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if(self.datePickerIsOpen)return;
    if(self.isoViewIsOpen)return;
    UITouch *touch = [[event allTouches] anyObject];
    
    if(self.showTouches){
        self.touchIcon.center = [touch locationInView:self];
    }
    
    UIView *touchedView;
    if([touch view] != nil){
        touchedView = [touch view];
    }
    //if we're on an icon move it with the touch
    if ([touchedView class] == [PlantIconView class] || [touchedView class] == [ClassIconView class]){
        self.scrollEnabled = NO;
        CGPoint location = [touch locationInView:editBedVC.bedFrameView];
        location.x = location.x - startX;
        location.y = location.y - startY;
        touchedView.center = location;
        touchedView.alpha = .5;
    }
    self.scrollEnabled = YES;
    //check to see if we need to give it a multi-sqft frame
    if([touchedView class] == [PlantIconView class]){
        PlantIconView *plant = (PlantIconView*)touchedView;
        if(plant.model.squareFeet > 1){
            //check frame size
            if(plant.frame.size.width > appGlobals.bedDimension - 5)return;
            //update frame size
            CGRect frame = CGRectMake(plant.frame.origin.x,
                                      plant.frame.origin.y,
                                      (appGlobals.bedDimension -5)*(plant.model.squareFeet /2),
                                      (appGlobals.bedDimension -5)*(plant.model.squareFeet /2));
            plant.frame = frame;
            plant.layer.borderColor = [UIColor blackColor].CGColor;
            plant.layer.borderWidth = 2;
            //redraw the icon in the new frame
            [plant setImageGrid:1 :1];
        }
    }
}

-(CGPoint) convertPointToIso: (UIView*)view{
    CGPoint point;
    //CGRect transformFrame = [editBedVC.isoView  convertRect:[view frame] fromView:editBedVC.isoView.bedFrameView];
    CGRect transformFrame = [editBedVC.isoView  convertRect:[view frame] fromView:nil];
    point.x = transformFrame.origin.x + (transformFrame.size.width/2);
    point.y = transformFrame.origin.y + (appGlobals.bedDimension/4);
    return point;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if(self.datePickerIsOpen)return;
    if(self.isoViewIsOpen)return;
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    if ([touchedView class] == [ClassIconView class])return;
    /*
    if(self.showTouches){
        self.touchIcon.center = [touch locationInView:self];
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.touchIcon.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [self.touchIcon removeFromSuperview];
                         }];
    }
    */
    CGPoint locationInBed;
    touchedView = [touch view];
    locationInBed = [touch locationInView:editBedVC.bedFrameView];
    if(self.isoViewIsOpen)locationInBed = [self convertPointToIso:touchedView];
    if ([touchedView class] == [PlantIconView class]){
        PlantIconView *plantView = (PlantIconView*)touchedView;
        
        float endingDeltaY = fabs(viewStartY - touchedView.center.y);
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
        

        yCo = locationInBed.y;
        xCo = locationInBed.x;
        //test if we're multi sqft and adjust xCo and yCo if so
        if(plantView.model.squareFeet > 1){
            xCo = locationInBed.x - ((appGlobals.bedDimension -5) /2);
            yCo = locationInBed.y - ((appGlobals.bedDimension -5) /2);
        }
        
        
        //NSLog(@"XCordinate: %f  screenWidth: %f", xCo, self.mainView.frame.size.width);
        //NSLog(@"YCordinate: %f  TouchCoord: %f screenHeight: %f", yCo, touchedView.center.y, self.mainView.frame.size.height);
        int i = 0;
        float leastSquare = 500000;
        float deltaSquare = 500000;
        int targetCell = -1;
        for(UIView *subview in editBedVC.bedFrameView.subviews){
            CGPoint location = subview.center;
            if(self.isoViewIsOpen)location = [self convertPointToIso:subview];
            //NSLog(@"subview center x : %f",subview.center.x);
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
        //if we're far from a bedview just return
        if(leastSquare > (appGlobals.bedDimension * appGlobals.bedDimension)*2){
            touchedView.alpha = 1;
            CGPoint location;
            location.x = viewStartX;
            location.y = viewStartY;
            touchedView.center = location;
            return;
        }
        
        if(plantView.model.squareFeet > 1){
            //and kick out if we'll draw part out of bounds
            //right hand column
            if((targetCell+1) % editBedVC.currentGardenModel.columns == 0){
                [touchedView removeFromSuperview];
                [editBedVC initViews];
                return;
            }
            //special case for width == 2
            if(editBedVC.currentGardenModel.columns > 1 || editBedVC.currentGardenModel.columns < 3){
                NSLog(@"columns == %i", editBedVC.currentGardenModel.columns);
                //last row
                if((targetCell) < (editBedVC.currentGardenModel.rows * editBedVC.currentGardenModel.columns - 3)){
                    [editBedVC updatePlantBeds:targetCell:plantView.plantUuid];
                    AudioServicesPlaySystemSound(1105);
                    return;
                }
            }
            //last row
            if((targetCell) > (editBedVC.currentGardenModel.rows * (editBedVC.currentGardenModel.columns-1)-2)){
                [touchedView removeFromSuperview];
                [editBedVC initViews];
                return;
            }
        }
        //GA Tracking setup
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Plants"
                                                              action:@"Select"
                                                               label:plantView.model.plantName
                                                               value:@1] build]];
        
        
        [editBedVC updatePlantBeds:targetCell:plantView.plantUuid];
        AudioServicesPlaySystemSound(1105);
    }
}

-(void) hideGrowToolBar{
    CGRect toolbarFrame = CGRectMake(editBedVC.toolBar.frame.origin.x,
                                     editBedVC.toolBar.frame.origin.y +44,
                                     editBedVC.toolBar.frame.size.width,
                                     editBedVC.toolBar.frame.size.height);
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{

         editBedVC.toolBar.frame = toolbarFrame;
     }
                     completion:^(BOOL finished)
     {
         editBedVC.toolBar.hidden = YES;
         self.toolBarHidden = YES;
     }];
}

-(void) showGrowToolBar{
    editBedVC.toolBar.hidden = NO;
    self.toolBarHidden = NO;
    CGRect toolbarFrame = CGRectMake(editBedVC.toolBar.frame.origin.x,
                                     editBedVC.toolBar.frame.origin.y -44,
                                     editBedVC.toolBar.frame.size.width,
                                     editBedVC.toolBar.frame.size.height);
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         editBedVC.toolBar.frame = toolbarFrame;
                     }
                     completion:^(BOOL finished)
     {
         
     }];
}


@end
