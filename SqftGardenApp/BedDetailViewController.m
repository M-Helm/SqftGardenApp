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
#import "PlantModel.h"
#import "SelectPlantView.h"
#import "GrowToolbarView.h"
#import "DBManager.h"
#import "TimelineView.h"

@implementation BedDetailViewController
ApplicationGlobals *appGlobals;
DBManager *dbManager;
PlantModel *plant;
CGFloat pointsPerDay;
NSDate *frostDate;
CGFloat maxDays;
NSDate *frostDate;
NSDate *startInsideDate;
NSDate *transplantDate;
NSDate *plantingDate;
NSDate *harvestFromPlantingDate;
NSDate *harvestFromTransplantDate;


- (void)viewDidLoad {
    [super viewDidLoad];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    dbManager = [DBManager getSharedDBManager];
    plant = appGlobals.selectedPlant.model;
    //setup views
    //self.navigationItem.title = appGlobals.appTitle;
    self.navigationController.navigationItem.backBarButtonItem.title = @"Back";
    if((int)self.bedRowCount < 1)self.bedRowCount = 3;
    if((int)self.bedColumnCount < 1)self.bedColumnCount = 3;
    self.bedCellCount = self.bedRowCount * self.bedColumnCount;

    frostDate = [self checkFrostDate];
    [self setDates];
    pointsPerDay = [self calculateDateBounds];
    [self initViewGrid];
    
}

- (void)setDates{
    int transplantRecoveryTime = 60*60*24*10;
    startInsideDate = [frostDate dateByAddingTimeInterval:60*60*24*plant.startInsideDelta];
    plantingDate = [frostDate dateByAddingTimeInterval:60*60*24*plant.plantingDelta];
    transplantDate = [frostDate dateByAddingTimeInterval:60*60*24*plant.transplantDelta];
    harvestFromPlantingDate = [plantingDate dateByAddingTimeInterval:60*60*24*plant.maturity];
    harvestFromTransplantDate = [startInsideDate dateByAddingTimeInterval:(60*60*24*plant.maturity + transplantRecoveryTime)];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"bedDetailViewController"];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
        [self makeToolbar];
}


-(CGFloat)calculateDateBounds{
    int min = 0;
    int max = 0;
    CGFloat ptsPerDay;
    //min = abs(appGlobals.selectedPlant.model.startInsideDelta) - abs(appGlobals.selectedPlant.model.plantingDelta);
    //if(abs(appGlobals.selectedPlant.model.startInsideDelta) < 1)min=0;
    //if(abs(appGlobals.selectedPlant.model.plantingDelta) < 1)min = 0;
    min = appGlobals.selectedPlant.model.plantingDelta;
    if(appGlobals.selectedPlant.model.startInside)min = appGlobals.selectedPlant.model.startInsideDelta;
    
    max = appGlobals.selectedPlant.model.maturity;
    int days = abs(max - min);
    //NSLog(@"days: %i", days);
    ptsPerDay = (self.view.bounds.size.width -20) / days;
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
    
    [self makeTimeline];
    //[self makeCriticalDatesBar:plantIconView withWidth:width andHeight:height];
    
}


-(void)makeTimeline{
    UIView *timeline = [[TimelineView alloc]initWithFrame:CGRectMake(10,115,self.view.frame.size.width,44) withPlantUuid:appGlobals.selectedPlant.model.plantUuid pointsPerDay:pointsPerDay maxDays:maxDays];
    //timeline.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:timeline];
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
    plantNameLabel.text = appGlobals.selectedPlant.model.plantName;
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
    plantScienceNameLabel.text = appGlobals.selectedPlant.model.plantScientificName;
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
    NSString *maturityStr = [NSString stringWithFormat:@"Matures in about %i days", appGlobals.selectedPlant.model.maturity];
    plantMaturityLabel.text = maturityStr;
    [plantMaturityLabel setFont:[UIFont italicSystemFontOfSize:12]];
    plantMaturityLabel.textColor = [UIColor blackColor];
    return plantMaturityLabel;
}


-(UITextView*) makePlantTextView:(UIView *)base withWidth:(int)width andHeight:(int)height{
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

- (UIImageView *) getIcon{
    UIImage *icon = [UIImage imageNamed:appGlobals.selectedPlant.model.iconResource];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    return imageView;
}
- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //have to call this here for the toolbar to work. Else the other views toolbar persits.
    //[self makeToolbar];
}

- (void) makeToolbar{
    float toolBarYOrigin = self.view.frame.size.height-44;
    GrowToolBarView *toolBar = [[GrowToolBarView alloc] initWithFrame:CGRectMake(0,toolBarYOrigin,self.view.frame.size.width,44) andViewController:self];
    [toolBar setToolBarIsPinned:YES];
    [self.navigationController.view addSubview:toolBar];
    [toolBar enableBackButton:YES];
    [toolBar enableMenuButton:NO];
    [toolBar enableDateButton:NO];
    [toolBar enableSaveButton:NO];
    [toolBar enableIsoButton:NO];
    [toolBar setCanOverrideDate:NO];
}

- (NSString *) makeCriticalDatesText{
    NSString *text;
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd"];
    //NSDate *startIndoorsDate = [frostDate dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.model.startInsideDelta];
    NSString *insideStr = [dateFormatter stringFromDate:startInsideDate];
    //NSDate *transplantDate = [frostDate dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.model.transplantDelta];
    //NSDate *maturityDate = [frostDate dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.model.maturity];
    //maturityDate = [maturityDate dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.model.plantingDelta];
    
    NSString *maturityStr = [dateFormatter stringFromDate:harvestFromPlantingDate];
    NSString *transplantMaturityStr = [dateFormatter stringFromDate:harvestFromTransplantDate];
    //NSDate *plantingDate = [frostDate dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.model.plantingDelta];
    NSString *plantingStr = [dateFormatter stringFromDate:plantingDate];
    NSString *transStr = [dateFormatter stringFromDate:transplantDate];
    

    if(appGlobals.selectedPlant.model.startInside && !appGlobals.selectedPlant.model.startSeed){
        text = [NSString stringWithFormat:@"\r\u2055 Plant %i per Square \r\u2055 Start inside %@ \r\u2055 Harden & Transplant %@  \r\u2055 Harvest %@ \r",appGlobals.selectedPlant.model.population,insideStr, transStr, transplantMaturityStr];
    }
    if(appGlobals.selectedPlant.model.startSeed && !appGlobals.selectedPlant.model.startInside){
        text = [NSString stringWithFormat:@"\r\u2055 Plant %i per Square \r\u2055 Plant seeds %@ \r\u2055 Harvest %@ \r",appGlobals.selectedPlant.model.population,plantingStr, maturityStr];
    }
    if(appGlobals.selectedPlant.model.startSeed && appGlobals.selectedPlant.model.startInside){
        text = [NSString stringWithFormat:@"\r\u2055 Plant %i per Square \r\u2055 Start inside %@ \r\u2055 Alternate plant seeds %@ \r\u2055 Transplant from inside %@ \r\u2055 Harvest %@ \r",appGlobals.selectedPlant.model.population,insideStr, plantingStr, transStr, maturityStr];
    }
    
    return text;
}

-(NSString *)makeDescriptionText{
    NSString *text = [self makeCriticalDatesText];
    //NSString *text = @"\r";
    NSString *str = @"";
    NSArray *json = appGlobals.selectedPlant.model.tipJsonArray;
    
    for(int i = 0; i<json.count; i++){
        str = json[i];
        if(str.length < 5)continue;
        str = [str substringToIndex:[str length] - 2];
        text = [NSString stringWithFormat:@"%@\r\u2609 %@ \r", text, str];
    }
    
    return text;
}

-(void)animateView:(UIView *)animView toFrame:(CGRect)frame{
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         animView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    return;
}

-(NSDate *)checkFrostDate{
    NSDate *compareDate = [[NSDate alloc]initWithTimeIntervalSince1970:2000];
    if([appGlobals.globalGardenModel.frostDate compare:compareDate] == NSOrderedAscending) {
        //no date selected return may 1 next year as standard date
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setDay:1];
        [comps setMonth:5];
        [comps setYear:2016];
        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];
        return date;
    }else{
        //a date is selected
        return appGlobals.globalGardenModel.frostDate;
    }
}

@end
