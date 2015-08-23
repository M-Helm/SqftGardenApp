//
//  SizeBedViewController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 8/23/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//


#import "SizeBedViewController.h"
#import "ApplicationGlobals.h"
#import "DBManager.h"
#import "BedView.h"

@interface SizeBedViewController()

@end

@implementation SizeBedViewController

const int svBED_LAYOUT_HEIGHT_BUFFER = 3;
const int svBED_LAYOUT_WIDTH_BUFFER = -17;
float svStartX = 0;
float svStartY = 0;



ApplicationGlobals *appGlobals;
DBManager *dbManager;
- (void) viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    appGlobals = [ApplicationGlobals getSharedGlobals];
    dbManager = [DBManager getSharedDBManager];
    appGlobals.selectedCell = -1;
    if(self.bedColumnCount < 1)self.bedColumnCount = 1;
    if(self.bedRowCount < 1)self.bedRowCount = 1;
    self.maxRowCount = 6;
    self.maxColumnCount = 6;
    
    self.currentGardenModel = [[SqftGardenModel alloc] init];
    
    //check if there's a model in globals, save it and reset it
    if ([appGlobals getCurrentGardenModel] != nil){
        [appGlobals.globalGardenModel saveModel:true];
        [appGlobals setCurrentGardenModel:self.currentGardenModel];
    }
    [self initViews];
}
- (void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.bedFrameView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.bedFrameView.layer.borderWidth = 3;
}
-(void)initViews{
    
    [self.bedFrameView removeFromSuperview];
    int bedDimension = [self bedDimension];
    //int frameDimension = bedDimension - 5;
    float xCo = self.view.bounds.size.width;
    int yCo = self.bedRowCount * bedDimension * self.maxRowCount;
    self.bedFrameView = [[UIView alloc] initWithFrame:CGRectMake(10, 100,
                                                                 xCo+svBED_LAYOUT_WIDTH_BUFFER, yCo+svBED_LAYOUT_HEIGHT_BUFFER)];
    //get bed array
    NSMutableArray *bedArray = [self buildBedViewArray];
    
    //add my array of beds as subviews
    for(int i = 0; i < bedArray.count; i++){
        [self.bedFrameView addSubview:[bedArray objectAtIndex:i]];
    }
    
  
    [self.view addSubview:self.bedFrameView];
}


-(int)bedDimension{
    int columnDimension = (int)(self.view.bounds.size.width - 20) / (int)self.maxColumnCount;
    int bedDimension = (int)(self.view.bounds.size.height - 60) / (int)self.maxRowCount;
    if(bedDimension > columnDimension){
        bedDimension = columnDimension;
    }
    [appGlobals setBedDimension:bedDimension];
    return bedDimension;
}
- (NSMutableArray *)buildBedViewArray{
    NSMutableArray *bedArray = [[NSMutableArray alloc] init];
    int bedDimension = [self bedDimension];
    int rowNumber = 0;
    int columnNumber = 0;
    int cell = 0;
    //int cellCount = self.bedRowCount * self.bedColumnCount;
    
    for(int i=0; i<self.bedRowCount; i++){
        while(columnNumber < self.bedColumnCount){

            BedView *bed = [[BedView alloc] initWithFrame:CGRectMake(1 + (bedDimension*columnNumber),
                                                                     (bedDimension*rowNumber)+1, bedDimension, bedDimension): 0];
            bed.index = cell;
            [bedArray addObject:bed];
            columnNumber++;
            cell++;
        }
        columnNumber = 0;
        rowNumber++;
    }
    return bedArray;
}
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [BedView class]){
        CGPoint location = [touch locationInView:[self view]];
        svStartX = location.x - touchedView.center.x;
        svStartY = location.y - touchedView.center.y;
    }
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    float bedSizeAdjuster = [self bedDimension]/2;
    float xCoUpperLimit = self.bedFrameView.frame.size.width - bedSizeAdjuster;
    float xCoLowerLimit = self.bedFrameView.frame.origin.x + bedSizeAdjuster + (svBED_LAYOUT_WIDTH_BUFFER/2);
    //float yCoUpperLimit = self.bedFrameView.frame.origin.y;
    float yCoLowerLimit = self.bedFrameView.frame.size.height;
    
    //NSLog(@"yCo limits: %f  %f", yCoLowerLimit, yCoUpperLimit);
    
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [BedView class]){
        touchedView.hidden=FALSE;
        [self.view bringSubviewToFront:touchedView];
        [self.bedFrameView bringSubviewToFront:touchedView];
        CGPoint location = [touch locationInView:[self view]];
        location.x = location.x - svStartX;
        location.y = location.y - svStartY;
        //apply a grid step to our bed frame
        float step = [self bedDimension] / 2; // Grid step size.
        location.x = step * floor((location.x / step) + .5);
        location.y = step * floor((location.y / step) + .5);

        //apply limits so we don't go outside our box
        if(location.x > xCoUpperLimit)location.x = xCoUpperLimit;
        if(location.x < xCoLowerLimit)location.x = xCoLowerLimit;
        if(location.y < bedSizeAdjuster + (svBED_LAYOUT_HEIGHT_BUFFER /2))location.y = bedSizeAdjuster + (svBED_LAYOUT_HEIGHT_BUFFER /2);
        
        if(location.y > yCoLowerLimit - bedSizeAdjuster - (svBED_LAYOUT_HEIGHT_BUFFER /2))location.y = yCoLowerLimit - bedSizeAdjuster - (svBED_LAYOUT_HEIGHT_BUFFER /2);

        
        touchedView.center = location;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
}


@end