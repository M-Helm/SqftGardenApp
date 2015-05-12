//
//  MainViewController.h
//  SqftGardenApp
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//
#import "EditBedViewController.h"
#import "BedView.h"
#import "PlantModel.h"
#import "SelectPlantView.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)



@interface EditBedViewController ()

@end

@implementation EditBedViewController
const int BED_LAYOUT_HEIGHT_BUFFER = 3;
const int BED_LAYOUT_WIDTH_BUFFER = -17;


UIView *bedFrameView;
UIView *selectPlantView;

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
    
    [self initViews];
    
    for(int i =0; i<self.bedViewArray.count; i++){
        UIView *bed = [self.bedViewArray objectAtIndex:i];
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [bed addGestureRecognizer:singleFingerTap];
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    bedFrameView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bedFrameView.layer.borderWidth = 3;
    bedFrameView.layer.cornerRadius = 15;
    [self.view addSubview:bedFrameView];
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
    bedFrameView = [[UIView alloc] initWithFrame:CGRectMake(10, 100,
                    xCo+BED_LAYOUT_WIDTH_BUFFER, yCo+BED_LAYOUT_HEIGHT_BUFFER)];
    for(int i = 0; i<self.bedViewArray.count;i++){
        [bedFrameView addSubview:[self.bedViewArray objectAtIndex:i]];
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

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    //CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    for(int i = 0; i<self.bedViewArray.count; i++){
        UIView *bed = [self.bedViewArray objectAtIndex:i];
        bed.backgroundColor = [UIColor whiteColor];
        bed.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    recognizer.view.backgroundColor = [UIColor lightGrayColor];
    recognizer.view.layer.borderColor = [UIColor darkGrayColor].CGColor;
}

- (NSMutableArray *)buildBedViewArray{
    NSMutableArray *bedArray = [[NSMutableArray alloc] init];
    int bedDimension = [self bedDimension];
    int rowNumber = 0;
    int columnNumber = 0;
    for(int i=0; i<self.bedRowCount; i++){
        while(columnNumber < self.bedColumnCount){
            BedView *bed = [[BedView alloc] initWithFrame:CGRectMake(1 + (bedDimension*columnNumber),
                            (bedDimension*rowNumber)+1, bedDimension, bedDimension)];
            [bedArray addObject:bed];
            //rowNumber++;
            columnNumber++;
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
        BedView *bed = [[BedView alloc] initWithFrame:CGRectMake(6 + (frameDimension*i),
                            2, frameDimension, frameDimension)];
        UIImage *icon = [self generateIcon:i];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
        bed.layer.cornerRadius = frameDimension/2;
        bed.layer.borderWidth = 2;
        bed.layer.borderColor = [UIColor greenColor].CGColor;
        imageView.frame = bed.bounds;
        [bed addSubview:imageView];
        
        [selectArray addObject:bed];
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


