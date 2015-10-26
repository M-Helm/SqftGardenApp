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
ApplicationGlobals *appGlobals;
DBManager *dbManager;
CGFloat pointsPerDay;
CGFloat frostLineXCo;
CGFloat maxDays;

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
    pointsPerDay = [self calculateDateBounds];
    [self initViewGrid];
    
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}

-(CGFloat)calculateDateBounds{
    int min = 0;
    int max = 0;
    CGFloat ptsPerDay;
    min = abs(appGlobals.selectedPlant.startInsideDelta) - abs(appGlobals.selectedPlant.plantingDelta);
    if(abs(appGlobals.selectedPlant.startInsideDelta) < 1)min=0;
    if(abs(appGlobals.selectedPlant.plantingDelta) < 1)min = 0;
    max = appGlobals.selectedPlant.maturity;
    int days = max + abs(min);
    NSLog(@"min %i max %i days %i", min, max, days);
    ptsPerDay = (self.view.bounds.size.width -20) / days;
    NSLog(@"days %i pts %f", days, ptsPerDay);
    frostLineXCo = abs(min);
    if(frostLineXCo < 1)frostLineXCo = appGlobals.selectedPlant.plantingDelta;
    maxDays = days;
    return ptsPerDay;
}

-(void)initViewGrid{
    int margin = 5;
    float width = self.view.bounds.size.width;
    float height = self.view.bounds.size.height;
    
    UIView *plantIconView = [[UIView alloc] initWithFrame:CGRectMake(10, 30, 88, 88)];
    UIImageView *icon = [self getIcon];
    icon.frame = CGRectMake(margin, margin, plantIconView.frame.size.width-(margin*2), plantIconView.frame.size.height-(margin*2));
    plantIconView.clipsToBounds = YES;
    [plantIconView addSubview:icon];
    plantIconView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    plantIconView.layer.borderWidth = 0;
    plantIconView.layer.cornerRadius = 15;
    [self.view addSubview:plantIconView];
    [self.view addSubview:[self makeNameLabel:plantIconView withWidth:width andHeight:height andMargin:margin]];
    [self.view addSubview:[self makeScienceNameLabel:plantIconView withWidth:width andHeight:height andMargin:margin]];
    [self.view addSubview:[self makeMaturityLabel:plantIconView withWidth:width andHeight:height andMargin:margin]];
    [self.view addSubview:[self makePlantTextView:plantIconView withWidth:width andHeight:height]];
    [self makeCriticalDatesBar:plantIconView withWidth:width andHeight:height];
}
-(UILabel*)makeNameLabel:(UIView *)base withWidth:(int)width andHeight:(int)height andMargin:(int)margin{
    UILabel *plantNameLabel = [[UILabel alloc]
                               initWithFrame:CGRectMake(base.frame.size.width + (margin*3),
                                                        base.frame.origin.y+10,
                                                        width - base.frame.size.width-(margin*4),
                                                        25)];
    plantNameLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    plantNameLabel.layer.borderWidth = 0;
    plantNameLabel.layer.cornerRadius = 0;
    plantNameLabel.text = appGlobals.selectedPlant.plantName;
    [plantNameLabel setFont:[UIFont boldSystemFontOfSize:18]];
    plantNameLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    plantNameLabel.layer.borderWidth = 0;
    return plantNameLabel;

}

-(UILabel*)makeScienceNameLabel:(UIView *)base withWidth:(int)width andHeight:(int)height andMargin:(int)margin{
    UILabel *plantScienceNameLabel = [[UILabel alloc]
                                      initWithFrame:CGRectMake(base.frame.size.width + (margin*3),
                                                               base.frame.origin.y+35,
                                                               width - base.frame.size.width-(margin*4),
                                                               12)];
    plantScienceNameLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    plantScienceNameLabel.layer.borderWidth = 0;
    plantScienceNameLabel.layer.cornerRadius = 0;
    plantScienceNameLabel.text = appGlobals.selectedPlant.plantScientificName;
    [plantScienceNameLabel setFont:[UIFont italicSystemFontOfSize:12]];
    plantScienceNameLabel.textColor = [UIColor blackColor];
    return plantScienceNameLabel;
}

-(UILabel*)makeMaturityLabel:(UIView *)base withWidth:(int)width andHeight:(int)height andMargin:(int)margin{
    UILabel *plantMaturityLabel = [[UILabel alloc]
                                   initWithFrame:CGRectMake(base.frame.size.width + (margin*3),
                                                            base.frame.origin.y+50,
                                                            width - base.frame.size.width-(margin*4),
                                                            12)];
    plantMaturityLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    plantMaturityLabel.layer.borderWidth = 0;
    plantMaturityLabel.layer.cornerRadius = 15;
    NSString *maturityStr = [NSString stringWithFormat:@"Matures in about %i days", appGlobals.selectedPlant.maturity];
    plantMaturityLabel.text = maturityStr;
    [plantMaturityLabel setFont:[UIFont italicSystemFontOfSize:12]];
    plantMaturityLabel.textColor = [UIColor blackColor];
    return plantMaturityLabel;
}

-(void)makeCriticalDatesBar:(UIView *)base withWidth:(int)width andHeight:(int)height{
    UIView *criticalDateBar = [[UIView alloc]initWithFrame:CGRectMake(10,base.frame.size.height+30, width-20, 44)];
    //criticalDateBar.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:.5];
    
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd"];
    
    
    UIView *indoorsBar = [[UIView alloc]initWithFrame:CGRectMake(0,12,44,20)];
    indoorsBar.layer.borderColor = [UIColor blueColor].CGColor;
    indoorsBar.layer.borderWidth = 0;
    indoorsBar.layer.cornerRadius = 20/2;
    indoorsBar.backgroundColor = [UIColor whiteColor];
    //[criticalDateBar addSubview:indoorsBar];
    
    UIView *harvestBar = [[UIView alloc]initWithFrame:CGRectMake(5,12,width-30,20)];
    harvestBar.layer.borderColor = [UIColor orangeColor].CGColor;
    harvestBar.layer.borderWidth = 0;
    harvestBar.layer.cornerRadius = 20/2;
    harvestBar.backgroundColor = [UIColor whiteColor];
    harvestBar.clipsToBounds = YES;

    
    
    UIView *growingBar = [[UIView alloc]initWithFrame:CGRectMake(30,12,64,20)];
    growingBar.layer.borderColor = [UIColor greenColor].CGColor;
    growingBar.layer.borderWidth = 0;
    //growingBar.layer.cornerRadius = 20/2;
    //growingBar.backgroundColor = [UIColor whiteColor];
    //[criticalDateBar addSubview:growingBar];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.startPoint = CGPointMake(1,0);
    gradient.endPoint = CGPointMake(0,0);
    gradient.frame = harvestBar.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                             (id)[UIColor greenColor].CGColor,
                             (id)[UIColor greenColor].CGColor,
                             (id)[UIColor greenColor].CGColor,
                             (id)[UIColor whiteColor].CGColor,
                             (id)[UIColor lightGrayColor].CGColor,
                             nil];
    [harvestBar.layer insertSublayer:gradient atIndex:0];
    //harvestBar.alpha = .5;
    

    NSDate *plantingDate = [appGlobals.globalGardenModel.frostDate dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.plantingDelta];
    NSString *plantingStr = [NSString stringWithFormat:@"Plant: %@",[dateFormatter stringFromDate:plantingDate]];
    NSDate *maturityDate = [appGlobals.globalGardenModel.frostDate dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.maturity];
    maturityDate = [maturityDate dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.plantingDelta];
    NSString *maturityStr = [NSString stringWithFormat:@"Harvest: %@",[dateFormatter stringFromDate:maturityDate]];
    NSDate *startIndoorsDate = [appGlobals.globalGardenModel.frostDate dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.startInsideDelta];
    NSString *insideStr = [NSString stringWithFormat:@"Start Inside:%@",[dateFormatter stringFromDate:startIndoorsDate]];
    
    [criticalDateBar addSubview:harvestBar];
    [criticalDateBar addSubview:[self makeInsideLabel:insideStr isUp:YES]];
    [criticalDateBar addSubview:[self makePlantingLabel:plantingStr isUp:NO]];
    [criticalDateBar addSubview:[self makeHarvestLabel:maturityStr isUp:YES]];
    
    [self.view addSubview:criticalDateBar];
}
-(UILabel *)makeInsideLabel:(NSString *)text isUp:(bool)up{
    int upSpot = -3;
    if(!up)upSpot = 31;
    //int width = self.view.frame.size.width;
    CGFloat xAnchor = 0;
    if(abs(appGlobals.selectedPlant.startInsideDelta)<abs(appGlobals.selectedPlant.plantingDelta)){
        int delta = abs(appGlobals.selectedPlant.plantingDelta) - abs(appGlobals.selectedPlant.startInsideDelta);
        xAnchor = delta * pointsPerDay;
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xAnchor,upSpot,80,16)];
    label.layer.borderColor = [UIColor blackColor].CGColor;
    label.layer.borderWidth = 1;
    label.layer.cornerRadius = 7;
    //plantingLabel.numberOfLines = 2;
    label.backgroundColor = [UIColor clearColor];
    [label setFont: [UIFont systemFontOfSize:9]];
    [label setTextAlignment:NSTextAlignmentCenter];
    //label.clipsToBounds=YES;
    label.text = text;

    CAShapeLayer *indicatorLayer = [CAShapeLayer layer];
    [indicatorLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(-2, 21, 11, 11)] CGPath]];
    [indicatorLayer setStrokeColor:[[UIColor blackColor] CGColor]];
    [indicatorLayer setLineWidth:2];
    [indicatorLayer setFillColor:[[UIColor whiteColor] CGColor]];
    [label.layer addSublayer:indicatorLayer];
    if(!appGlobals.selectedPlant.startInside)label.alpha = 0;
    
    return label;
}

-(UILabel *)makeHarvestLabel:(NSString *)text isUp:(bool)up{
    if(pointsPerDay < 1)[self calculateDateBounds];
    int upSpot = -5;
    if(!up)upSpot = 31;
    //int width = self.view.frame.size.width;
    CGFloat xAnchor = maxDays*pointsPerDay;

    //NSLog(@"xanchor harvest label %i * %f = %f", appGlobals.selectedPlant.maturity, pointsPerDay, xAnchor);
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xAnchor-75,upSpot,80,16)];
    label.layer.borderColor = [UIColor blackColor].CGColor;
    label.layer.borderWidth = 1;
    label.layer.cornerRadius = 7;
    //plantingLabel.numberOfLines = 2;
    label.backgroundColor = [UIColor clearColor];
    [label setFont: [UIFont systemFontOfSize:9]];
    [label setTextAlignment:NSTextAlignmentCenter];
    //label.clipsToBounds=YES;
    label.text = text;
    
    CAShapeLayer *indicatorLayer = [CAShapeLayer layer];
    [indicatorLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(55, 21, 11, 11)] CGPath]];
    [indicatorLayer setStrokeColor:[[UIColor blackColor] CGColor]];
    [indicatorLayer setLineWidth:2];
    [indicatorLayer setFillColor:[[UIColor whiteColor] CGColor]];
    [label.layer addSublayer:indicatorLayer];
    
    
    
    return label;
}

-(UILabel *)makePlantingLabel:(NSString *)text isUp:(bool)up{
    int upSpot = 0;
    if(!up)upSpot = 31;
    CGFloat xAnchor = 0;
    if(abs(appGlobals.selectedPlant.startInsideDelta)>abs(appGlobals.selectedPlant.plantingDelta)){
        int delta = abs(appGlobals.selectedPlant.startInsideDelta) - abs(appGlobals.selectedPlant.plantingDelta);
        xAnchor = delta * pointsPerDay;
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xAnchor,upSpot,65,16)];
    label.layer.borderColor = [UIColor blackColor].CGColor;
    label.layer.borderWidth = 1;
    label.layer.cornerRadius = 7;
    //plantingLabel.numberOfLines = 2;
    label.backgroundColor = [UIColor clearColor];
    [label setFont: [UIFont systemFontOfSize:9]];
    [label setTextAlignment:NSTextAlignmentCenter];
    //label.clipsToBounds=YES;
    label.text = text;
    
    CAShapeLayer *indicatorLayer = [CAShapeLayer layer];
    [indicatorLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(7, -13, 11, 11)] CGPath]];
    [indicatorLayer setStrokeColor:[[UIColor blackColor] CGColor]];
    [indicatorLayer setLineWidth:2];
    [indicatorLayer setFillColor:[[UIColor whiteColor] CGColor]];
    [label.layer addSublayer:indicatorLayer];
    if(!appGlobals.selectedPlant.startSeed)label.alpha = 0;
    
    return label;
}

-(UITextView*)makePlantTextView:(UIView *)base withWidth:(int)width andHeight:(int)height{
    UITextView *plantDescriptionText = [[UITextView alloc]
                                        initWithFrame:CGRectMake(10,
                                                                 base.frame.size.height+74,
                                                                 width-20,
                                                                 height - (base.frame.size.height+90))];
    plantDescriptionText.layer.borderWidth = 0;
    plantDescriptionText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //plantDescriptionText.backgroundColor = [[UIColor greenColor]colorWithAlphaComponent:.05];
    plantDescriptionText.layer.cornerRadius = 15;
    [plantDescriptionText setFont:[UIFont systemFontOfSize:16]];

    plantDescriptionText.text = [self makeDescriptionText];
    plantDescriptionText.editable = NO;
    return plantDescriptionText;
}

-(UIImageView *) getIcon{
    UIImage *icon = [UIImage imageNamed:appGlobals.selectedPlant.iconResource];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    return imageView;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //have to call this here for the toolbar to work.
    [self makeToolbar];
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

-(NSString *)makeCriticalDatesText{
    NSString *text;
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd"];
    NSDate *startIndoorsDate = [appGlobals.globalGardenModel.frostDate dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.startInsideDelta];
    NSString *insideStr = [dateFormatter stringFromDate:startIndoorsDate];
    NSDate *transplantDate = [appGlobals.globalGardenModel.frostDate dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.transplantDelta];
    NSDate *maturityDate = [appGlobals.globalGardenModel.frostDate dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.maturity];
    maturityDate = [maturityDate dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.plantingDelta];
    NSString *maturityStr = [dateFormatter stringFromDate:maturityDate];
    NSDate *plantingDate = [appGlobals.globalGardenModel.frostDate dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.plantingDelta];
    NSString *plantingStr = [dateFormatter stringFromDate:plantingDate];
    NSString *transStr = [dateFormatter stringFromDate:transplantDate];
    

    if(appGlobals.selectedPlant.startInside && !appGlobals.selectedPlant.startSeed){
        text = [NSString stringWithFormat:@" Start inside %@ \r Harden & Transplant %@  \r Harvest %@ \r",insideStr, transStr, maturityStr];
    }
    if(appGlobals.selectedPlant.startSeed && !appGlobals.selectedPlant.startInside){
        text = [NSString stringWithFormat:@" Plant seeds %@ \r Harvest %@ \r",plantingStr, maturityStr];
    }
    if(appGlobals.selectedPlant.startSeed && appGlobals.selectedPlant.startInside){
        text = [NSString stringWithFormat:@" Start inside %@ \r Alternate Plant seeds %@ \r Transplant from inside %@ \r Harvest %@ \r",insideStr, plantingStr, transStr, maturityStr];
    }
    
    return text;
}

-(NSString *)makeDescriptionText{
    NSString *text = [self makeCriticalDatesText];
    //NSString *text = @"\r";
    NSString *str = @"";
    NSArray *json = appGlobals.selectedPlant.tipJsonArray;
    
    for(int i = 0; i<json.count; i++){
        str = json[i];
        if(str.length < 5)continue;
        str = [str substringToIndex:[str length] - 2];
        text = [NSString stringWithFormat:@"%@\r\u2609 %@ \r", text, str];
    }
    
    /*
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

    */
    return text;
}

@end
