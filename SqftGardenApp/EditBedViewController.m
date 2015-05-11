//
//  MainViewController.h
//  SqftGardenApp
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//
#import "EditBedViewController.h"
#import "BedView.h"


#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


@interface EditBedViewController ()

@end

@implementation EditBedViewController



UIView *bedFrameView;

UIView *bed0;
UIView *bed1;
UIView *bed2;

UIView *bed3;
UIView *bed4;
UIView *bed5;

UIView *bed6;
UIView *bed7;
UIView *bed8;


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
    NSLog(@"Cell Count %i", (int)self.bedCellCount);
    self.bedViewArray = [[NSMutableArray alloc] init];
    self.bedViewArray = [self buildBedViewArray];
    NSLog(@"ARRAY INIT Count %i", self.bedViewArray.count);
    [self initViews];

}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    //float xCo = self.view.bounds.size.width;
    //float yCo = self.view.bounds.size.height;
    bedFrameView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bedFrameView.layer.borderWidth = 3;
    bedFrameView.layer.cornerRadius = 15;
    [self.view addSubview:bedFrameView];
    
    /*
    bed0.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bed0.layer.borderWidth = 3;
    bed0.layer.cornerRadius = 15;
    bed1.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bed1.layer.borderWidth = 3;
    bed1.layer.cornerRadius = 15;
    bed2.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bed2.layer.borderWidth = 3;
    bed2.layer.cornerRadius = 15;
    bed3.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bed3.layer.borderWidth = 3;
    bed3.layer.cornerRadius = 15;
    bed4.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bed4.layer.borderWidth = 3;
    bed4.layer.cornerRadius = 15;
    bed5.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bed5.layer.borderWidth = 3;
    bed5.layer.cornerRadius = 15;
    bed6.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bed6.layer.borderWidth = 3;
    bed6.layer.cornerRadius = 15;
    bed7.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bed7.layer.borderWidth = 3;
    bed7.layer.cornerRadius = 15;
    bed8.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bed8.layer.borderWidth = 3;
    bed8.layer.cornerRadius = 15;
    */
    [self.view addSubview:bedFrameView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)buildBedViewArray{
    NSMutableArray *bedArray = [[NSMutableArray alloc] init];
    int bedDimension = (int)(self.view.bounds.size.width - 20) / (int)self.bedRowCount;
    int rowNumber = 0;
    int columnNumber = 0;
    for(int i=0; i<self.bedCellCount; i++){
        NSLog(@"Outer array loop");
        while(rowNumber < self.bedRowCount){
            BedView *bed = [[BedView alloc] initWithFrame:CGRectMake(1 + (bedDimension*rowNumber),
                            (bedDimension*columnNumber)+1, bedDimension, bedDimension)];
            [bedArray addObject:bed];
            NSLog(@"Inner array loop");
            rowNumber++;
        }
        rowNumber = 0;
        columnNumber++;
    }
    return bedArray;
}

-(void)initViewsOLD{
    float xCo = self.view.bounds.size.width;
    //int bedDimension = (int)(self.view.bounds.size.width - 20);
    int bedDimension = (int)(self.view.bounds.size.width - 20) / (int)self.bedRowCount;
    int i = self.bedColumnCount * bedDimension;
    bedFrameView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, xCo-20, i+10)];
    
    bed0 = [[UIView alloc] initWithFrame:CGRectMake(1, 1, bedDimension, bedDimension)];
    bed1 = [[UIView alloc] initWithFrame:CGRectMake(bedDimension+1, 1, bedDimension, bedDimension)];
    bed2 = [[UIView alloc] initWithFrame:CGRectMake((bedDimension*2)+1, 1, bedDimension, bedDimension)];
    
    bed3 = [[UIView alloc] initWithFrame:CGRectMake(1, bedDimension+1, (bedDimension * 1) +1, bedDimension)];
    bed4 = [[UIView alloc] initWithFrame:CGRectMake(bedDimension+1,(bedDimension * 1)+1, bedDimension, bedDimension)];
    bed5 = [[UIView alloc] initWithFrame:CGRectMake((bedDimension * 2)+1, (bedDimension * 1)+1, bedDimension, bedDimension)];

    bed6 = [[UIView alloc] initWithFrame:CGRectMake(1, (bedDimension * 2)+1, bedDimension, bedDimension)];
    bed7 = [[UIView alloc] initWithFrame:CGRectMake(bedDimension+1,(bedDimension * 2)+1, bedDimension, bedDimension)];
    bed8 = [[UIView alloc] initWithFrame:CGRectMake((bedDimension * 2)+1, (bedDimension * 2)+1, bedDimension, bedDimension)];
    
    [bedFrameView addSubview:bed0];
    [bedFrameView addSubview:bed1];
    [bedFrameView addSubview:bed2];
    [bedFrameView addSubview:bed3];
    [bedFrameView addSubview:bed4];
    [bedFrameView addSubview:bed5];
    [bedFrameView addSubview:bed6];
    [bedFrameView addSubview:bed7];
    [bedFrameView addSubview:bed8];
}
-(void)initViews{
    NSLog(@"initViews");
    float xCo = self.view.bounds.size.width;
    int bedDimension = (int)(self.view.bounds.size.width - 20) / (int)self.bedRowCount;
    int i = self.bedColumnCount * bedDimension;
    bedFrameView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, xCo-20, i+10)];
    NSLog(@"array count %i", self.bedViewArray.count);
    for(int i = 0; i<self.bedViewArray.count;i++){
        [bedFrameView addSubview:[self.bedViewArray objectAtIndex:i]];
        NSLog(@"array add %i", i);
    }
}



@end


