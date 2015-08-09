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
NSString * const ROW_KEY = @"rows";
NSString * const COLUMN_KEY = @"columns";



//UIView *bedFrameView;
SelectPlantView *selectPlantView;

ApplicationGlobals *appGlobals;
DBManager *dbManager;

- (id) initWithDimensions:(int)rows columns:(int)columns {
    self.bedRowCount = rows;
    self.bedColumnCount = columns;
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    if (self.bedStateDict == nil)self.bedStateDict = [[NSMutableDictionary alloc]init];
    //self.bedStateDict = [appGlobals getCurrentBedState];
    
    
    NSString *key = [NSString stringWithFormat:@"cell%i",0];
    int plantId = (int)[[self.bedStateDict valueForKey:key] integerValue];
    NSLog(@"plant Id from globals = %i", plantId);
    
    
    if((int)self.bedRowCount < 1)self.bedRowCount = 3;
    if((int)self.bedColumnCount < 1)self.bedColumnCount = 3;
    
    NSNumber *nRows = [NSNumber numberWithInt: self.bedRowCount];
    NSNumber *nCols = [NSNumber numberWithInt: self.bedColumnCount];
    [self.bedStateDict setObject: nRows forKey:ROW_KEY];
    [self.bedStateDict setObject: nCols forKey:COLUMN_KEY];
    
    
    self.bedCellCount = self.bedRowCount * self.bedColumnCount;
    self.bedViewArray = [self buildBedViewArray];
    self.selectPlantArray = [self buildPlantSelectArray];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    dbManager = [DBManager getSharedDBManager];
    appGlobals.selectedCell = -1;
    
    [self initViews];
}

- (void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.bedFrameView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.bedFrameView.layer.borderWidth = 3;
    self.bedFrameView.layer.cornerRadius = 15;
    //NSMutableArray *selectPlantArray = [self buildPlantSelectArray];
    
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
    int bedDimension = [self bedDimension];
    int frameDimension = bedDimension - 5;
    float xCo = self.view.bounds.size.width;
    int yCo = self.bedRowCount * bedDimension;
    self.bedFrameView = [[UIView alloc] initWithFrame:CGRectMake(10, 100,
                    xCo+BED_LAYOUT_WIDTH_BUFFER, yCo+BED_LAYOUT_HEIGHT_BUFFER)];
    
    //add my array of beds
    for(int i = 0; i<self.bedViewArray.count;i++){
        [self.bedFrameView addSubview:[self.bedViewArray objectAtIndex:i]];
    }
    
    int i = 0;
    //NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    for (UIView *subview in self.bedFrameView.subviews){
        NSString *key = [NSString stringWithFormat:@"cell%i",i];
        int plantId = (int)[[self.bedStateDict valueForKey:key] integerValue];
        
        PlantIconView *plantIcon = [[PlantIconView alloc]
                                    initWithFrame:CGRectMake(6 + (frameDimension*i), 2, frameDimension,frameDimension) : plantId];
        UIImage *icon = [UIImage imageNamed: plantIcon.iconResource];

        //add locations to array for drop & drag
        //NSValue *point = [NSValue valueWithCGPoint: subview.center];
        //[tempArray addObject:point];

        //add icons to bedviews
        UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
        imageView.frame = CGRectMake(subview.bounds.size.width/4,
                                     subview.bounds.size.height/4,
                                     subview.bounds.size.width/2,
                                     subview.bounds.size.height/2);
        [subview addSubview:imageView];
        i++;
    }
    //appGlobals.bedLocationArray = tempArray;
    //NSLog(@"count: %i", appGlobals.bedLocationArray.count);
    if(selectPlantView != nil){
        [selectPlantView removeFromSuperview];
    }
    selectPlantView = [[SelectPlantView alloc] initWithFrame: CGRectMake(10, yCo+BED_LAYOUT_HEIGHT_BUFFER + 125, xCo+BED_LAYOUT_WIDTH_BUFFER,bedDimension)];
    for(int i = 0; i<self.selectPlantArray.count;i++){
        [selectPlantView addSubview:[self.selectPlantArray objectAtIndex:i]];
    }
    self.selectMessageView = [[UIView alloc] initWithFrame:CGRectMake(10,
                                            yCo+BED_LAYOUT_HEIGHT_BUFFER + 102,
                                            xCo+BED_LAYOUT_WIDTH_BUFFER,
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
    //NSNumber *plantId = [NSNumber numberWithInt:0];
    int cellCount = self.bedRowCount * self.bedColumnCount;
    if(self.bedStateDict == nil){
        self.bedStateDict = [[NSMutableDictionary alloc]init];
    }
    if([self.bedStateDict objectForKey:@"cell0"] < 0){
        //NSLog(@"dict initialized");
        for(int i=0; i<cellCount; i++){
            NSString *key = [NSString stringWithFormat:@"cell%i",i];
            [self.bedStateDict setValue:0 forKey: key];
        }
    }
    for(int i=0; i<self.bedRowCount; i++){
        while(columnNumber < self.bedColumnCount){
            NSString *key = [NSString stringWithFormat:@"cell%i",cell];
            int plantId = (int)[[self.bedStateDict valueForKey:key] integerValue];
            //NSLog(@"Get Function: %i , %@", plantId, key);
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
    //save plant selection to dict
    NSNumber *selectedId = [NSNumber numberWithInt:plantId];
    NSString *key = [NSString stringWithFormat:@"cell%i",updatedCell];
    NSLog(@"Insert Function: %i , %@", plantId, key);
    [self.bedStateDict setValue:selectedId forKey: key];
    
    self.bedViewArray = [self buildBedViewArray];
    self.selectPlantArray = [self buildPlantSelectArray];
    [self saveCurrentBed:self.bedStateDict];
    [self initViews];
}

- (BOOL) saveCurrentBed : (NSMutableDictionary *)bedJSON{
    NSLog(@"step 1");
    
    //[dbManager dropTable:@"saves"];
    NSString *local_id = @"1";
    long ts = (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970]);
    NSString *timestamp = [NSString stringWithFormat:@"%ld", ts];
    NSString *name = @"autoSave";
    
    NSNumber *rows = [NSNumber numberWithInt:(int)[[bedJSON valueForKey:ROW_KEY]integerValue]];
    
    NSLog(@"rows %i", rows.integerValue);
    
    //if(rows.integerValue < 1)return false;
    
    
    NSNumber *columns = [NSNumber numberWithInt:(int)[[bedJSON valueForKey:COLUMN_KEY] integerValue]];
    
    NSLog(@"columns %i", columns.integerValue);
    
    //if(columns.integerValue < 1 )return false;
    
    if(![dbManager checkTableExists:@"saves"]){
        NSLog(@"no saves table exists");
        [dbManager createTable:@"saves"];
        [dbManager addColumn:@"saves" : @"rows" : @"int"];
        [dbManager addColumn:@"saves" : @"columns" : @"int" ];
        [dbManager addColumn:@"saves" : @"bedstate" : @"char(255)" ];
        [dbManager addColumn:@"saves" : @"timestamp" : @"int"];
        [dbManager addColumn:@"saves" : @"name" : @"char(140)"];
    }

    /*
     [msgJSON objectForKey:@"local_id"],
     [msgJSON objectForKey:@"rows"],
     [msgJSON objectForKey:@"columns"],
     [msgJSON objectForKey:@"bedstate"],
     [msgJSON objectForKey:@"timestamp"],
     [msgJSON objectForKey:@"name"]];
     */
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    [json setObject:local_id forKey:@"local_id"];
    [json setObject:rows forKey:@"rows"];
    [json setObject:columns forKey:@"columns"];
    [json setObject:timestamp forKey:@"timestamp"];
    [json setObject:name forKey:@"name"];
    
    NSLog(@"step 2");
    
    int cellCount = rows.integerValue * columns.integerValue;
    NSString *tempArrayStr = @"";
    NSString *tempStr = @"";
    NSString *key = @"";
    for(int i=0; i<cellCount; i++){
        key = [NSString stringWithFormat:@"cell%i", i];
        int strId = (int)[[bedJSON valueForKey:key] integerValue];
        tempStr = [NSString stringWithFormat:@"%i", strId];
        if(i == 0)tempArrayStr = [NSString stringWithFormat:@"%@", tempStr];
        else tempArrayStr = [NSString stringWithFormat:@"%@,%@", tempArrayStr, tempStr];
    }
    
    NSLog(@"step 3");
    
    tempArrayStr = [NSString stringWithFormat:@"{%@}",tempArrayStr];
    [json setObject:tempArrayStr forKey:@"bedstate"];
    [dbManager saveBedAutoSave:json];
    [appGlobals setCurrentBedState:json];
    
    NSLog(@"json: %@, %@, %@, %@, %@", local_id, rows, columns, timestamp, name);
    NSLog(@"Temp Array String: %i, %i, %@", rows.integerValue, columns.integerValue, tempArrayStr);
    return false;
}




@end


