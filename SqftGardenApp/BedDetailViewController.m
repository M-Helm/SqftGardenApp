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
//CGFloat frostLineXCo;
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
    //UIColor *plantingColor = [appGlobals colorFromHexString:@"#ba9060"];
    UIColor *growingColor = [appGlobals colorFromHexString:@"#74aa4a"];
    
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd"];
    
    UIView *timelineBar = [[UIView alloc]initWithFrame:CGRectMake(5,12,width-30,21)];
    timelineBar.layer.borderColor = [UIColor orangeColor].CGColor;
    timelineBar.layer.borderWidth = 0;
    timelineBar.layer.cornerRadius = 20/2;
    timelineBar.backgroundColor = [UIColor whiteColor];
    timelineBar.clipsToBounds = YES;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.startPoint = CGPointMake(1,0);
    gradient.endPoint = CGPointMake(0,0);
    gradient.frame = timelineBar.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                             (id)[growingColor colorWithAlphaComponent:1].CGColor,
                             (id)[growingColor colorWithAlphaComponent:.5].CGColor,
                             (id)[growingColor colorWithAlphaComponent:.05].CGColor,
                             nil];
    [timelineBar.layer insertSublayer:gradient atIndex:0];
    //harvestBar.alpha = .5;
    
    NSDate *plantingDate = [appGlobals.globalGardenModel.frostDate dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.plantingDelta];
    NSString *plantingStr = [NSString stringWithFormat:@"Plant:%@",[dateFormatter stringFromDate:plantingDate]];
    NSDate *maturityDate0 = [appGlobals.globalGardenModel.frostDate dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.maturity];
    maturityDate0 = [maturityDate0 dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.plantingDelta];
    NSDate *maturityDate1 = [maturityDate0 dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.transplantDelta];
    NSDate *transDate = [appGlobals.globalGardenModel.frostDate dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.transplantDelta];
    
    NSString *maturityStr0 = [NSString stringWithFormat:@"Harvest:%@",[dateFormatter stringFromDate:maturityDate0]];
    NSString *maturityStr1 = [NSString stringWithFormat:@"Harvest:%@",[dateFormatter stringFromDate:maturityDate1]];
    NSDate *startIndoorsDate = [appGlobals.globalGardenModel.frostDate dateByAddingTimeInterval:60*60*24*appGlobals.selectedPlant.startInsideDelta];
    NSString *insideStr = [NSString stringWithFormat:@"Start Inside:%@",[dateFormatter stringFromDate:startIndoorsDate]];
    NSString *transStr = [NSString stringWithFormat:@"Transplant:%@",[dateFormatter stringFromDate:transDate]];
    
    [criticalDateBar addSubview:timelineBar];
    [criticalDateBar addSubview:[self makeHarvestLabel1:maturityStr1 isUp:NO]];
    
    [criticalDateBar addSubview:[self makeInsideLabel:insideStr isUp:NO]];
    [criticalDateBar addSubview:[self makeTransplantLabel:transStr isUp:YES]];
    if(appGlobals.selectedPlant.startInside)
        [criticalDateBar addSubview:[self makePlantingLabel:plantingStr isUp:YES]];
    else [criticalDateBar addSubview:[self makePlantingLabel:plantingStr isUp:NO]];
    [criticalDateBar addSubview:[self makeHarvestLabel0:maturityStr0 isUp:YES]];
    
    [self.view addSubview:criticalDateBar];
}
-(UILabel *)makeInsideLabel:(NSString *)text isUp:(bool)up{
    int upSpot = -3;
    if(!up)upSpot = 34;
    CGFloat xAnchor = 0;
    if(abs(appGlobals.selectedPlant.startInsideDelta)<abs(appGlobals.selectedPlant.plantingDelta)){
        int delta = abs(appGlobals.selectedPlant.plantingDelta) - abs(appGlobals.selectedPlant.startInsideDelta);
        xAnchor = delta * pointsPerDay;
    }
    UILabel *label = [self makeLabelWithFrame:CGRectMake(xAnchor,upSpot,90,16)];
    label.text = text;
    
    CGPoint start = CGPointMake(12,16);
    if(!up)start = CGPointMake(12,0);
    CGPoint end = CGPointMake(12,20);
    if(!up)end = CGPointMake(12,-10);
    CAShapeLayer *line = [self makeLineFrom:start toPoint:end];
    [label.layer addSublayer:line];

//    start = CGPointMake(12,0);
//    CGPoint end = CGPointMake(12,-10);
//    [label.layer addSublayer:line];
//    [indicatorLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(7, -14, 11, 11)] CGPath]];
    CAShapeLayer *layer = [self makeIndicatorWithFrame:CGRectMake(7, (18-upSpot), 11, 11)];
    [label.layer addSublayer: layer];
    
    if(!appGlobals.selectedPlant.startInside)label.alpha = 0;
    return label;
}
-(UILabel *)makeHarvestLabel0:(NSString *)text isUp:(bool)up{
    if(pointsPerDay < 1)[self calculateDateBounds];
    int upSpot = -5;
    if(!up)upSpot = 31;
    CGFloat xAnchor = maxDays*pointsPerDay;
    UILabel *label = [self makeLabelWithFrame:CGRectMake(xAnchor-75,upSpot,80,16)];
    label.text = text;
    
    CGPoint start = CGPointMake(60,16);
    CGPoint end = CGPointMake(60,26);
    CAShapeLayer *line = [self makeLineFrom:start toPoint:end];
    [label.layer addSublayer:line];
    
    CAShapeLayer *layer = [self makeIndicatorWithFrame:CGRectMake(55, 18-upSpot, 11, 11)];
    [label.layer addSublayer: layer];
    return label;
}

-(UILabel *)makeHarvestLabel1:(NSString *)text isUp:(bool)up{
    if(pointsPerDay < 1)[self calculateDateBounds];
    int upSpot = -5;
    if(!up)upSpot = 34;
    CGFloat xAnchor = (maxDays - 10)*pointsPerDay;
    UILabel *label = [self makeLabelWithFrame:CGRectMake(xAnchor-75,upSpot,80,16)];
    label.text = text;
    
    CGPoint start = CGPointMake(12,0);
    CGPoint end = CGPointMake(12,-10);
    //CGPoint mid = CGPointMake(24,120);
    CAShapeLayer *line = [self makeLineFrom:start toPoint:end];
    //CAShapeLayer *path = [self makePathFrom:start toPoint:end withPathMidPoint:mid];
    [label.layer addSublayer:line];
    
    CAShapeLayer *layer = [self makeIndicatorWithFrame:CGRectMake(7, 18-upSpot, 11, 11)];
    [label.layer addSublayer: layer];
    
    if(!appGlobals.selectedPlant.startInside)label.alpha = 0;
    return label;
}
-(UILabel *) makePlantingLabel:(NSString *)text isUp:(bool)up{
    int upSpot = -3;
    if(!up)upSpot = 34;
    CGFloat xAnchor = 0;
    if(abs(appGlobals.selectedPlant.startInsideDelta)>abs(appGlobals.selectedPlant.plantingDelta)){
        int delta = abs(appGlobals.selectedPlant.startInsideDelta) - abs(appGlobals.selectedPlant.plantingDelta);
        xAnchor = delta * pointsPerDay;
    }
    UILabel *label = [self makeLabelWithFrame:CGRectMake(xAnchor,upSpot,65,16)];
    label.text = text;

    
    CGPoint start = CGPointMake(12,16);
    if(!up)start = CGPointMake(12,0);
    CGPoint end = CGPointMake(12,20);
    if(!up)end = CGPointMake(12,-10);
    
    //CAShapeLayer *path = [CAShapeLayer layer];
    //CGFloat harvestAnchor = (maxDays*pointsPerDay)-xAnchor - 55;
    //CGPoint pathStart = CGPointMake(65,8);
    //CGPoint pathEnd = CGPointMake(harvestAnchor, -31);
    //[path setPath:[self drawBezierPathFrom:pathStart to:pathEnd].CGPath];
    //[path setStrokeColor:[[UIColor blackColor] CGColor]];
    //[path setLineWidth:1];
    //[path setFillColor:[[UIColor clearColor] CGColor]];
    //[label.layer addSublayer:path];
    
    CAShapeLayer *line = [self makeLineFrom:start toPoint:end];
    [label.layer addSublayer:line];
    
    CAShapeLayer *layer = [self makeIndicatorWithFrame:CGRectMake(7, 18-upSpot, 11, 11)];
    [label.layer addSublayer: layer];
    
    if(!appGlobals.selectedPlant.startSeed)label.alpha = 0;
    return label;
}

-(UILabel *)makeTransplantLabel:(NSString *)text isUp:(bool)up{
    if(pointsPerDay < 1)[self calculateDateBounds];
    int upSpot = -21;
    if(!up)upSpot = 31;
    CGFloat delta = (abs(appGlobals.selectedPlant.startInsideDelta) - abs(appGlobals.selectedPlant.transplantDelta));
    CGFloat xAnchor = delta*pointsPerDay;
    UILabel *label = [self makeLabelWithFrame:CGRectMake(xAnchor,upSpot,85,16)];
    label.text = text;
    
    CGPoint start = CGPointMake(12,16);
    CGPoint end = CGPointMake(12,40);
    
    CAShapeLayer *line = [self makeLineFrom:start toPoint:end];
    [label.layer addSublayer:line];
    CAShapeLayer *layer = [self makeIndicatorWithFrame:CGRectMake(7, 18-upSpot, 11, 11)];
    [label.layer addSublayer: layer];
    
    if(!appGlobals.selectedPlant.startInside)label.alpha=0;
    return label;
}

- (UIBezierPath *)drawBezierPathFrom:(CGPoint)point1 to:(CGPoint)point2{
    
    CGPoint controlPoint1 = CGPointMake(point1.x+50, point1.y + 15);
    CGPoint controlPoint2 = CGPointMake(point2.x-50, point2.y - 25);
    
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    
    [path1 setLineWidth:1.0];
    [path1 moveToPoint:point1];
    [path1 addCurveToPoint:point2 controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    [path1 stroke];

    return path1;
}

-(BOOL)viewIntersectsWithAnotherView:(UIView*)firstView withView:(UIView*)secondView{
    if(CGRectIntersectsRect(firstView.frame, secondView.frame))return YES;
    return NO;
}

- (UILabel *)makeLabelWithFrame:(CGRect)frame{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.layer.borderColor = [UIColor blackColor].CGColor;
    label.layer.borderWidth = 1;
    label.layer.cornerRadius = 7;
    label.backgroundColor = [UIColor clearColor];
    [label setFont: [UIFont systemFontOfSize:9]];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.backgroundColor = [UIColor whiteColor];
    return label;
}


- (CAShapeLayer *)makeIndicatorWithFrame:(CGRect)frame{
    CAShapeLayer *layer = [CAShapeLayer layer];
    [layer setPath:[[UIBezierPath bezierPathWithOvalInRect:frame] CGPath]];
    [layer setStrokeColor:[[UIColor blackColor] CGColor]];
    [layer setLineWidth:2];
    [layer setFillColor:[[UIColor whiteColor] CGColor]];
    return layer;
}

- (CAShapeLayer *)makeLineFrom:(CGPoint)start toPoint:(CGPoint)end{
    CAShapeLayer *line = [CAShapeLayer layer];
    UIBezierPath *linePath=[UIBezierPath bezierPath];
    [linePath moveToPoint:start];
    [linePath addLineToPoint:end];
    line.lineWidth = 1.0;
    line.path=linePath.CGPath;
    line.strokeColor =  [UIColor blackColor].CGColor;
    [[self.view layer] addSublayer:line];
    return line;
}

- (CAShapeLayer *)makePathFrom:(CGPoint)start toPoint:(CGPoint)end withPathMidPoint:(CGPoint)pathMid{
    CAShapeLayer *line = [CAShapeLayer layer];
    UIBezierPath *linePath=[UIBezierPath bezierPath];
    [linePath moveToPoint:start];
    [linePath addLineToPoint:pathMid];
    [linePath addLineToPoint:end];
    line.lineWidth = 1.0;
    line.path=linePath.CGPath;
    line.strokeColor =  [UIColor blackColor].CGColor;
    line.fillColor = [UIColor blackColor].CGColor;
    [[self.view layer] addSublayer:line];
    return line;
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
        text = [NSString stringWithFormat:@"\r\u2055 Plant %i per Square \r\u2055 Start inside %@ \r\u2055 Harden & Transplant %@  \r\u2055 Harvest %@ \r",appGlobals.selectedPlant.population,insideStr, transStr, maturityStr];
    }
    if(appGlobals.selectedPlant.startSeed && !appGlobals.selectedPlant.startInside){
        text = [NSString stringWithFormat:@"\r\u2055 Plant %i per Square \r\u2055 Plant seeds %@ \r\u2055 Harvest %@ \r",appGlobals.selectedPlant.population,plantingStr, maturityStr];
    }
    if(appGlobals.selectedPlant.startSeed && appGlobals.selectedPlant.startInside){
        text = [NSString stringWithFormat:@"\r\u2055 Plant %i per Square \r\u2055 Start inside %@ \r\u2055 Alternate Plant seeds %@ \r\u2055 Transplant from inside %@ \r\u2055 Harvest %@ \r",appGlobals.selectedPlant.population,insideStr, plantingStr, transStr, maturityStr];
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
    
    return text;
}

@end
