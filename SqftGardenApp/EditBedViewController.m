//
//  MainViewController.h
//  SqftGardenApp
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//
#import "EditBedViewController.h"
#import "BedView.h"
#import "PlantIcon.h"
#import "PlantModel.h"
#import "SelectPlantView.h"
#import "ApplicationGlobals.h"
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
    appGlobals.selectedCell = -1;
    [self initViews];

}

- (void)viewDidLayoutSubviews{
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
    self.bedFrameView = [[UIView alloc] initWithFrame:CGRectMake(10, 100,
                    xCo+BED_LAYOUT_WIDTH_BUFFER, yCo+BED_LAYOUT_HEIGHT_BUFFER)];
    for(int i = 0; i<self.bedViewArray.count;i++){
        [self.bedFrameView addSubview:[self.bedViewArray objectAtIndex:i]];
    }
    selectPlantView = [[SelectPlantView alloc] initWithFrame:CGRectMake(10,
                                            yCo+BED_LAYOUT_HEIGHT_BUFFER + 110,
                                            xCo+BED_LAYOUT_WIDTH_BUFFER,
                                            bedDimension)];
    for(int i = 0; i<self.selectPlantArray.count;i++){
        [selectPlantView addSubview:[self.selectPlantArray objectAtIndex:i]];
    }
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
    for(int i = 0; i<self.selectPlantArray.count; i++){
        //UIView *box = [self.selectPlantArray objectAtIndex:i];
        //box.backgroundColor = [UIColor whiteColor];
        //box.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    //recognizer.view.backgroundColor = [UIColor lightGrayColor];
    //recognizer.view.layer.borderColor = [UIColor darkGrayColor].CGColor;
    if(appGlobals.selectedCell > -1){
        BedView *bed = [self.bedViewArray objectAtIndex: appGlobals.selectedCell];
        BedView *plant = (BedView*)recognizer.view;
        appGlobals.selectedPlant = plant.index;
        UIImage *icon = [self generateIcon:plant.index];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
        imageView.frame = bed.bounds;
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
            //rowNumber++;
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
    //UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];

    for(int i=0; i<3; i++){
        PlantIcon *plantIcon = [[PlantIcon alloc] initWithFrame:CGRectMake(6 + (frameDimension*i),
                            2, frameDimension, frameDimension)];
        UIImage *icon = [self generateIcon:i];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
        plantIcon.layer.cornerRadius = frameDimension/2;
        plantIcon.layer.borderWidth = 2;
        plantIcon.layer.borderColor = [UIColor greenColor].CGColor;
        imageView.frame = plantIcon.bounds;
        plantIcon.index = i;
        [plantIcon addSubview:imageView];
        [selectArray addObject:plantIcon];
    }
    return selectArray;
}
- (UIImage *)generateIcon:(int)iconNumber{
    UIImage *icon = [UIImage imageNamed:@"ic_cabbage_78px.png"];
    switch (iconNumber) {
        case 0:
            return icon;
            break;
        case 1:
            icon = [UIImage imageNamed:@"ic_carrot_78px.png"];
            return icon;
            break;
        case 2:
            icon = [UIImage imageNamed:@"ic_flower_78px.png"];
            return icon;
        default:
            return icon;
            break;
    }
}

@end


