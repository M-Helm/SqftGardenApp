//
//  BedDetailViewController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/13/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "BedDetailViewController.h"

@implementation BedDetailViewController

UIView *bedFrameView;

- (void)viewDidLoad {
    [super viewDidLoad];
    //setup views
    NSLog(@"Plant ID: %i", self.plantID);

}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    float xCo = self.view.bounds.size.width;
    //float yCo = self.view.bounds.size.height;
    bedFrameView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, xCo-20, xCo-20)];
    bedFrameView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bedFrameView.layer.borderWidth = 3;
    bedFrameView.layer.cornerRadius = 15;
    [self.view addSubview:bedFrameView];
}


@end
