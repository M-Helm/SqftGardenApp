//
//  BedDetailViewController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/13/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "BedDetailViewController.h"
#import "BedView.h"
#import "ApplicationGlobals.h"
#import "PlantIconView.h"
#import "SelectPlantView.h"

@implementation BedDetailViewController
const int BED_DETAIL_LAYOUT_HEIGHT_BUFFER = 3;
const int BED_DETAIL_LAYOUT_WIDTH_BUFFER = -17;
ApplicationGlobals *appGlobals;


- (void)viewDidLoad {
    [super viewDidLoad];
    //appGlobals = [[ApplicationGlobals alloc] init];
    
    //setup views
    if((int)self.bedRowCount < 1)self.bedRowCount = 3;
    if((int)self.bedColumnCount < 1)self.bedColumnCount = 3;
    self.bedCellCount = self.bedRowCount * self.bedColumnCount;
    self.bedViewArray = [self buildBedViewArray];
    self.selectPlantArray = [self buildPlantSelectArray];
    NSLog(@"Cell ID: %i", appGlobals.selectedCell);
    [self initGrids];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.bedFrameView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.bedFrameView.layer.borderWidth = 3;
    self.bedFrameView.layer.cornerRadius = 15;
    
    
    for(int i =0; i<self.selectPlantArray.count; i++){
        UIView *box = [self.selectPlantArray objectAtIndex:i];
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handlePlantSingleTap:)];
        [box addGestureRecognizer:singleFingerTap];
    }
    [self.view addSubview:self.bedFrameView];
    [self.view addSubview:self.selectPlantView];
}

- (void)handleBedSingleTap:(UITapGestureRecognizer *)recognizer {
    recognizer.view.backgroundColor = [UIColor lightGrayColor];
    recognizer.view.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (NSMutableArray *)buildBedViewArray{
    NSMutableArray *bedArray = [[NSMutableArray alloc] init];
    int bedDimension = [self bedDimension];
    int rowNumber = 0;
    int columnNumber = 0;
    int cell = 1;
    for(int i=0; i<self.bedRowCount; i++){
        while(columnNumber < self.bedColumnCount){
            BedView *bed = [[BedView alloc] initWithFrame:CGRectMake(1+(bedDimension*columnNumber),
                                        (bedDimension*rowNumber)+1, bedDimension, bedDimension)];
            bed.index = cell-1;
            bed.layer.borderWidth = 0;
            UIImageView *icon = [self setIcon];
            icon.frame = CGRectMake(bed.bounds.size.width/4,
                                    bed.bounds.size.height/4,
                                    bed.bounds.size.width/2,
                                    bed.bounds.size.height/2);
            if(cell % 2){
                [bed addSubview:icon];
            }
            else {
                //bed.layer.backgroundColor  = [UIColor lightGrayColor].CGColor;
            }
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
        PlantIconView *plantIcon = [[PlantIconView alloc]
                                    initWithFrame:CGRectMake(6 + (frameDimension*i),2, frameDimension, frameDimension) : i+1];
        //PlantModel *plant = [[PlantModel alloc] initWithId:i+1];
        UIImage *icon = [UIImage imageNamed:plantIcon.iconResource];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
        plantIcon.layer.cornerRadius = frameDimension/2;
        plantIcon.layer.borderWidth = 2;
        plantIcon.layer.borderColor = [UIColor greenColor].CGColor;
        imageView.frame = CGRectMake(plantIcon.bounds.size.width/4,
                                     plantIcon.bounds.size.height/4,
                                     plantIcon.bounds.size.width/2,
                                     plantIcon.bounds.size.height/2);
        plantIcon.position = i;
        plantIcon.layer.borderWidth = 0;
        [plantIcon addSubview:imageView];
        [selectArray addObject:plantIcon];
    }
    return selectArray;
}

-(void)initGrids{
    int bedDimension = [self bedDimension];
    float xCo = self.view.bounds.size.width;
    int yCo = self.bedRowCount * bedDimension;
    self.bedFrameView = [[UIView alloc] initWithFrame:CGRectMake(10, 100,
                                                                 xCo+BED_DETAIL_LAYOUT_WIDTH_BUFFER, yCo+BED_DETAIL_LAYOUT_HEIGHT_BUFFER)];
    for(int i = 0; i<self.bedViewArray.count;i++){
        [self.bedFrameView addSubview:[self.bedViewArray objectAtIndex:i]];
    }
    self.selectPlantView = [[SelectPlantView alloc] initWithFrame:CGRectMake(10,
                                                                        yCo+BED_DETAIL_LAYOUT_HEIGHT_BUFFER + 110,
                                                                        xCo+BED_DETAIL_LAYOUT_WIDTH_BUFFER,
                                                                        bedDimension)];
    for(int i = 0; i<self.selectPlantArray.count;i++){
        [self.selectPlantView addSubview:[self.selectPlantArray objectAtIndex:i]];
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

-(UIImageView *) setIcon{
    PlantIconView *plant = appGlobals.selectedPlant;
    UIImage *icon = [UIImage imageNamed:plant.iconResource];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    return imageView;
}

- (void)handlePlantSingleTap:(UITapGestureRecognizer *)recognizer {
    PlantIconView *plant = (PlantIconView*)recognizer.view;
    appGlobals.selectedPlant = plant;
    //PlantModel *plant = [[PlantModel alloc] initWithId:bed.index];
    UIImage *icon = [UIImage imageNamed:plant.iconResource];
    for(int i=0;i<self.bedViewArray.count;i++){
        if(i % 2){
            BedView *cell = [self.bedViewArray objectAtIndex:i];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
            imageView.frame = CGRectMake(cell.bounds.size.width/4,
                                         cell.bounds.size.height/4,
                                         cell.bounds.size.width/2,
                                         cell.bounds.size.height/2);
            [[cell subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [cell addSubview:imageView];
        }
    }
}

@end
