//
//  MainViewController.h
//  SqftGardenApp
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.

#import "EditBedViewController.h"
#import "PlantIconView.h"
#import "ClassIconView.h"
#import "ApplicationGlobals.h"
#import "DBManager.h"
#import "PlantingDateViewController.h"




#define amDebugging ((bool) YES)
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface EditBedViewController ()

@end

@implementation EditBedViewController

const float BED_LAYOUT_HEIGHT_RATIO = .60;
const int BED_LAYOUT_MINIMUM_DIMENSION = 55;
const int BED_LAYOUT_MAXIMUM_DIMENSION = 110;
float editStartX = 0;
float editStartY = 0;




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
    _showTouches = NO;
    [self setToolBarIsOpen:YES];
    [self setDatePickerIsOpen:NO];
    [self setIsoViewIsOpen:NO];

    
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.backgroundColor = [[UIColor orangeColor]colorWithAlphaComponent:.05];
    //NSMutableArray *vcArray = [[NSMutableArray alloc] init];
    //[vcArray addObject:self];
    //self.navigationController.viewControllers = vcArray;
    
    
    self.sideOffset = 10;
    
    self.topOffset = self.navigationController.navigationBar.frame.size.height * 1.5;
    self.heightMultiplier = self.view.frame.size.height/667;
    self.topOffset = self.topOffset*self.heightMultiplier;

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
    self.bedCellCount = self.bedRowCount * self.bedColumnCount;
    self.bedViewArray = [self buildBedViewArray];
    self.selectPlantArray = [self buildClassSelectArray];
    [self.currentGardenModel setRows:self.bedRowCount];
    [self.currentGardenModel setColumns:self.bedColumnCount];
    [self initViews];
    [Appirater tryToShowPrompt];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //turn bedframe clear
    self.bedFrameView.backgroundColor = [UIColor clearColor];
    
    //NSLog(@"should be tracking");
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"mainViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

    for(UIView *subview in self.navigationController.view.subviews){
        if(subview.tag == 77){
            subview.alpha = 0;
            [subview removeFromSuperview];
        }
    }
}



- (void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    for(int i =0; i<self.bedViewArray.count; i++){
        PlantIconView *bed = [self.bedViewArray objectAtIndex:i];
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleBedSingleTap:)];
        [bed addGestureRecognizer:singleFingerTap];
    }
    
    [self.view addSubview:self.bedFrameView];
    [self.view addSubview:self.selectPlantView];
    [self.view addSubview:self.toolBar];
    //[self.toolBar showToolBar];
    //[self.toolBar setToolBarIsPinned:YES];

}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //have to call this here for the toolbar to work.
    [self initViews];
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
    
    self.toolBar = [self makeToolbar];
    [self.view addSubview:self.toolBarContainer];
    
    
    [self makeTitleBar];
    [self makeBedFrameView];
    [self makeSelectMessageView: width : height];
    [self makeSelectView: width : height];
    [self makeShareButton];

}

-(GrowToolBarView *)makeToolbar{
    
    for(UIView *subview in self.navigationController.view.subviews){
        if([subview class] == [GrowToolBarView class])[subview removeFromSuperview];
    }
    
    float toolBarYOrigin = self.view.frame.size.height-44;
    if(!self.toolBarIsOpen)toolBarYOrigin = self.view.frame.size.height;
    
    GrowToolBarView *toolBar = [[GrowToolBarView alloc] initWithFrame:CGRectMake(0,toolBarYOrigin,self.view.frame.size.width,44) andViewController:self];
    
    //using this view to detect touches to toolbar are when the bar itself is hidden
    self.toolBarContainer = [[UIView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-44,self.view.frame.size.width,44)];
    self.toolBarContainer.userInteractionEnabled = YES;
    self.toolBarContainer.tag = 7;
    
    return toolBar;
}


-(void)makeTitleBar{
    //remove self if exists
    [self.titleView removeFromSuperview];
    //make and add view
    UIColor *color = [appGlobals colorFromHexString: @"#74aa4a"];
    float navBarHeight = self.navigationController.navigationBar.bounds.size.height *  1.5;
    
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(-15,
                                                              navBarHeight *.5,
                                                              self.view.frame.size.width - 5,
                                                              self.topOffset * .75)];
    self.titleView.backgroundColor = [color colorWithAlphaComponent:0.45];
    self.titleView.layer.cornerRadius = 15;
    self.titleView.layer.borderWidth = 3;
    self.titleView.layer.borderColor = [color colorWithAlphaComponent:1].CGColor;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(35,0, self.view.frame.size.width - 75, 18)];
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(35,label.frame.origin.y+14, self.view.frame.size.width - 75, (navBarHeight / 1.5)-18)];
    //NSString *gardenName = appGlobals.globalGardenModel.name;
    NSString *nameStr = appGlobals.globalGardenModel.name;
    NSString *plantDate = @"Planting date not set";
    if(appGlobals.globalGardenModel.frostDate != nil){
        NSDate *compareDate = [[NSDate alloc]initWithTimeIntervalSince1970:2000];
        if ([appGlobals.globalGardenModel.frostDate compare:compareDate] == NSOrderedAscending) {
            //no change
        }else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMM dd, yyyy"];
            plantDate = [dateFormatter stringFromDate: appGlobals.globalGardenModel.frostDate];
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

    [self.titleView addSubview:label];
    [self.titleView addSubview:label2];
    
    [self.view addSubview: self.titleView];

}
-(void)makeBedFrameView{
    //remove self if exists
    if(self.bedFrameView != nil)[self.bedFrameView removeFromSuperview];
    //init
    self.bedFrameView = [[UIView alloc]
                         initWithFrame:[self calculateBedFrame]];
    self.bedFrameView.backgroundColor = [UIColor clearColor];
    //add my array of beds
    for(int i = 0; i<self.bedViewArray.count;i++){
        [self.bedFrameView addSubview:[self.bedViewArray objectAtIndex:i]];
    }
}

-(CGRect)calculateBedFrame{
    float xCo = self.view.bounds.size.width;
    float yCo = self.bedRowCount * [self bedDimension];
    CGRect bedFrame = CGRectMake(self.sideOffset,
                                  self.topOffset + self.titleView.frame.size.height+7,
                                  xCo+(self.sideOffset*-2),
                                  yCo);
    return bedFrame;
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
    self.selectPlantView = [[SelectPlantView alloc]initWithFrame:selectFrame andEditBedVC:self];
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
    if(self.bedColumnCount < 1)self.bedColumnCount = 1;
    if(self.bedRowCount < 1)self.bedRowCount = 1;
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
    if([self.currentGardenModel getPlantUuidForCell:0] < 0){
        for(int i=0; i<cellCount; i++){
            [self.currentGardenModel setPlantUuidForCell:i :@"nil"];
        }
    }
    for(int i=0; i<self.bedRowCount; i++){
        while(columnNumber < self.bedColumnCount){
            NSString *plantUuid = [self.currentGardenModel getPlantUuidForCell:cell];
            //NSLog(@"plantUUID in build = %@", plantUuid);
            //int plantId = [self.currentGardenModel getPlantIdForCell:cell];
            float padding = [self calculateBedViewHorizontalPadding];
            PlantIconView *plantView = [[PlantIconView alloc]
                                  initWithFrame:CGRectMake(padding + (bedDimension*columnNumber),
                                                           (bedDimension*rowNumber)+1,
                                                           bedDimension,
                                                           bedDimension)
                                                            withPlantUuid: plantUuid
                                                            isIsometric:NO];
            //test if multi-sqft and adjust frame if so
            if(plantView.model.squareFeet > 1){
                CGRect frame = CGRectMake(plantView.frame.origin.x,
                                          plantView.frame.origin.y,
                                          (appGlobals.bedDimension -5)*(plantView.model.squareFeet /2),
                                          (appGlobals.bedDimension -5)*(plantView.model.squareFeet /2));
                plantView.frame = frame;
                [plantView setImageGrid:1 :1];
            }
            //plantView.layer.borderWidth = 2;
            plantView.model.position = cell;
            [bedArray addObject:plantView];
            //if(i==0)self.bedViewAnchor = bed.frame.origin;
            columnNumber++;
            cell++;
        }
        columnNumber = 0;
        rowNumber++;
    }
    //iterate thru the array, if multi-sqft plants, null out adjacent cells
    int i = 0;
    NSArray *tempArray = [[NSArray alloc]initWithArray:bedArray];
    for(PlantIconView *plantView in tempArray){
        plantView.model.position = i;
        if(plantView.model.squareFeet > 1){
            PlantIconView *nullPlant0 = [[PlantIconView alloc]initWithFrame:CGRectMake(0,0,0,0) withPlantUuid:@"0" isIsometric:NO];
            PlantIconView *nullPlant1 = [[PlantIconView alloc]initWithFrame:CGRectMake(0,0,0,0) withPlantUuid:@"0" isIsometric:NO];
            PlantIconView *nullPlant2 = [[PlantIconView alloc]initWithFrame:CGRectMake(0,0,0,0) withPlantUuid:@"0" isIsometric:NO];
            [bedArray replaceObjectAtIndex:i+1 withObject:nullPlant0];
            [self.currentGardenModel setPlantUuidForCell:i+1 :@"0"];
            if(i+1 < (tempArray.count-self.currentGardenModel.columns)){
                [bedArray replaceObjectAtIndex:i+self.currentGardenModel.columns withObject:nullPlant1];
                [bedArray replaceObjectAtIndex:i+1+self.currentGardenModel.columns withObject:nullPlant2];
                
                //update our model too
                [self.currentGardenModel setPlantUuidForCell:i+self.currentGardenModel.columns :@"0"];
                [self.currentGardenModel setPlantUuidForCell:i+1+self.currentGardenModel.columns :@"0"];
            }
        }
        i++;
    }

    return bedArray;
}

- (float) calculateBedViewHorizontalPadding{
    float padding = 1;
    padding = (self.view.frame.size.width - (([self bedDimension]-1)*self.bedColumnCount))/2;
    [self setCellHorizontalPadding:padding];
    return padding;
}

- (void) updatePlantBeds : (int)updatedCell : (NSString *)plantUuid{
    if(plantUuid == nil)plantUuid = @"nil";
    [self.currentGardenModel setPlantUuidForCell:updatedCell :plantUuid];
    self.bedViewArray = [self buildBedViewArray];
    self.selectPlantArray = [self buildClassSelectArray];
    [self.currentGardenModel autoSaveModel];
    [appGlobals setCurrentGardenModel:self.currentGardenModel];
    //[self.currentGardenModel showModelInfo];
    [self initViews];
    //[self makeBedFrameView];
}

- (void) updatePlantingDate : (NSDate *)date{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    [self.currentGardenModel setFrostDate:date];
    [self.currentGardenModel autoSaveModel];
    [appGlobals setCurrentGardenModel:self.currentGardenModel];
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

    UITouch *touch = [[event allTouches] anyObject];
    if(self.showTouches){
        self.touchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,34,34)];
        UIImage *icon = [UIImage imageNamed:@"asset_circle_token_512px.png"];
        self.touchIcon.image = icon;
        self.touchIcon.center = [touch locationInView:self.view];
        self.touchIcon.alpha = .8;
        [self.view addSubview:self.touchIcon];
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.touchIcon.alpha = .5;
                         }
                         completion:^(BOOL finished) {
                             //do stuff
                         }];
    }
    if(appGlobals.isMenuDrawerOpen == YES){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyButtonPressed" object:self];
        return;
    }
    
    UIView *touchedView;
    if([touch view] != nil){
        touchedView = [touch view];
        if(touchedView.tag == self.toolBar.toolBarTag)return;
        if((touchedView.tag == 7) && (!self.toolBarIsOpen)){
            [self.toolBar showToolBar];
            self.toolBarIsOpen = YES;
        }
        if((self.toolBarIsOpen) && (touchedView.tag != 7)){
            //[self.toolBar hideToolBar];
            //self.toolBarIsOpen = NO;
        }
    }
    if(self.isoViewIsOpen)return;
    
    if ([touchedView class] == [PlantIconView class]){
        PlantIconView *plantView = (PlantIconView*)[touch view];
        if(plantView.plantUuid.length < 5)return;
        CGPoint location = [touch locationInView:[self view]];
        editStartX = location.x - touchedView.center.x;
        editStartY = location.y - touchedView.center.y;
        AudioServicesPlaySystemSound(1104);
    }
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //if(self.datePickerIsOpen)return;
    if(self.isoViewIsOpen)return;
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    if(self.showTouches){
        self.touchIcon.center = [touch locationInView:self.view];
    }
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [PlantIconView class]){
        PlantIconView *plantView = (PlantIconView*)[touch view];
        if(plantView.plantUuid.length < 5)return;
        plantView.hidden=FALSE;
        if(plantView.model.squareFeet < 2)plantView.layer.borderWidth = 0;
        [self.view bringSubviewToFront:touchedView];
        [self.bedFrameView bringSubviewToFront:touchedView];
        CGPoint location = [touch locationInView:[self view]];
        location.x = location.x - editStartX;
        location.y = location.y - editStartY;
        touchedView.center = location;
        
        
        //check to see if we need to give it a multi-sqft frame
        if(plantView.model.squareFeet > 1){
            //check frame size
            if(plantView.frame.size.width > appGlobals.bedDimension - 5)return;
            //update frame size
            CGRect frame = CGRectMake(plantView.frame.origin.x,
                                      plantView.frame.origin.y,
                                      (appGlobals.bedDimension -5)*(plantView.model.squareFeet /2),
                                      (appGlobals.bedDimension -5)*(plantView.model.squareFeet /2));
            plantView.frame = frame;
            plantView.layer.borderColor = [UIColor blackColor].CGColor;
            plantView.layer.borderWidth = 2;
            //redraw the icon in the new frame
            [plantView setImageGrid:1 :1];
        }
    }

    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //if(self.datePickerIsOpen)return;
    if(self.isoViewIsOpen)return;
    UITouch *touch = [[event allTouches] anyObject];
    if(self.showTouches){
        self.touchIcon.center = [touch locationInView:self.view];
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.touchIcon.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [self.touchIcon removeFromSuperview];
                         }];
    }
    UIView *touchedView;
    if([touch view] != nil){
        touchedView = [touch view];
    }
    else return;
    [self calculatePlantDropPosition:touchedView];
}

-(void)calculatePlantDropPosition : (UIView*)touchedView{
    if ([touchedView class] == [PlantIconView class]){
        PlantIconView *plantView = (PlantIconView*)touchedView;
        //remove the bed from it's old spot
        [self updatePlantBeds: plantView.model.position : @"0"];
        
        float xCo = plantView.center.x;
        float yCo = plantView.center.y;
        
        //test if we're multi sqft and set xCo and yCo if so
        if(plantView.model.squareFeet > 1){
            xCo = plantView.frame.origin.x + ((appGlobals.bedDimension -5) /2);
            yCo = plantView.frame.origin.y + ((appGlobals.bedDimension -5) /2);
        }
        
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
        if(leastSquare > (appGlobals.bedDimension * appGlobals.bedDimension)*2){
            touchedView.alpha = 0;
            [touchedView removeFromSuperview];
            return;
        }
        if(self.touchIcon != nil)[self.touchIcon removeFromSuperview];
        
        if(plantView.model.squareFeet > 1){
            //and kick out if we'll draw part out of bounds
            //right hand column
            if((targetCell+1) % self.currentGardenModel.columns == 0){
                [touchedView removeFromSuperview];
                return;
            }
            //special case for width == 2
            if(self.currentGardenModel.columns > 1 || self.currentGardenModel.columns < 3){
                //last row
                if((targetCell) < (self.currentGardenModel.rows * self.currentGardenModel.columns - 3)){
                    [self updatePlantBeds:targetCell:plantView.plantUuid];
                    return;
                }
            }
            //last row
            if((targetCell) > (self.currentGardenModel.rows * (self.currentGardenModel.columns-1)-2)){
                [touchedView removeFromSuperview];
                return;
            }
        }
        [self updatePlantBeds: targetCell :plantView.plantUuid];
        //AudioServicesPlaySystemSound(1104);
        
    }
}

-(void) showDatePickerView{
    
    if(true){
        [self.navigationController performSegueWithIdentifier:@"showPlantDate" sender:self];
        return;
    }
    
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
    CGRect fm = CGRectMake((self.view.frame.size.width-315)/2, self.view.frame.origin.y+80, 300, 44+216);

    //CGRect fm = CGRectMake(self.bedFrameView.frame.origin.x, self.bedFrameView.frame.origin.y, self.bedFrameView.frame.size.width, 44+216);
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


- (void)handleBedSingleTap:(UITapGestureRecognizer *)recognizer {
    if(self.datePickerIsOpen)return;
    PlantIconView *bd = (PlantIconView*)recognizer.view;
    if(bd.plantUuid.length < 5){
        if(self.touchIcon != nil)[self.touchIcon removeFromSuperview];
        return;
    }
    for(int i = 0; i<self.bedViewArray.count; i++){
        UIView *bed = [self.bedViewArray objectAtIndex:i];
        bed.backgroundColor = [UIColor clearColor];
        bed.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    recognizer.view.layer.borderColor = [UIColor darkGrayColor].CGColor;
    appGlobals.selectedPlant = bd;
    appGlobals.selectedCell = bd.model.position;
    [self calculatePlantDropPosition:bd];
    [self.navigationController performSegueWithIdentifier:@"showBedDetail" sender:self];
}

- (void)unwindIsoView {
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.isoView.alpha = 0;
                         self.bedFrameView.alpha = 1;
                         //self.selectPlantView.alpha = 1;
                         //self.selectMessageView.alpha = 1;
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

- (void)hideSelectView{
    CGRect selectFrame = self.selectPlantView.frame;
    CGRect msgFrame = self.selectMessageView.frame;
    CGRect frame = CGRectMake(selectFrame.origin.x, selectFrame.origin.y+300,
                              selectFrame.size.width, selectFrame.size.height);
    CGRect mFrame = CGRectMake(msgFrame.origin.x, msgFrame.origin.y+300,
                              msgFrame.size.width, msgFrame.size.height);
    [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.selectPlantView.alpha = .5;
                         self.selectMessageView.alpha = .5;
                         self.selectPlantView.frame = frame;
                         self.selectMessageView.frame = mFrame;
                     }
                     completion:^(BOOL finished) {
                         if(finished){
                             //do stuff
                         }
                     }];
}
- (void)showSelectView{
    CGRect selectFrame = self.selectPlantView.frame;
    CGRect msgFrame = self.selectMessageView.frame;
    CGRect frame = CGRectMake(selectFrame.origin.x,selectFrame.origin.y-300,
                              selectFrame.size.width, selectFrame.size.height);
    CGRect mFrame = CGRectMake(msgFrame.origin.x, msgFrame.origin.y-300,
                               msgFrame.size.width, msgFrame.size.height);
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.selectPlantView.alpha = 1;
                         self.selectMessageView.alpha = 1;
                         self.selectPlantView.frame = frame;
                         self.selectMessageView.frame = mFrame;
                     }
                     completion:^(BOOL finished) {
                         if(finished){
                             //do stuff
                         }
                     }];
}

- (UIImage *)takeScreenshot {
    //add white background for the shot
    self.bedFrameView.layer.borderWidth = 0;
    self.bedFrameView.backgroundColor = [UIColor whiteColor];
    if(self.isoViewIsOpen){
        [self.isoView addSubview:[self makePromoLabel]];
        self.isoView.backgroundColor = [UIColor whiteColor];
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, YES, 0.0f);
        [self.isoView drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    UIGraphicsBeginImageContextWithOptions(self.bedFrameView.bounds.size, YES, 0.0f);
    [self.bedFrameView drawViewHierarchyInRect:self.bedFrameView.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (BOOL)shareLinkOnFB {
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:@"https://itunes.apple.com/us/app/growsquared/id1053329069?ls=1&mt=8"];
    
    return YES;
}


- (void) makeShareButton{
    [self.shareButton removeFromSuperview];
    UIImageView *imageBtn = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-44,25,44,44)];
    
    UIImage *icon = [UIImage imageNamed:@"ic_facebook_128px.png"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,33,44,11)];

    [label setFont:[UIFont systemFontOfSize:10]];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.text = @"Share";
    //[imageBtn addSubview:label];
    
    [imageBtn setImage:icon];
    imageBtn.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleFBButtonSingleTap:)];
    [imageBtn addGestureRecognizer:singleFingerTap];
    imageBtn.userInteractionEnabled = YES;
    self.shareButton = imageBtn;
    [self.view addSubview:self.shareButton];
}

- (void)handleFBButtonSingleTap:(UITapGestureRecognizer *)recognizer {
    //GA Tracking setup
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"fbShare"
                                                          action:@"Select"
                                                           label:@"shareBtnPress"
                                                           value:@1] build]];
    
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    UIImage *image = [self takeScreenshot];
    photo.image = image;
    photo.userGenerated = YES;
    //photo.caption = @"http://growsquared.net";
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[photo];
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:nil];
}

-(UIView *)makePromoLabel{
    UIView *promo = [[UIView alloc]initWithFrame:CGRectMake(0,self.isoView.bounds.size.height-24,200,24)];
    //UIColor *color = [appGlobals colorFromHexString: @"#74aa4a"];
    //promo.backgroundColor = [color colorWithAlphaComponent:0.45];
    promo.backgroundColor = [UIColor clearColor];
    //promo.layer.borderWidth = 3;
    promo.layer.cornerRadius = 15;
    //promo.layer.borderColor = color.CGColor;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0,0,200,24)];
    label.textColor = [UIColor lightGrayColor];
    [label setFont: [UIFont systemFontOfSize:12]];
    label.text = @"growsquared.net";
    label.textAlignment = NSTextAlignmentCenter;
    [promo addSubview:label];
    return promo;
}

#pragma mark delegate methods

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults :(NSDictionary*)results {
    NSLog(@"FB: SHARE RESULTS=%@\n",[results debugDescription]);
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"FB: ERROR=%@\n",[error debugDescription]);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"FB: CANCELED SHARER=%@\n",[sharer debugDescription]);
}


@end


