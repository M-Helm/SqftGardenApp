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
const int svBEDFRAME_TOP_OFFSET = 120;
const int svBEDFRAME_SIDE_OFFSET = 10;
float svStartX = 0;
float svStartY = 0;



ApplicationGlobals *appGlobals;
DBManager *dbManager;
- (void) viewDidLoad {
    [super viewDidLoad];
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

    
}
-(void)initViews{
    
    UIColor *color = [appGlobals colorFromHexString:@"#fefefe"];
    self.view.backgroundColor = color;
    
    [self.bedFrameView removeFromSuperview];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"";
    //self.navigationItem.title = appGlobals.appTitle;
    int bedDimension = [self bedDimension];
    //int frameDimension = bedDimension - 5;
    float xCo = self.view.bounds.size.width;
    int yCo = self.bedRowCount * bedDimension * self.maxRowCount;
    self.bedFrameView = [[UIView alloc] initWithFrame:CGRectMake(svBEDFRAME_SIDE_OFFSET, svBEDFRAME_TOP_OFFSET,
                                                                 xCo+svBED_LAYOUT_WIDTH_BUFFER, yCo+svBED_LAYOUT_HEIGHT_BUFFER)];
    self.sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20+yCo+(svBED_LAYOUT_HEIGHT_BUFFER*3),xCo+svBED_LAYOUT_WIDTH_BUFFER,200)];
    self.sizeLabel.text = @"Drag the square to set garden size";
    [self.view addSubview:self.sizeLabel];
    
    //get bed array
    NSMutableArray *bedArray = [self buildBedViewArray];
    
    //add my array of beds as subviews
    for(int i = 0; i < bedArray.count; i++){
        [self.bedFrameView addSubview:[bedArray objectAtIndex:i]];
    }
    self.bedFrameView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.bedFrameView.layer.borderWidth = 1;
    self.bedFrameView.layer.cornerRadius = 15;
    

    [self.view addSubview:self.bedFrameView];
    [self makeTitleBar];
    [self drawBaseGrid];
}

-(void)makeTitleBar{
    
    UIColor *color = [appGlobals colorFromHexString: @"#74aa4a"];
    
    float navBarHeight = self.navigationController.navigationBar.bounds.size.height *  1.5;
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(-15,navBarHeight - 2, self.view.frame.size.width - 5, navBarHeight / 1.5)];
    self.titleView.backgroundColor = [color colorWithAlphaComponent:0.55];
    self.titleView.layer.cornerRadius = 15;
    self.titleView.layer.borderWidth = 3;
    self.titleView.layer.borderColor = [color colorWithAlphaComponent:1].CGColor;

    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(25,0, self.view.frame.size.width - 20, 18)];
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(25,18, self.view.frame.size.width - 20, (navBarHeight / 1.5)-18)];
    //NSString *gardenName = appGlobals.globalGardenModel.name;
    NSString *nameStr = appGlobals.globalGardenModel.name;
    NSString *plantDate = @"planting date undefined";
    if(nameStr.length < 1)nameStr = @"New Garden";
    if([nameStr isEqualToString:@"autoSave"])nameStr = @"Unnamed Garden";
    
    NSString *gardenName = [NSString stringWithFormat:@"Garden Name: %@",  nameStr];
    NSString *gardenDate = [NSString stringWithFormat:@"Planting Date: %@",  plantDate];
    //NSString *alertStr = [NSString stringWithFormat:@"File Saved as %@", fileName];
    label.text = gardenName;
    label2.text = gardenDate;
    [label setFont:[UIFont boldSystemFontOfSize:15]];
    [label2 setFont:[UIFont boldSystemFontOfSize:9]];
    //label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label2.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label2.backgroundColor = [UIColor clearColor];
    
    [self.titleView addSubview:label];
    [self.titleView addSubview:label2];
    [self.view addSubview: self.titleView];
    
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

            BedView *bed = [[BedView alloc] initWithFrame:CGRectMake(1 + (bedDimension*rowNumber),
                                                                     (bedDimension*columnNumber)+1, bedDimension, bedDimension): 0];
            bed.index = cell;
            bed.layer.borderWidth = 2;
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
    bedSizeAdjuster = 0;
    
    
    float xCoUpperLimit = self.bedFrameView.frame.size.width - bedSizeAdjuster;
    float xCoLowerLimit = self.bedFrameView.frame.origin.x + bedSizeAdjuster + (svBED_LAYOUT_WIDTH_BUFFER/2);
    //float yCoUpperLimit = self.bedFrameView.frame.origin.y;
    float yCoLowerLimit = self.bedFrameView.frame.size.height;
    
    //NSLog(@"yCo limits: %f  %f", yCoLowerLimit, yCoUpperLimit);
    
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [BedView class]){
        
        CGPoint location = [touch locationInView:[self view]];
        touchedView.hidden=FALSE;
        touchedView.backgroundColor = [UIColor clearColor];
        [self.view bringSubviewToFront:touchedView];
        [self.bedFrameView bringSubviewToFront:touchedView];
        

        //calc row and columns and update label text
        int columnCalc = round(location.x / [self bedDimension]);
        int rowCalc = round((location.y - self.bedFrameView.frame.origin.y) / [self bedDimension]);
        if(rowCalc < 1)rowCalc = 1;
        if(columnCalc < 1) columnCalc = 1;
        if(columnCalc > self.maxColumnCount)columnCalc = self.maxColumnCount;
        if(rowCalc > self.maxRowCount)rowCalc = self.maxRowCount;
        NSString *msg = [NSString stringWithFormat:@"SIZE: %i ft by %i ft", columnCalc, rowCalc];
        self.sizeLabel.text = msg;
        
        //apply a grid step to our bed frame
        
        location.x = location.x - svStartX;
        location.y = location.y - svStartY;
        
        float step = [self bedDimension] / 1; // Grid step size.
        location.x = step * floor((location.x / step) + .75);
        location.y = step * floor((location.y / step) + .75);
        

        //apply limits so we don't go outside our box
        if(location.x > xCoUpperLimit)location.x = xCoUpperLimit;
        if(location.x < xCoLowerLimit)location.x = xCoLowerLimit;
        if(location.y < bedSizeAdjuster + (svBED_LAYOUT_HEIGHT_BUFFER /2))location.y = bedSizeAdjuster + (svBED_LAYOUT_HEIGHT_BUFFER /2);
        
        if(location.y > yCoLowerLimit - bedSizeAdjuster - (svBED_LAYOUT_HEIGHT_BUFFER /2))location.y = yCoLowerLimit - bedSizeAdjuster - (svBED_LAYOUT_HEIGHT_BUFFER /2);
        
        CGRect frame = CGRectMake(0, 0, location.x, location.y);
        [touchedView setFrame: frame];
        
        if(columnCalc != self.bedColumnCount){
            self.bedColumnCount = columnCalc;
            self.bedRowCount = rowCalc;
            [self drawSelectedGrid];
            return;
        }
        if(rowCalc != self.bedRowCount){
            self.bedColumnCount = columnCalc;
            self.bedRowCount = rowCalc;
            [self drawSelectedGrid];
            return;
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [BedView class]){
        CGPoint location = [touch locationInView:[self view]];
        int columnCalc = round(location.x / [self bedDimension]);
        int rowCalc = round((location.y - self.bedFrameView.frame.origin.y) / [self bedDimension]);
        if(rowCalc < 1)rowCalc = 1;
        if(columnCalc < 1) columnCalc = 1;
        if(columnCalc > self.maxColumnCount)columnCalc = self.maxColumnCount;
        if(rowCalc > self.maxRowCount)rowCalc = self.maxRowCount;
        self.bedRowCount = rowCalc;
        self.bedColumnCount = columnCalc;
        
        //build new view array with new row&col counts
        NSArray *array = [self buildBedViewArray];
        //remove old subviews
        for(UIView *subview in self.bedFrameView.subviews){
            [subview removeFromSuperview];
        }
        
        //add my array of beds as subviews
        for(int i = 0; i < array.count; i++){
            [self.bedFrameView addSubview:[array objectAtIndex:i]];
        }
        [self.view addSubview:self.bedFrameView];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSNumber *rows = [NSNumber numberWithInt:self.bedRowCount];
        NSNumber *cols = [NSNumber numberWithInt:self.bedColumnCount];
        [dict setObject: rows forKey:@"rows"];
        [dict setObject: cols forKey:@"columns"];
        SqftGardenModel *model = [[SqftGardenModel alloc] initWithDict:dict];
        [appGlobals setGlobalGardenModel:model];
    
        //NSLog(@"end of the touches section");
        [self.navigationController performSegueWithIdentifier:@"showMain" sender:self.navigationController];
    }
}
-(void)drawSelectedGrid{
    //remove previously drawn grid lines
    for(int i=0; i<self.view.layer.sublayers.count;i++){
        if([self.view.layer.sublayers[i] class] == [CAShapeLayer class]){
            [self.view.layer.sublayers[i] removeFromSuperlayer];
        }
    }
    [self drawBaseGrid];
    //draw Column Lines
    for(int i = 1; i<self.bedColumnCount - 0; i++){
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(svBEDFRAME_SIDE_OFFSET + appGlobals.bedDimension*i, svBEDFRAME_TOP_OFFSET)];
        [path addLineToPoint:CGPointMake(svBEDFRAME_SIDE_OFFSET + appGlobals.bedDimension*i, appGlobals.bedDimension*self.bedRowCount + svBEDFRAME_TOP_OFFSET)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [path CGPath];
        shapeLayer.strokeColor = [[UIColor blackColor] CGColor];
        shapeLayer.lineWidth = 1.0;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        [self.view.layer addSublayer:shapeLayer];
    }
    //Draw Row Lines
    for(int i = 1; i<self.bedRowCount - 0; i++){
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(svBEDFRAME_SIDE_OFFSET, svBEDFRAME_TOP_OFFSET  + appGlobals.bedDimension*i)];
        [path addLineToPoint:CGPointMake(svBEDFRAME_SIDE_OFFSET + appGlobals.bedDimension*(self.bedColumnCount-0), appGlobals.bedDimension*i + svBEDFRAME_TOP_OFFSET)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [path CGPath];
        shapeLayer.strokeColor = [[UIColor blackColor] CGColor];
        shapeLayer.lineWidth = 1.0;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        [self.view.layer addSublayer:shapeLayer];
    }
}
-(void)drawBaseGrid{

    //draw Column Lines
    for(int i = 1; i< 6; i++){
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(svBEDFRAME_SIDE_OFFSET + appGlobals.bedDimension*i, svBEDFRAME_TOP_OFFSET)];
        [path addLineToPoint:CGPointMake(svBEDFRAME_SIDE_OFFSET + appGlobals.bedDimension*i, appGlobals.bedDimension*6 + svBEDFRAME_TOP_OFFSET)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [path CGPath];
        shapeLayer.strokeColor = [[UIColor blueColor] CGColor];
        shapeLayer.lineWidth = .15;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        [self.view.layer addSublayer:shapeLayer];
    }
    //Draw Row Lines
    for(int i = 1; i<6; i++){
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(svBEDFRAME_SIDE_OFFSET, svBEDFRAME_TOP_OFFSET  + appGlobals.bedDimension*i)];
        [path addLineToPoint:CGPointMake(svBEDFRAME_SIDE_OFFSET + appGlobals.bedDimension*6, appGlobals.bedDimension*i + svBEDFRAME_TOP_OFFSET)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [path CGPath];
        shapeLayer.strokeColor = [[UIColor blueColor] CGColor];
        shapeLayer.lineWidth = .15;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        [self.view.layer addSublayer:shapeLayer];
    }
}

@end