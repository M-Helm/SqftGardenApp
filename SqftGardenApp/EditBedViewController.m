//
//  MainViewController.h
//  SqftGardenApp
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.

#import "EditBedViewController.h"
//#import "BedView.h"
#import "PlantIconView.h"
#import "ClassIconView.h"
#import "SelectPlantView.h"
#import "ApplicationGlobals.h"
#import "DBManager.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface EditBedViewController ()

@end

@implementation EditBedViewController
const int BED_LAYOUT_HEIGHT_BUFFER = 3;
const int BED_LAYOUT_WIDTH_BUFFER = -17;
const float BED_LAYOUT_WIDTH_RATIO = 1.0;
const float BED_LAYOUT_HEIGHT_RATIO = .60;
const float SELECT_LAYOUT_WIDTH_RATIO = 1.0;
const float SELECT_LAYOUT_HEIGHT_RATIO = .20;

NSString * const ROW_KEY = @"rows";
NSString * const COLUMN_KEY = @"columns";
float evStartX = 0;
float evStartY = 0;

SelectPlantView *selectPlantView;

ApplicationGlobals *appGlobals;
DBManager *dbManager;


- (id) initWithDimensions:(int)rows :(int)columns {
    self.bedRowCount = rows;
    self.bedColumnCount = columns;
    [self bedDimension];
    return self;
}
- (id) initWithModel:(SqftGardenModel *)model {
    self.bedRowCount = model.rows;
    self.bedColumnCount = model.columns;
    NSLog(@"MODEL Rows = %i Cols = %i", model.rows, model.columns);
    
    self.currentGardenModel = model;
    [self bedDimension];
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    dbManager = [DBManager getSharedDBManager];
    appGlobals.selectedCell = -1;
    self.navigationController.navigationBar.hidden = NO;
    self.view.backgroundColor = [UIColor whiteColor];

    
    if ([appGlobals getCurrentGardenModel] != nil){
        self.currentGardenModel = [appGlobals getCurrentGardenModel];
        NSLog(@"Garden Model 1: %@ ROWS: %i", self.currentGardenModel, self.currentGardenModel.rows);
        self.bedColumnCount = self.currentGardenModel.columns;
        self.bedRowCount = self.currentGardenModel.rows;

    }
    
    if (self.currentGardenModel == nil){
        if(appGlobals.hasShownLaunchScreen == NO)
            [self.navigationController performSegueWithIdentifier:@"showLaunch" sender:self];
        else
            [self.navigationController performSegueWithIdentifier:@"showResize" sender:self];
        return;
    }
    if((int)self.bedRowCount < 1)self.bedRowCount = 3;
    if((int)self.bedColumnCount < 1)self.bedColumnCount = 3;
    self.bedCellCount = self.bedRowCount * self.bedColumnCount;
    self.bedViewArray = [self buildBedViewArray];
    self.selectPlantArray = [self buildClassSelectArray];
    //self.selectPlantArray = [self buildPlantSelectArray];
    [self.currentGardenModel setRows:self.bedRowCount];
    [self.currentGardenModel setColumns:self.bedColumnCount];
    [self initViews];
}

- (void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.bedFrameView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.bedFrameView.layer.borderWidth = 0;
    self.bedFrameView.layer.cornerRadius = 15;
    for(int i =0; i<self.bedViewArray.count; i++){
        PlantIconView *bed = [self.bedViewArray objectAtIndex:i];
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleBedSingleTap:)];
        [bed addGestureRecognizer:singleFingerTap];
    }
    selectPlantView.mainView = self.bedFrameView;
    selectPlantView.editBedVC = self;
    [self.view addSubview:self.bedFrameView];
    self.bedFrameView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:selectPlantView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initViews{
    //get rid of all old views.
    for(UIView* subview in self.view.subviews){
        [subview removeFromSuperview];
    }
    UIColor *color = [appGlobals colorFromHexString:@"#fefefe"];
    self.view.backgroundColor = color;
    
    self.navigationItem.hidesBackButton = YES;
    [self.bedFrameView removeFromSuperview];
    int width = self.view.bounds.size.width;
    int height = self.view.frame.size.height * BED_LAYOUT_HEIGHT_RATIO;
    if(selectPlantView != nil){
        [selectPlantView removeFromSuperview];
    }
    [self makeBedFrame : width : height];
    [self makeSelectView: width : height];
    [self makeSelectMessageView: width : height];
    [self makeTitleBar];
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
    if([nameStr isEqualToString:@"autoSave"])nameStr = @"New Garden";
    
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

-(void)makeSelectMessageView : (int)width :(int)height{
    self.selectMessageView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                      height+BED_LAYOUT_HEIGHT_BUFFER + 102,
                                                                      width,
                                                                      20)];
    self.selectMessageView.layer.borderWidth = 0;
    self.selectMessageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    UIColor *color = [UIColor blackColor];
    self.selectMessageView.backgroundColor = [color colorWithAlphaComponent:0.95];
    self.selectMessageLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,3,width,18)];
    self.selectMessageLabel.textColor = [UIColor whiteColor];
    [self.selectMessageLabel setFont:[UIFont systemFontOfSize:16]];
    self.selectMessageLabel.text = @"This is the select Message";
    [self.selectMessageView addSubview:self.selectMessageLabel];
    [self.view addSubview:self.selectMessageView];
    self.selectMessageLabel.text = @"Select A Class Of Plants";
    
}

-(void)makeSelectView : (int)width : (int)height{
    int bedDimension = [self bedDimension];
    int selectDimension = bedDimension + 5;
    if((self.view.frame.size.width / selectDimension) > 6)selectDimension = self.view.frame.size.width / 6;
    if((self.view.frame.size.width / selectDimension) < 3)selectDimension = self.view.frame.size.width / 3;
    selectPlantView = [[SelectPlantView alloc] initWithFrame: CGRectMake(0, height+BED_LAYOUT_HEIGHT_BUFFER + 125, width, selectDimension)];
    for(int i = 0; i<self.selectPlantArray.count;i++){
        [selectPlantView addSubview:[self.selectPlantArray objectAtIndex:i]];
    }
}

-(void)makeBedFrame : (int) width : (int) height{
    
    //when you monkey with this layout you need adjust the endTouches method in SelectPlantView Class else the drag and drop stuff breaks
    float navBarHeight = self.navigationController.navigationBar.bounds.size.height * 1.5;
    self.bedFrameView = [[UIView alloc] initWithFrame:CGRectMake(10, navBarHeight * 2,
                                                                 width+BED_LAYOUT_WIDTH_BUFFER, height+BED_LAYOUT_HEIGHT_BUFFER)];
    //add my array of beds
    for(int i = 0; i<self.bedViewArray.count;i++){
        [self.bedFrameView addSubview:[self.bedViewArray objectAtIndex:i]];
    }
    //add icons to bedviews
    int cellCount = 0;
    for (UIView *subview in self.bedFrameView.subviews){
        if( [subview class] == [PlantIconView class]){
            cellCount++;
        }
    }
}

-(int)bedDimension{
    int columnDimension = (int)(self.view.bounds.size.width - 20) / (int)self.bedColumnCount;
    int bedDimension = (int)(self.view.bounds.size.height - 60) / (int)self.bedRowCount;
    if(bedDimension > columnDimension){
        bedDimension = columnDimension;
    }
    if(((self.view.frame.size.width - 20) / bedDimension) < 3)
            bedDimension = (int)(self.view.bounds.size.width - 20)/3;
    
    
    while(bedDimension * self.bedRowCount > (self.view.frame.size.height * BED_LAYOUT_HEIGHT_RATIO)){
        bedDimension = bedDimension * .93;
    }
    
    [appGlobals setBedDimension:bedDimension];
    return bedDimension;
}

- (void)handleBedSingleTap:(UITapGestureRecognizer *)recognizer {
    for(int i = 0; i<self.bedViewArray.count; i++){
        UIView *bed = [self.bedViewArray objectAtIndex:i];
        bed.backgroundColor = [UIColor whiteColor];
        bed.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    recognizer.view.layer.borderColor = [UIColor darkGrayColor].CGColor;
    PlantIconView *bd = (PlantIconView*)recognizer.view;
    appGlobals.selectedPlant = bd;
    appGlobals.selectedCell = bd.position;
    [self calculatePlantDropPosition:bd];
    [self.navigationController performSegueWithIdentifier:@"showBedDetail" sender:self];
}

- (NSMutableArray *)buildBedViewArray{
    NSMutableArray *bedArray = [[NSMutableArray alloc] init];
    int bedDimension = [self bedDimension] - 5;
    int rowNumber = 0;
    int columnNumber = 0;
    int cell = 0;
    int cellCount = self.bedRowCount * self.bedColumnCount;

    if(self.currentGardenModel == nil){
        self.currentGardenModel = [[SqftGardenModel alloc] init];
        NSLog(@"dict initialized in build method");
        //NSLog(@"GARDEN MODEL INITIALIZED");
    }
    if([self.currentGardenModel getPlantIdForCell:0] < 0){
        //NSLog(@"dict initialized");
        for(int i=0; i<cellCount; i++){
            [self.currentGardenModel setPlantIdForCell:i :0];
            //NSLog(@"dict initialized on less than zero");
        }
    }
    for(int i=0; i<self.bedRowCount; i++){
        while(columnNumber < self.bedColumnCount){
            int plantId = [self.currentGardenModel getPlantIdForCell:cell];
            //plantId = 3;
            //NSLog(@"Get Function: %i , %i", plantId, cell);
            float padding = [self calculateBedViewHorizontalPadding];
            PlantIconView *bed = [[PlantIconView alloc] initWithFrame:CGRectMake(padding + (bedDimension*columnNumber),(bedDimension*rowNumber)+1, bedDimension, bedDimension): plantId];
            bed.layer.borderWidth = 1;
            bed.position = cell;
            [bedArray addObject:bed];
            columnNumber++;
            cell++;
        }
        columnNumber = 0;
        rowNumber++;
    }
    return bedArray;
}

- (float) calculateBedViewHorizontalPadding{
    float padding = 1;
    padding = (self.view.frame.size.width - (([self bedDimension]-1)*self.bedColumnCount))/2;
    return padding;
}

- (void) updatePlantBeds : (int)updatedCell : (int)plantId{
    [self.currentGardenModel setPlantIdForCell:updatedCell :plantId];
    self.bedViewArray = [self buildBedViewArray];
    self.selectPlantArray = [self buildClassSelectArray];
    [self.currentGardenModel autoSaveModel];
    [appGlobals setCurrentGardenModel:self.currentGardenModel];
    //[self.currentGardenModel showModelInfo];
    [self initViews];
}

- (NSMutableArray *)buildClassSelectArray{
    NSMutableArray *selectArray = [[NSMutableArray alloc] init];
    self.selectMessageLabel.text = @"Select A Class Of Plants";
    //[self.selectMessageLabel setNeedsDisplay];
    int frameDimension = [self bedDimension] - 5;
    int rowCount = [dbManager getTableRowCount:@"plant_classes"];
    for(int i=0; i<rowCount; i++){
        ClassIconView *classIcon = [[ClassIconView alloc]
                                    initWithFrame:CGRectMake(6 + (frameDimension*i), 2, frameDimension,frameDimension) : i+1];
        classIcon.index = i+1;
        [selectArray addObject:classIcon];
    }
    return selectArray;
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches Began in EVC");
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [PlantIconView class]){
        PlantIconView *plantView = (PlantIconView*)[touch view];
        if(plantView.plantId < 1)return;
        NSLog(@"Touches Began in EVC (INNER)");
        CGPoint location = [touch locationInView:[self view]];
        evStartX = location.x - touchedView.center.x;
        evStartY = location.y - touchedView.center.y;
        AudioServicesPlaySystemSound(1104);
        
        
    }
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [PlantIconView class]){
        PlantIconView *plantView = (PlantIconView*)[touch view];
        if(plantView.plantId < 1)return;
        touchedView.hidden=FALSE;
        touchedView.layer.borderWidth = 0;
        [self.view bringSubviewToFront:touchedView];
        [self.bedFrameView bringSubviewToFront:touchedView];
        CGPoint location = [touch locationInView:[self view]];
        location.x = location.x - evStartX;
        location.y = location.y - evStartY;
        touchedView.center = location;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    if([touch view] != nil){
        touchedView = [touch view];
    }
    else return;
    [self calculatePlantDropPosition:touchedView];
}
-(void)calculatePlantDropPosition : (UIView*)touchedView{
    if ([touchedView class] == [PlantIconView class]){
        PlantIconView *bedView = (PlantIconView*)touchedView;
        //remove the bed from it's old spot
        [self updatePlantBeds: bedView.position : 0];
        
        float xCo = bedView.center.x;
        float yCo = bedView.center.y;
        
        float yLowerLimit = self.bedFrameView.center.y + self.bedFrameView.frame.size.height / 3;
        float yUpperLimit = 0;
        
        if(yCo > yLowerLimit)return;
        if(yCo < yUpperLimit)return;
        
        int i = 0;
        float leastSquare = 500000;
        float deltaSquare = 0;
        int targetCell = -1;
        for(UIView *subview in self.bedFrameView.subviews){
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
        NSLog(@"Target Cell: %i  PLANT ID: %i", targetCell, bedView.plantId);
        
        //if we're far from a bedview just return
        NSLog(@"squares reports at D: %f , LOS: %f", deltaSquare, leastSquare);
        if(leastSquare > (appGlobals.bedDimension * appGlobals.bedDimension)*2){
            touchedView.alpha = 0;
            [touchedView removeFromSuperview];
            return;
        }
        
        [self updatePlantBeds:targetCell:bedView.plantId];
        //AudioServicesPlaySystemSound(1104);
    }
}


@end


