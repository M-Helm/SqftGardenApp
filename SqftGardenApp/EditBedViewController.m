//
//  MainViewController.h
//  SqftGardenApp
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//
#import "EditBedViewController.h"
#import "BedView.h"
#import "PlantIconView.h"
#import "PlantModel.h"
#import "SelectPlantView.h"
#import "ApplicationGlobals.h"
#import "DBManager.h"
//#import "MainNavigationController.h"
//#import "BedDetailViewController.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface EditBedViewController ()

@end

@implementation EditBedViewController
const int BED_LAYOUT_HEIGHT_BUFFER = 3;
const int BED_LAYOUT_WIDTH_BUFFER = -17;


//UIView *bedFrameView;
UIView *selectPlantView;
ApplicationGlobals *appGlobals;
DBManager *dbManager;

- (id)initWithDimensions:(int)rows columns:(int)columns {
    self.bedRowCount = rows;
    self.bedColumnCount = columns;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if((int)self.bedRowCount < 1)self.bedRowCount = 3;
    if((int)self.bedColumnCount < 1)self.bedColumnCount = 3;
    self.bedCellCount = self.bedRowCount * self.bedColumnCount;
    self.bedViewArray = [self buildBedViewArray];
    self.selectPlantArray = [self buildPlantSelectArray];
    appGlobals = [[ApplicationGlobals alloc] init];
    dbManager = [DBManager getSharedDBManager];
    appGlobals.selectedCell = -1;
    [self initViews];
}

- (void)viewDidLayoutSubviews{
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
    for(int i =0; i<self.selectPlantArray.count; i++){
        UIView *box = [self.selectPlantArray objectAtIndex:i];
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handlePlantSingleTap:)];
        [box addGestureRecognizer:singleFingerTap];
    }
    
    [self.view addSubview:self.bedFrameView];
    [self.view addSubview:selectPlantView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initViews{
    int bedDimension = [self bedDimension];
    float xCo = self.view.bounds.size.width;
    int yCo = self.bedRowCount * bedDimension;
    //NSMutableArray *selectPlantArray = [self buildPlantSelectArray];
    self.bedFrameView = [[UIView alloc] initWithFrame:CGRectMake(10, 100,
                    xCo+BED_LAYOUT_WIDTH_BUFFER, yCo+BED_LAYOUT_HEIGHT_BUFFER)];
    for(int i = 0; i<self.bedViewArray.count;i++){
        [self.bedFrameView addSubview:[self.bedViewArray objectAtIndex:i]];
    }
    selectPlantView = [[SelectPlantView alloc] initWithFrame:CGRectMake(10,
                                            yCo+BED_LAYOUT_HEIGHT_BUFFER + 125,
                                            xCo+BED_LAYOUT_WIDTH_BUFFER,
                                            bedDimension)];
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
    return bedDimension;
}

- (void)handleBedSingleTap:(UITapGestureRecognizer *)recognizer {
    //CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    for(int i = 0; i<self.bedViewArray.count; i++){
        UIView *bed = [self.bedViewArray objectAtIndex:i];
        bed.backgroundColor = [UIColor whiteColor];
        bed.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    //NSLog(@"View Id %@", recognizer.view.description);
    //recognizer.view.backgroundColor = [UIColor lightGrayColor];
    recognizer.view.layer.borderColor = [UIColor darkGrayColor].CGColor;
    BedView *bd = (BedView*)recognizer.view;
    appGlobals.selectedCell = bd.index;
}
- (void)handlePlantSingleTap:(UITapGestureRecognizer *)recognizer {
    if(appGlobals.selectedCell > -1){
        BedView *bed = [self.bedViewArray objectAtIndex: appGlobals.selectedCell];
        BedView *plant = (BedView*)recognizer.view;
        appGlobals.selectedPlant = plant.index;
        UIImage *icon = [self generateIcon:plant.index];
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

- (NSMutableArray *)buildBedViewArray{
    NSMutableArray *bedArray = [[NSMutableArray alloc] init];
    int bedDimension = [self bedDimension];
    int rowNumber = 0;
    int columnNumber = 0;
    int cell = 0;
    for(int i=0; i<self.bedRowCount; i++){
        while(columnNumber < self.bedColumnCount){
            BedView *bed = [[BedView alloc] initWithFrame:CGRectMake(1 + (bedDimension*columnNumber),
                            (bedDimension*rowNumber)+1, bedDimension, bedDimension)];
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
    for(int i=0; i<9; i++){
        PlantIconView *plantIcon = [[PlantIconView alloc] initWithFrame:CGRectMake(6 + (frameDimension*i),
                            2, frameDimension, frameDimension)];
        UIImage *icon = [self generateIcon:i];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
        plantIcon.layer.borderWidth = 0;
        imageView.frame = CGRectMake(plantIcon.bounds.size.width/4,
                                     plantIcon.bounds.size.height/4,
                                     plantIcon.bounds.size.width/2,
                                     plantIcon.bounds.size.height/2);
        plantIcon.index = i;
        [plantIcon addSubview:imageView];
        [selectArray addObject:plantIcon];
    }
    return selectArray;
}
- (UIImage *)generateIcon:(int)iconNumber{
    UIImage *icon = [UIImage imageNamed:@"ic_fruit_strawberry_256.png"];
    switch (iconNumber) {
        case 0:
            icon = [UIImage imageNamed:@"ic_bean_256.png"];
            return icon;
            break;
        case 1:
            icon = [UIImage imageNamed:@"ic_vegetable_carrot_256.png"];
            return icon;
            break;
        case 2:
            icon = [UIImage imageNamed:@"ic_vegetable_radish_256.png"];
            return icon;
        case 3:
            icon = [UIImage imageNamed:@"ic_vegetable_capsicum_256.png"];
            return icon;
        case 4:
            icon = [UIImage imageNamed:@"ic_vegetable_chilly_256.png"];
            return icon;
        case 5:
            icon = [UIImage imageNamed:@"ic_vegetable_onion_256.png"];
            return icon;
        case 6:
            icon = [UIImage imageNamed:@"ic_vegetable_tomato_01_256.png"];
            return icon;
        case 7:
            icon = [UIImage imageNamed:@"ic_vegetable_brinjal_256.png"];
            return icon;
        case 8:
            icon = [UIImage imageNamed:@"ic_cereal_wheat_256.png"];
            return icon;
        default:
            return icon;
            break;
    }
}

@end


