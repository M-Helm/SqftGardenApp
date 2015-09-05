//
//  MainViewController.h
//  SqftGardenApp
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.

#import "EditBedViewController.h"
#import "BedView.h"
#import "PlantIconView.h"
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


- (id) initWithDimensions:(int)rows columns:(int)columns {
    self.bedRowCount = rows;
    self.bedColumnCount = columns;
    return self;
}
- (id) initWithModel:(SqftGardenModel *)model {
    self.bedRowCount = model.rows;
    self.bedColumnCount = model.columns;
    NSLog(@"MODEL Rows = %i Cols = %i", model.rows, model.columns);
    
    self.currentGardenModel = model;
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    appGlobals = [ApplicationGlobals getSharedGlobals];
    dbManager = [DBManager getSharedDBManager];
    appGlobals.selectedCell = -1;
    
    if ([appGlobals getCurrentGardenModel] != nil){
        self.currentGardenModel = [appGlobals getCurrentGardenModel];
        NSLog(@"Garden Model 1: %@ ROWS: %i", self.currentGardenModel, self.currentGardenModel.rows);
        self.bedColumnCount = self.currentGardenModel.columns;
        self.bedRowCount = self.currentGardenModel.rows;
        
    }
    
    if (self.currentGardenModel == nil){
        //temp stuff to work on resizer
        //NSLog(@"GARDEN MODEL NOT INITIALIZED");
        [self.navigationController performSegueWithIdentifier:@"showResize" sender:self];
        return;
        //self.currentGardenModel = [[SqftGardenModel alloc] init];
        //NSLog(@"Garden Model 2: %@", self.currentGardenModel);
        //[self.currentGardenModel showModelInfo];
    }

    if((int)self.bedRowCount < 1)self.bedRowCount = 3;
    if((int)self.bedColumnCount < 1)self.bedColumnCount = 3;
    
    self.bedCellCount = self.bedRowCount * self.bedColumnCount;
    self.bedViewArray = [self buildBedViewArray];
    self.selectPlantArray = [self buildPlantSelectArray];
    [self.currentGardenModel setRows:self.bedRowCount];
    [self.currentGardenModel setColumns:self.bedColumnCount];
    [self initViews];
}

- (void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.bedFrameView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.bedFrameView.layer.borderWidth = 3;
    self.bedFrameView.layer.cornerRadius = 15;
    for(int i =0; i<self.bedViewArray.count; i++){
        BedView *bed = [self.bedViewArray objectAtIndex:i];
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleBedSingleTap:)];
        [bed addGestureRecognizer:singleFingerTap];
    }
    /*
    for(int i =0; i<self.selectPlantArray.count; i++){
        UIView *box = [self.selectPlantArray objectAtIndex:i];
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handlePlantSingleTap:)];
        [box addGestureRecognizer:singleFingerTap];
    }
    */
    selectPlantView.mainView = self.bedFrameView;
    selectPlantView.editBedVC = self;
    [self.view addSubview:self.bedFrameView];
    [self.view addSubview:selectPlantView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initViews{

    [self.bedFrameView removeFromSuperview];
    
    int bedDimension = [self bedDimension];
    int bedIconDimension = bedDimension - 5;
    float width = self.view.bounds.size.width;
    //int yCo = self.bedRowCount * bedDimension;
    int height = self.view.frame.size.height * BED_LAYOUT_HEIGHT_RATIO;
    self.bedFrameView = [[UIView alloc] initWithFrame:CGRectMake(10, 100,
                    width+BED_LAYOUT_WIDTH_BUFFER, height+BED_LAYOUT_HEIGHT_BUFFER)];
    
    if(selectPlantView != nil){
        [selectPlantView removeFromSuperview];
    }
    
    int selectDimension = bedDimension - 5;
    if((self.view.frame.size.width / selectDimension) > 6)selectDimension = self.view.frame.size.width / 6;
    if((self.view.frame.size.width / selectDimension) < 3)selectDimension = self.view.frame.size.width / 3;
    
    selectPlantView = [[SelectPlantView alloc] initWithFrame: CGRectMake(10, height+BED_LAYOUT_HEIGHT_BUFFER + 125, width+BED_LAYOUT_WIDTH_BUFFER, selectDimension)];

    
    //add my array of beds
    for(int i = 0; i<self.bedViewArray.count;i++){
        [self.bedFrameView addSubview:[self.bedViewArray objectAtIndex:i]];
    }
    
    int i = 0;
    for (UIView *subview in self.bedFrameView.subviews){
        //NSString *key = [NSString stringWithFormat:@"cell%i",i];
        
        //int plantId = (int)[[self.bedStateDict valueForKey:key] integerValue];
        int plantId = [self.currentGardenModel getPlantIdForCell:i];
        
        PlantIconView *plantIcon = [[PlantIconView alloc]
                                    initWithFrame:CGRectMake(6 + (bedIconDimension*i), 2, bedIconDimension,bedIconDimension) : plantId];
        UIImage *icon = [UIImage imageNamed: plantIcon.iconResource];

        //add icons to bedviews
        UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
        imageView.frame = CGRectMake(subview.bounds.size.width/4,
                                     subview.bounds.size.height/4,
                                     subview.bounds.size.width/2,
                                     subview.bounds.size.height/2);
        [subview addSubview:imageView];
        i++;
    }


    for(int i = 0; i<self.selectPlantArray.count;i++){
        [selectPlantView addSubview:[self.selectPlantArray objectAtIndex:i]];
    }
    self.selectMessageView = [[UIView alloc] initWithFrame:CGRectMake(10,
                                            height+BED_LAYOUT_HEIGHT_BUFFER + 102,
                                            width+BED_LAYOUT_WIDTH_BUFFER,
                                            20)];
    self.selectMessageView.layer.borderWidth = 3;
    self.selectMessageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:self.selectMessageView];
}

-(int)bedDimension{
    int columnDimension = (int)(self.view.bounds.size.width - 20) / (int)self.bedColumnCount;
    int bedDimension = (int)(self.view.bounds.size.height - 60) / (int)self.bedRowCount;
    if(bedDimension > columnDimension){
        bedDimension = columnDimension;
    }
    if(((self.view.frame.size.width - 20) / bedDimension) < 3)
            bedDimension = (int)(self.view.bounds.size.width - 20)/3;
    
    
    while(bedDimension * self.bedRowCount > (self.view.frame.size.height * .70)){
        bedDimension = bedDimension * .95;
    }
    
    [appGlobals setBedDimension:bedDimension];
    return bedDimension;
}

- (void)handleBedSingleTap:(UITapGestureRecognizer *)recognizer {
    //CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    for(int i = 0; i<self.bedViewArray.count; i++){
        UIView *bed = [self.bedViewArray objectAtIndex:i];
        bed.backgroundColor = [UIColor whiteColor];
        bed.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    //NSLog(@"Bed Single Tap View Id %@", recognizer.view.description);
    //recognizer.view.backgroundColor = [UIColor lightGrayColor];
    recognizer.view.layer.borderColor = [UIColor darkGrayColor].CGColor;
    BedView *bd = (BedView*)recognizer.view;
    appGlobals.selectedCell = bd.index;
    [self.navigationController performSegueWithIdentifier:@"showBedDetail" sender:self];
}
/*
- (void)handlePlantSingleTap:(UITapGestureRecognizer *)recognizer {
    if(appGlobals.selectedCell > -1){
        NSLog(@"Plant Single Tap View Id %@", recognizer.view.description);
        BedView *bed = [self.bedViewArray objectAtIndex: appGlobals.selectedCell];
        PlantIconView *selected = (PlantIconView*)recognizer.view;
        //PlantModel *plant = [[PlantModel alloc]initWithId:selected.index];
        appGlobals.selectedPlant = selected;
        UIImage *icon = [UIImage imageNamed: selected.iconResource];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
        imageView.frame = CGRectMake(bed.bounds.size.width/4,
                                     bed.bounds.size.height/4,
                                     bed.bounds.size.width/2,
                                     bed.bounds.size.height/2);
        [[bed subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [bed addSubview:imageView];
        [self.navigationController performSegueWithIdentifier:@"showBedDetail" sender:self];
    }
}
*/
- (NSMutableArray *)buildBedViewArray{
    NSMutableArray *bedArray = [[NSMutableArray alloc] init];
    int bedDimension = [self bedDimension];
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
            BedView *bed = [[BedView alloc] initWithFrame:CGRectMake(1 + (bedDimension*columnNumber),
                                                                     (bedDimension*rowNumber)+1, bedDimension, bedDimension): plantId];
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

- (NSMutableArray *)buildPlantSelectArray{
    NSMutableArray *selectArray = [[NSMutableArray alloc] init];
    int frameDimension = [self bedDimension] - 5;
    if((self.view.frame.size.width / frameDimension) > 6)frameDimension = self.view.frame.size.width / 6;
    if((self.view.frame.size.width / frameDimension) < 3)frameDimension = self.view.frame.size.width / 3;
    
    int rowCount = [dbManager getTableRowCount:@"plants"];
    for(int i=0; i<rowCount; i++){
        //PlantModel *plant = [[PlantModel alloc] initWithId:i+1];
        PlantIconView *plantIcon = [[PlantIconView alloc]
                                    initWithFrame:CGRectMake(6 + (frameDimension*i), 2, frameDimension,frameDimension) : i+1];
        UIImage *icon = [UIImage imageNamed: plantIcon.iconResource];
        //NSLog(@"res: %@", plantIcon.iconResource);
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


- (void) updatePlantBeds : (int)updatedCell : (int)plantId{
    [self.currentGardenModel setPlantIdForCell:updatedCell :plantId];
    self.bedViewArray = [self buildBedViewArray];
    self.selectPlantArray = [self buildPlantSelectArray];
    [self.currentGardenModel autoSaveModel];
    [appGlobals setCurrentGardenModel:self.currentGardenModel];
    //[self.currentGardenModel showModelInfo];
    [self initViews];
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
        evStartX = location.x - touchedView.center.x;
        evStartY = location.y - touchedView.center.y;
    }
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [BedView class]){
        touchedView.hidden=FALSE;
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
    if ([touchedView class] == [BedView class]){
        BedView *bedView = (BedView*)touchedView;
        //remove the bed from it's old spot
        [self updatePlantBeds: bedView.index : 0];

        float xCo = bedView.center.x;
        float yCo = bedView.center.y;
        
        float yLowerLimit = self.bedFrameView.center.y + self.bedFrameView.frame.size.height / 3;
        float yUpperLimit = 0;
        
        if(yCo > yLowerLimit)return;
        if(yCo < yUpperLimit)return;
        
        int i = 0;
        float leastSquare = 500000;
        int targetCell = -1;
        for(UIView *subview in self.bedFrameView.subviews){
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
        [self updatePlantBeds:targetCell:bedView.primaryPlant];
    }
}





@end


