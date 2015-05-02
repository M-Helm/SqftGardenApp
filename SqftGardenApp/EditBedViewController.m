//
//  MainViewController.h
//  SqftGardenApp
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//
#import "EditBedViewController.h"


#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


@interface EditBedViewController ()

@end

@implementation EditBedViewController



UIView *bedFrameView;

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)initViews{
    float xCo = self.view.bounds.size.width;
    int bedDimension = (int)(self.view.bounds.size.width - 20) / (int)self.bedRowCount;
    bedFrameView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, xCo-20, 115)];
}



@end


