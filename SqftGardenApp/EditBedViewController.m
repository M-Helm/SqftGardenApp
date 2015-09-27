//
//  MainViewController.h
//  SqftGardenApp
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.

#import "EditBedViewController.h"

#import "PlantIconView.h"
#import "ClassIconView.h"
//#import "SelectPlantView.h"
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
const int BED_LAYOUT_MINIMUM_DIMENSION = 55;
const int BED_LAYOUT_MAXIMUM_DIMENSION = 110;

NSString * const ROW_KEY = @"rows";
NSString * const COLUMN_KEY = @"columns";
float evStartX = 0;
float evStartY = 0;
//bool datePickerIsOpen = NO;

//SelectPlantView *selectPlantView;
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

    [self setDatePickerIsOpen:NO];
    [self setIsoViewIsOpen:NO];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.backgroundColor = [[UIColor orangeColor]colorWithAlphaComponent:.05];
    
    self.sideOffset = 10;
    self.topOffset = self.navigationController.navigationBar.frame.size.height * 1.5;
    
    self.heightMultiplier = self.view.frame.size.height/667;
    
    self.topOffset = self.topOffset*self.heightMultiplier;
    //NSLog(@"EditBed VC Calls show appG model info on %@", appGlobals.globalGardenModel.name);
    //[appGlobals.globalGardenModel showModelInfo];

    if ([appGlobals getCurrentGardenModel] != nil){
        //self.currentGardenModel = [appGlobals getCurrentGardenModel];
        [self setCurrentGardenModel: [appGlobals getCurrentGardenModel]];
        self.bedColumnCount = self.currentGardenModel.columns;
        self.bedRowCount = self.currentGardenModel.rows;
    }
    
    if (self.currentGardenModel == nil){
        if(appGlobals.hasShownLaunchScreen == NO)
            [self.navigationController performSegueWithIdentifier:@"showLaunch" sender:self];
        else{
            //NSLog(@"EDITBED VC REPORTS NIL FOR ITS MODEL");
            [self.navigationController performSegueWithIdentifier:@"showResize" sender:self];
        }
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
    [self.view addSubview:self.bedFrameView];
    [self.view addSubview:self.selectPlantView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initViews{
    //get rid of all old views.
    [self setIsoViewIsOpen:NO];
    [self.selectPlantView setIsoViewIsOpen:NO];
    for(UIView* subview in self.view.subviews){
        [subview removeFromSuperview];
    }
    //UIColor *color = [appGlobals colorFromHexString:@"#fefefe"];
    //self.view.backgroundColor = color;
    
    self.navigationItem.hidesBackButton = YES;
    [self.bedFrameView removeFromSuperview];
    int width = self.view.bounds.size.width;
    int height = self.view.frame.size.height * BED_LAYOUT_HEIGHT_RATIO;
    if(self.selectPlantView != nil){
        [self.selectPlantView removeFromSuperview];
    }
    UIImage *background = [UIImage imageNamed:@"cloth_test.png"];
    UIImageView *bk = [[UIImageView alloc]initWithImage:background];
    bk.alpha = 0.075;
    bk.frame = self.view.frame;
    [self.view addSubview:bk];
    

    
    [self makeSaveIcon];
    [self makeTitleBar];
    [self setToolIconPositions];
    [self makeBedFrame : width : height];
    [self makeSelectMessageView: width : height];
    [self makeSelectView: width : height];
    
    NSLog(@"select orgin = %i", (int)self.selectMessageLabel.frame.origin.y);
    self.selectPlantScreenView = [[UIView alloc] initWithFrame:CGRectMake(0,self.selectPlantView.frame.origin.y, self.view.frame.size.width,self.selectMessageView.frame.size.height + self.selectPlantView.frame.size.height)];
    self.selectPlantScreenView.backgroundColor = [UIColor darkGrayColor];
    self.selectPlantScreenView.alpha = 0;
    
    
    self.selectIsoView = [self makeIsoIconView];
    [self.view addSubview:self.selectPlantScreenView];
    [self.view addSubview:self.selectIsoView];
    

}
-(void)setToolIconPositions{
    //check if a date exists
    CGRect navBarFrame = CGRectMake((self.view.frame.size.width)-88-44,0,44,44);
    if(appGlobals.globalGardenModel.plantingDate != nil){
        NSDate *compareDate = [[NSDate alloc]initWithTimeIntervalSince1970:2000];
        if ([appGlobals.globalGardenModel.plantingDate compare:compareDate] == NSOrderedAscending) {
            //no date selected
            self.saveIconView.frame = navBarFrame;
            [self.navigationController.navigationBar addSubview:self.saveIconView];
            self.dateIconView = [self makeDateIcon];
            [self.titleView addSubview:self.dateIconView];
            
        }else{
            //a date is selected
            CGRect titleViewIconFrame = CGRectMake(20,0,44,44);
            self.saveIconView.frame = titleViewIconFrame;
            [self.titleView addSubview:self.saveIconView];
            
            [self makeDataPresentIcon];
            self.dataPresentIconView.frame = navBarFrame;
            [self.navigationController.navigationBar addSubview: self.dataPresentIconView];
        }
    }else{
        //something bad has happened. Throw an error
    }
}

-(void)makeSaveIcon{
    //remove self if exists
    [self.saveIconView removeFromSuperview];
    //make and add view
    UIImage *saveIcon = [UIImage imageNamed:@"ic_save_512px.png"];
    self.saveIconView = [[UIImageView alloc]initWithImage:saveIcon];
    //CGRect saveFrame = CGRectMake((self.view.frame.size.width)-88-44,0,44,44);
    CGRect saveFrame = CGRectMake(0,0,44,44);
    self.saveIconView.frame = saveFrame;
    self.saveIconView.userInteractionEnabled = YES;
    UITapGestureRecognizer *saveSingleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSaveIconSingleTap:)];
    [self.saveIconView addGestureRecognizer:saveSingleFingerTap];
    
    //if name.length < 1 we assume an empty garden model and alpha out save icon
    //if(appGlobals.globalGardenModel.name.length < 1) self.saveIconView.alpha = .05;
    
    //[self.navigationController.navigationBar addSubview:self.saveIconView];
}

-(void)makeDataPresentIcon{
    //remove self if exists
    [self.dataPresentIconView removeFromSuperview];
    UIImage *dataIcon = [UIImage imageNamed:@"ic_date_detail_512px.png"];
    self.dataPresentIconView = [[UIImageView alloc]initWithImage:dataIcon];
    CGRect dataFrame = CGRectMake((self.view.frame.size.width)-132-44,0,44,44);
    //CGRect dataFrame = CGRectMake(0,0,44,44);
    self.dataPresentIconView.frame = dataFrame;
    self.dataPresentIconView.alpha = 1;
    self.dataPresentIconView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleDataPresentIconSingleTap:)];
    [self.dataPresentIconView addGestureRecognizer:singleFingerTap];
    //[self.navigationController.navigationBar addSubview:self.dataPresentIconView];
}

-(UIImageView *)makeDateIcon{
    UIImage *dateIcon = [UIImage imageNamed:@"ic_edit_date_512px.png"];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:dateIcon];
    CGRect fm = CGRectMake(20,0,44,44);
    imgView.frame = fm;
    imgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleFingerTap =
                [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleDateIconSingleTap:)];
    [imgView addGestureRecognizer:singleFingerTap];
    return imgView;
}

-(void)makeTitleBar{
    //remove self if exists
    [self.titleView removeFromSuperview];
    //make and add view
    UIColor *color = [appGlobals colorFromHexString: @"#74aa4a"];
    float navBarHeight = self.navigationController.navigationBar.bounds.size.height *  1.5;
    
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(-15,navBarHeight - 2, self.view.frame.size.width - 5, self.topOffset)];
    self.titleView.backgroundColor = [color colorWithAlphaComponent:0.55];
    self.titleView.layer.cornerRadius = 15;
    self.titleView.layer.borderWidth = 3;
    self.titleView.layer.borderColor = [color colorWithAlphaComponent:1].CGColor;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(65,0, self.view.frame.size.width - 75, 18)];
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(65,18, self.view.frame.size.width - 75, (navBarHeight / 1.5)-18)];
    //NSString *gardenName = appGlobals.globalGardenModel.name;
    NSString *nameStr = appGlobals.globalGardenModel.name;
    NSString *plantDate = @"Planting not selected";
    if(appGlobals.globalGardenModel.plantingDate != nil){
        NSDate *compareDate = [[NSDate alloc]initWithTimeIntervalSince1970:2000];
        if ([appGlobals.globalGardenModel.plantingDate compare:compareDate] == NSOrderedAscending) {
            //no change
        }else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMM dd, yyyy"];
            plantDate = [dateFormatter stringFromDate: appGlobals.globalGardenModel.plantingDate];
        }
    }

    if(nameStr.length < 1)nameStr = @"New Garden";
    //if([nameStr isEqualToString:@"autoSave"])nameStr = @"New Garden";
    
    NSString *gardenName = [NSString stringWithFormat:@"Garden Name: %@",  nameStr];
    NSString *gardenDate = [NSString stringWithFormat:@"Planting Date: %@",  plantDate];
    //NSString *alertStr = [NSString stringWithFormat:@"File Saved as %@", fileName];
    label.text = gardenName;
    label2.text = gardenDate;
    [label setFont:[UIFont boldSystemFontOfSize:15]];
    [label2 setFont:[UIFont boldSystemFontOfSize:11]];
    //label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label2.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label2.backgroundColor = [UIColor clearColor];
    self.dateIconView = [self makeDateIcon];

    
    [self.titleView addSubview:label];
    [self.titleView addSubview:label2];
    //[self.titleView addSubview: self.dateIconView];
    [self.view addSubview: self.titleView];

}

-(void)makeBedFrame : (int) width : (int) height{
    
    float xCo = self.view.bounds.size.width;
    float yCo = self.bedRowCount * [self bedDimension];
    self.bedFrameView = [[UIView alloc]
                         initWithFrame:CGRectMake(self.sideOffset,
                                                  self.topOffset + self.titleView.frame.size.height+7,
                                                  xCo+(self.sideOffset*-2),
                                                  yCo)];
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

-(void)makeSelectMessageView : (int)width :(int)height{
    float selectMessageTopOffset = self.topOffset + self.titleView.frame.size.height + self.bedFrameView.frame.size.height;
    self.selectMessageView = [[UIView alloc] initWithFrame:CGRectMake(0,selectMessageTopOffset,width,20)];
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
    float selectTopOffset = self.topOffset
                        + self.titleView.frame.size.height
                        + self.bedFrameView.frame.size.height
                        + self.selectMessageView.frame.size.height;
    
    if((self.view.frame.size.width / selectDimension) > 6)selectDimension = self.view.frame.size.width / 6;
    if((self.view.frame.size.width / selectDimension) < 3)selectDimension = self.view.frame.size.width / 3;
    CGRect selectFrame = CGRectMake(0, selectTopOffset, width, selectDimension);
    //self.selectPlantView = [[SelectPlantView alloc]initWithEditBedVC:self];
    self.selectPlantView = [[SelectPlantView alloc]initWithFrame:selectFrame andEditBedVC:self];
    //self.selectPlantView.frame = selectFrame;
    //self.selectPlantView = [[SelectPlantView alloc] initWithFrame: CGRectMake(0, selectTopOffset, width, selectDimension)];
    for(int i = 0; i<self.selectPlantArray.count;i++){
        [self.selectPlantView addSubview:[self.selectPlantArray objectAtIndex:i]];
    }
    
    if((self.view.frame.size.height - selectTopOffset - selectDimension) > selectDimension){
        float messageFrameHeight = self.selectMessageView.frame.size.height;
        CGRect newSelectFrame = CGRectMake(0,
                                           self.view.frame.size.height - (selectDimension*2),
                                           width,
                                           selectDimension);
        CGRect newSelectMessageFrame = CGRectMake(0,
                                                  self.view.frame.size.height - (selectDimension*2)-messageFrameHeight,
                                                  width,
                                                  messageFrameHeight);
        self.selectPlantView.frame = newSelectFrame;
        self.selectMessageView.frame = newSelectMessageFrame;
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
    if(bedDimension < BED_LAYOUT_MINIMUM_DIMENSION) bedDimension = BED_LAYOUT_MINIMUM_DIMENSION;
    if(bedDimension > BED_LAYOUT_MAXIMUM_DIMENSION) bedDimension = BED_LAYOUT_MAXIMUM_DIMENSION;
    
    //magic numbers to support iphone 4 screen sizes
    if(self.view.frame.size.height < 481){
        if(bedDimension > 65)bedDimension = 65;
    }
    
    [appGlobals setBedDimension:bedDimension];
    return bedDimension;
}

- (void)handleBedSingleTap:(UITapGestureRecognizer *)recognizer {
    if(self.datePickerIsOpen)return;
    PlantIconView *bd = (PlantIconView*)recognizer.view;
    if(bd.plantId < 1)return;
    for(int i = 0; i<self.bedViewArray.count; i++){
        UIView *bed = [self.bedViewArray objectAtIndex:i];
        bed.backgroundColor = [UIColor clearColor];
        bed.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    recognizer.view.layer.borderColor = [UIColor darkGrayColor].CGColor;
    appGlobals.selectedPlant = bd;
    appGlobals.selectedCell = bd.position;
    [self calculatePlantDropPosition:bd];
    [self.navigationController performSegueWithIdentifier:@"showBedDetail" sender:self];
}

- (void)handleDateIconSingleTap:(UITapGestureRecognizer *)recognizer {
    //check if a date exists
    if(appGlobals.globalGardenModel.plantingDate != nil){
        
        NSDate *compareDate = [[NSDate alloc]initWithTimeIntervalSince1970:2000];
        if ([appGlobals.globalGardenModel.plantingDate compare:compareDate] == NSOrderedAscending) {
            
            //date selected go somewhere else...
            
            
        }else{
            //no date selected
            
            NSLog(@"NO DATE SELECTED. GO TO DATE PICKER");
            
        }
    }
    //for(UIView* subview in self.navigationController.navigationBar.subviews){
    //    [subview removeFromSuperview];
    //}
    

    [self showDatePickerView];
}
- (void)handleSaveIconSingleTap:(UITapGestureRecognizer *)recognizer {
    bool success = [self.currentGardenModel saveModelWithOverWriteOption:YES];
    NSLog(@"save icon tapped %i", success);
    if(success){
        [self showWriteSuccessAlertForFile:self.currentGardenModel.name atIndex:self.currentGardenModel.localId];
        [appGlobals setGlobalGardenModel:self.currentGardenModel];
    }
}

- (void)handleDataPresentIconSingleTap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"data present icon tapped ");
    [appGlobals setGlobalGardenModel:self.currentGardenModel];    
    self.dataPresentIconView.tag = 6;
    self.dataPresentIconView.alpha = 0;
    [self.navigationController performSegueWithIdentifier:@"showPresent" sender:self];
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
    }
    if([self.currentGardenModel getPlantIdForCell:0] < 0){
        for(int i=0; i<cellCount; i++){
            [self.currentGardenModel setPlantIdForCell:i :0];
        }
    }
    for(int i=0; i<self.bedRowCount; i++){
        while(columnNumber < self.bedColumnCount){
            int plantId = [self.currentGardenModel getPlantIdForCell:cell];

            float padding = [self calculateBedViewHorizontalPadding];
            PlantIconView *bed = [[PlantIconView alloc]
                                  initWithFrame:CGRectMake(padding + (bedDimension*columnNumber),
                                                           (bedDimension*rowNumber)+1,
                                                           bedDimension,
                                                           bedDimension)
                                                            withPlantId: plantId
                                                            isIsometric:NO];
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

- (void) updatePlantingDate : (NSDate *)date{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    //NSString *dateString = [dateFormat stringFromDate:date];
    //NSDate *formatedDate = [dateFormat dateFromString:dateString];
    
    //self.currentGardenModel.plantingDate = date;
    //appGlobals.globalGardenModel.plantingDate = date;
    [self.currentGardenModel setPlantingDate:date];
    //[appGlobals.globalGardenModel setPlantingDate:date];
    [self.currentGardenModel autoSaveModel];
    [appGlobals setCurrentGardenModel:self.currentGardenModel];
    NSLog(@"Dates from updater: self %@, global %@", self.currentGardenModel.plantingDate, appGlobals.globalGardenModel.plantingDate);

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


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //if(self.datePickerIsOpen)return;
    if(self.isoViewIsOpen)return;
    if(appGlobals.isMenuDrawerOpen == YES){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyButtonPressed" object:self];
        return;
    }
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [PlantIconView class]){
        PlantIconView *plantView = (PlantIconView*)[touch view];
        if(plantView.plantId < 1)return;
        CGPoint location = [touch locationInView:[self view]];
        evStartX = location.x - touchedView.center.x;
        evStartY = location.y - touchedView.center.y;
        AudioServicesPlaySystemSound(1104);
    }
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    //if(self.datePickerIsOpen)return;
    if(self.isoViewIsOpen)return;
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
    //if(self.datePickerIsOpen)return;
    if(self.isoViewIsOpen)return;
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
        //if we're far from a bedview just return
        //NSLog(@"squares reports at D: %f , LOS: %f", deltaSquare, leastSquare);
        if(leastSquare > (appGlobals.bedDimension * appGlobals.bedDimension)*2){
            touchedView.alpha = 0;
            [touchedView removeFromSuperview];
            return;
        }
        
        [self updatePlantBeds:targetCell:bedView.plantId];
        //AudioServicesPlaySystemSound(1104);
    }
}

-(void) showDatePickerView{

    if(self.datePickerIsOpen){
        [self setDatePickerIsOpen:NO];
        [self.selectPlantView setDatePickerIsOpen:NO];
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
                             self.datePickerView.alpha = 0.0f;
                             self.bedFrameView.alpha = 1.00f;
                             self.selectMessageView.alpha = 1.00f;
                             self.selectPlantView.alpha = 1.00f;
                         }
                         completion:^(BOOL finished) {
                             [self initViews];
                         }];
        return;
    }
    [self setDatePickerIsOpen:YES];
    [self.selectPlantView setDatePickerIsOpen:YES];
    self.datePickerView = [[DateSelectView alloc] init];
    self.datePickerView.userInteractionEnabled = YES;
    [self.datePickerView createDatePicker:self];

    CGRect fm = CGRectMake(self.bedFrameView.frame.origin.x, self.bedFrameView.frame.origin.y, self.bedFrameView.frame.size.width, 44+216);
    self.datePickerView.frame = fm;
    
    self.datePickerView.alpha = 1.0f;
    [self.view addSubview:self.datePickerView];

    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.datePickerView.alpha = 1.0f;
                         self.bedFrameView.alpha = 0.00f;
                         self.selectMessageView.alpha = 0.00f;
                         self.selectPlantView.alpha = 0.00f;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void) showWriteSuccessAlertForFile: (NSString *)fileName atIndex: (int) index{
    NSString *alertStr = [NSString stringWithFormat:@"File Saved as %@", fileName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:appGlobals.appTitle
                                                    message: alertStr
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

- (UIView *)makeIsoIconView{
    //float navBarHeight = self.navigationController.navigationBar.bounds.size.height *  1.5;
    UIImage *icon = [UIImage imageNamed:@"ic_isometric_256px.png"];
    UIImageView *isoIcon = [[UIImageView alloc] initWithImage:icon];
    isoIcon.frame = CGRectMake(self.view.frame.size.width-44, self.view.frame.size.height-44, 44, 44);
    isoIcon.layer.borderColor = [UIColor blackColor].CGColor;
    isoIcon.layer.borderWidth = 2;
    isoIcon.layer.cornerRadius = 5;

    isoIcon.userInteractionEnabled = YES;
    isoIcon.clipsToBounds = YES;
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleIsoIconSingleTap:)];
    [isoIcon addGestureRecognizer:singleFingerTap];
    
    return isoIcon;
}
- (void)handleIsoIconSingleTap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"handle iso singletap");
    if(self.isoViewIsOpen){
        NSLog(@"isoview is open");
        [self.isoView unwindIsoViewTransform];
        return;
    }
    
    [self setIsoViewIsOpen:YES];
    [self.selectPlantView setIsoViewIsOpen:YES];
    //bool success = [self.currentGardenModel saveModelWithOverWriteOption:YES];
    [appGlobals setGlobalGardenModel:self.currentGardenModel];
    //NSLog(@"iso icon tapped");
    self.isoView = [[IsometricView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height - 44) andEditBedVC:self];

    
    self.isoView.alpha = 1;
    self.bedFrameView.alpha = 0;
    self.selectPlantView.alpha = .25;
    self.selectMessageView.alpha = .25;
    self.selectPlantScreenView.alpha = .8;

    [self.view addSubview:self.isoView];
   
}
- (void)unwindIsoView{
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.isoView.alpha = 0;
                         self.bedFrameView.alpha = 1;
                         self.selectPlantView.alpha = 1;
                         self.selectMessageView.alpha = 1;
                         self.selectPlantScreenView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         if(finished){
                             [self initViews];
                             [self setIsoViewIsOpen:NO];
                             [self.selectPlantView setIsoViewIsOpen:NO];
                             [self.isoView removeFromSuperview];
                         }
                     }];
}

@end


