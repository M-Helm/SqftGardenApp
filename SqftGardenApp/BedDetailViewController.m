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
    appGlobals = [ApplicationGlobals getSharedGlobals];
    
    //setup views
    //self.navigationItem.title = appGlobals.appTitle;
    self.navigationController.navigationItem.backBarButtonItem.title = @"Back";
    if((int)self.bedRowCount < 1)self.bedRowCount = 3;
    if((int)self.bedColumnCount < 1)self.bedColumnCount = 3;
    self.bedCellCount = self.bedRowCount * self.bedColumnCount;
    //NSLog(@"Cell ID: %i", appGlobals.selectedCell);
    [self initViewGrid];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.bedFrameView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.bedFrameView.layer.borderWidth = 0;
    self.bedFrameView.layer.cornerRadius = 15;
    [self.view addSubview:self.bedFrameView];
}


-(void)initViewGrid{
    float xCo = self.view.bounds.size.width;
    int bedDimension = (xCo/2)/self.bedColumnCount - 3;
    int yCo = self.bedRowCount * bedDimension;
    self.bedFrameView = [[UIView alloc] initWithFrame:CGRectMake(10, 100,
                                                                 (xCo/2)+BED_DETAIL_LAYOUT_WIDTH_BUFFER, yCo+BED_DETAIL_LAYOUT_HEIGHT_BUFFER)];
    UIImageView *icon = [self getIcon];
    icon.frame = CGRectMake(5, 5, self.bedFrameView.frame.size.width-45, self.bedFrameView.frame.size.height-45);
    self.bedFrameView.clipsToBounds = YES;
    [self.bedFrameView addSubview:icon];
    
    
    UILabel *plantNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bedFrameView.frame.size.width, 100, xCo/2, 25)];
    plantNameLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    plantNameLabel.layer.borderWidth = 0;
    plantNameLabel.layer.cornerRadius = 0;
    plantNameLabel.text = appGlobals.selectedPlant.plantName;
    [plantNameLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [self.view addSubview:plantNameLabel];
    
    UILabel *plantScienceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bedFrameView.frame.size.width, 100 + plantNameLabel.layer.bounds.size.height, (xCo/2), 12)];
    plantScienceNameLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    plantScienceNameLabel.layer.borderWidth = 0;
    plantScienceNameLabel.layer.cornerRadius = 15;
    plantScienceNameLabel.text = appGlobals.selectedPlant.plantScientificName;
    [plantScienceNameLabel setFont:[UIFont italicSystemFontOfSize:12]];
    plantScienceNameLabel.textColor = [UIColor blackColor];
    [self.view addSubview:plantScienceNameLabel];
    
    UILabel *plantMaturityLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bedFrameView.frame.size.width, 100 + (plantNameLabel.layer.bounds.size.height + 12), (xCo/2), 12)];
    plantMaturityLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    plantMaturityLabel.layer.borderWidth = 0;
    plantMaturityLabel.layer.cornerRadius = 15;
    NSString *maturityStr = [NSString stringWithFormat:@"Matures in about %i days", appGlobals.selectedPlant.maturity];
    plantMaturityLabel.text = maturityStr;
    [plantMaturityLabel setFont:[UIFont italicSystemFontOfSize:12]];
    plantMaturityLabel.textColor = [UIColor blackColor];
    [self.view addSubview:plantMaturityLabel];
    
    //UIImageView *plantPhotoView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bedFrameView.frame.size.width+25,  100 + plantNameLabel.layer.bounds.size.height + 24, (xCo/2)-25, (xCo/2)-25)];
    UIImage *photo = [UIImage imageNamed:appGlobals.selectedPlant.photoResource];
    UIImageView *photoImageView = [[UIImageView alloc] initWithImage:photo];
    [photoImageView setFrame: CGRectMake(self.bedFrameView.frame.size.width+15,  100 + plantNameLabel.layer.bounds.size.height + 24, (xCo/2)-25, (xCo/2)-55)];
    photoImageView.layer.cornerRadius = 15;
    photoImageView.clipsToBounds = YES;
    
    [self.view addSubview:photoImageView];
    
    
    UITextView *plantYieldText = [[UITextView alloc] initWithFrame:CGRectMake(10, yCo+BED_DETAIL_LAYOUT_HEIGHT_BUFFER + 102, xCo - 20, 75)];
    plantYieldText.layer.borderWidth = 0;
    plantYieldText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    plantYieldText.layer.cornerRadius = 15;
    [plantYieldText setFont:[UIFont boldSystemFontOfSize:14]];
    NSString *plural = @"has";
    if([appGlobals.selectedPlant.plantName hasSuffix:@"s"])plural = @"have";
    
    NSString *yieldStr = [NSString stringWithFormat:@"%@ %@ an expected yield of about %@ under good conditions. The recomended number of plants per square foot is %i.", appGlobals.selectedPlant.plantName, plural, appGlobals.selectedPlant.plantYield, appGlobals.selectedPlant.population];
    plantYieldText.text = yieldStr;
    plantYieldText.editable = NO;
    [self.view addSubview:plantYieldText];
    
    
    UITextView *plantDescriptionText = [[UITextView alloc] initWithFrame:CGRectMake(10, yCo+BED_DETAIL_LAYOUT_HEIGHT_BUFFER + 177, xCo - 20, self.view.bounds.size.height - (yCo+BED_DETAIL_LAYOUT_HEIGHT_BUFFER + 190))];
    plantDescriptionText.layer.borderWidth = 0;
    plantDescriptionText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    plantDescriptionText.layer.cornerRadius = 15;
    [plantDescriptionText setFont:[UIFont systemFontOfSize:12]];
    plantDescriptionText.text = appGlobals.selectedPlant.plantDescription;
    plantDescriptionText.editable = NO;
    [self.view addSubview:plantDescriptionText];
}


-(UIImageView *) getIcon{
    UIImage *icon = [UIImage imageNamed:appGlobals.selectedPlant.iconResource];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    return imageView;
}


@end
