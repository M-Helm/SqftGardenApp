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
#import "GrowToolbarView.h"
#import "DBManager.h"

@implementation BedDetailViewController
//const int BED_DETAIL_LAYOUT_HEIGHT_BUFFER = 3;
//const int BED_DETAIL_LAYOUT_WIDTH_BUFFER = -17;
ApplicationGlobals *appGlobals;
DBManager *dbManager;


- (void)viewDidLoad {
    [super viewDidLoad];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    dbManager = [DBManager getSharedDBManager];
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
}

-(void)initViewGrid{
    float width = self.view.bounds.size.width;
    int margin = 5;
    float height = self.view.bounds.size.height;
    //int bedDimension = (width/2)/self.bedColumnCount - 3;
    //int yCo = self.bedRowCount * bedDimension;
    
    UIView *plantIconView = [[UIView alloc] initWithFrame:CGRectMake(10, 30, 88, 88)];
    UIImageView *icon = [self getIcon];
    icon.frame = CGRectMake(margin, margin, plantIconView.frame.size.width-(margin*2), plantIconView.frame.size.height-(margin*2));
    plantIconView.clipsToBounds = YES;
    [plantIconView addSubview:icon];
    
    plantIconView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    plantIconView.layer.borderWidth = 0;
    plantIconView.layer.cornerRadius = 15;
    [self.view addSubview:plantIconView];
    
    
    UILabel *plantNameLabel = [[UILabel alloc]
                               initWithFrame:CGRectMake(plantIconView.frame.size.width + (margin*3),
                                                        plantIconView.frame.origin.y+10,
                                                        width - plantIconView.frame.size.width-(margin*4),
                                                        25)];
    plantNameLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    plantNameLabel.layer.borderWidth = 0;
    plantNameLabel.layer.cornerRadius = 0;
    plantNameLabel.text = appGlobals.selectedPlant.plantName;
    [plantNameLabel setFont:[UIFont boldSystemFontOfSize:18]];
    plantNameLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    plantNameLabel.layer.borderWidth = 0;
    [self.view addSubview:plantNameLabel];
    
    UILabel *plantScienceNameLabel = [[UILabel alloc]
                                      initWithFrame:CGRectMake(plantIconView.frame.size.width + (margin*3),
                                                            plantIconView.frame.origin.y+35,
                                                            width - plantIconView.frame.size.width-(margin*4),
                                                            12)];
    plantScienceNameLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    plantScienceNameLabel.layer.borderWidth = 0;
    plantScienceNameLabel.layer.cornerRadius = 0;
    plantScienceNameLabel.text = appGlobals.selectedPlant.plantScientificName;
    [plantScienceNameLabel setFont:[UIFont italicSystemFontOfSize:12]];
    plantScienceNameLabel.textColor = [UIColor blackColor];
    [self.view addSubview:plantScienceNameLabel];
    
    UILabel *plantMaturityLabel = [[UILabel alloc]
                                   initWithFrame:CGRectMake(plantIconView.frame.size.width + (margin*3),
                                                            plantIconView.frame.origin.y+50,
                                                            width - plantIconView.frame.size.width-(margin*4),
                                                            12)];
    plantMaturityLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    plantMaturityLabel.layer.borderWidth = 0;
    plantMaturityLabel.layer.cornerRadius = 15;
    NSString *maturityStr = [NSString stringWithFormat:@"Matures in about %i days", appGlobals.selectedPlant.maturity];
    plantMaturityLabel.text = maturityStr;
    [plantMaturityLabel setFont:[UIFont italicSystemFontOfSize:12]];
    plantMaturityLabel.textColor = [UIColor blackColor];
    [self.view addSubview:plantMaturityLabel];
    
    
    
    UITextView *plantDescriptionText = [[UITextView alloc]
                                        initWithFrame:CGRectMake(10,
                                                                plantIconView.frame.size.height+30,
                                                                width-20,
                                                                height - (plantIconView.frame.size.height+90))];
    plantDescriptionText.layer.borderWidth = 0;
    plantDescriptionText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //plantDescriptionText.backgroundColor = [[UIColor greenColor]colorWithAlphaComponent:.05];
    plantDescriptionText.layer.cornerRadius = 15;
    [plantDescriptionText setFont:[UIFont systemFontOfSize:16]];
    plantDescriptionText.text = [self makeDescriptionText];
    plantDescriptionText.editable = NO;
    [self.view addSubview:plantDescriptionText];
    
    [self makeToolbar];
}

-(UIImageView *) getIcon{
    UIImage *icon = [UIImage imageNamed:appGlobals.selectedPlant.iconResource];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    return imageView;
}

-(void)makeToolbar{
    float toolBarYOrigin = self.view.frame.size.height-44;
    //if(!self.toolBarIsOpen)toolBarYOrigin = self.view.frame.size.height;
    
    GrowToolBarView *toolBar = [[GrowToolBarView alloc] initWithFrame:CGRectMake(0,toolBarYOrigin,self.view.frame.size.width,44) andViewController:self];
    [toolBar setToolBarIsPinned:YES];
    [self.view addSubview:toolBar];
    [toolBar enableBackButton:YES];
    [toolBar enableMenuButton:NO];
    [toolBar enableDateButton:NO];
    [toolBar enableSaveButton:NO];
    [toolBar enableIsoButton:NO];
}

-(NSString *)makeDescriptionText{
    NSString* text = [NSString stringWithFormat:@"\r\u2609 %@ %@ %@ %@ %@ %@ %@ %@ %@",
                      appGlobals.selectedPlant.tip0,
                      @"\r\r\u2609",
                      appGlobals.selectedPlant.tip1,
                      @"\r\r\u2609",
                      appGlobals.selectedPlant.tip2,
                      @"\r\r\u2609",
                      appGlobals.selectedPlant.tip3,
                      @"\r\r\u2609",
                      appGlobals.selectedPlant.tip4
                      ];

    
    return text;
}

@end
