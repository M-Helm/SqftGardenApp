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

- (id)initWithDimensions:(int)rows columns:(int)columns {
    self.bedRowCount = rows;
    self.bedColumnCount = columns;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if((int)self.bedRowCount < 1)self.bedRowCount = 3;
    if((int)self.bedColumnCount < 1)self.bedColumnCount = 5;
    self.bedCellCount = self.bedRowCount * self.bedColumnCount;
    NSLog(@"Cell Count %i", (int)self.bedCellCount);
    self.bedViewArray = [[NSMutableArray alloc] init];
    self.bedViewArray = [self buildBedViewArray];
    NSLog(@"ARRAY INIT Count %i", self.bedViewArray.count);
    [self initViews];

}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    bedFrameView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bedFrameView.layer.borderWidth = 3;
    bedFrameView.layer.cornerRadius = 15;
    [self.view addSubview:bedFrameView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)buildBedViewArray{
    NSMutableArray *bedArray = [[NSMutableArray alloc] init];
    int bedDimension = [self bedDimension];
    int rowNumber = 0;
    int columnNumber = 0;
    for(int i=0; i<self.bedRowCount; i++){
        NSLog(@"Outer array loop");
        while(columnNumber < self.bedColumnCount){
            BedView *bed = [[BedView alloc] initWithFrame:CGRectMake(1 + (bedDimension*columnNumber),
                            (bedDimension*rowNumber)+1, bedDimension, bedDimension)];
            [bedArray addObject:bed];
            NSLog(@"Inner array loop");
            //rowNumber++;
            columnNumber++;
        }
        columnNumber = 0;
        rowNumber++;
    }
    return bedArray;
}

-(void)initViews{
    NSLog(@"initViews");
    float xCo = self.view.bounds.size.width;
    int bedDimension = [self bedDimension];
    int i = self.bedColumnCount * bedDimension;
    bedFrameView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, xCo-20, i+10)];
    NSLog(@"array count %i", self.bedViewArray.count);
    for(int i = 0; i<self.bedViewArray.count;i++){
        [bedFrameView addSubview:[self.bedViewArray objectAtIndex:i]];
        NSLog(@"array add %i", i);
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

@end


