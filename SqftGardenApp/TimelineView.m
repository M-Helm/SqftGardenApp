//
//  TimelineView.m
//  GrowSquared
//
//  Created by Matthew Helm on 11/20/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import "TimelineView.h"
#import "ApplicationGlobals.h"
#import "PlantModel.h"

@interface TimelineView()

@end

@implementation TimelineView

ApplicationGlobals *appGlobals;
NSDate *frostDate;
PlantModel *plant;


- (id)initWithFrame:(CGRect)frame withPlantUuid: (NSString *)plantUuid pointsPerDay: (CGFloat)pointsPerDay maxDays:(int)max{
    self = [super initWithFrame:frame];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    plant = [[PlantModel alloc]initWithUUID:plantUuid];
    self.pointsPerDay = pointsPerDay;
    self.maxDays = max;
    //get the frost date here
    frostDate = [self checkFrostDate];

    [self makeCriticalDatesBar:self.frame.size.width andHeight:self.frame.size.height];
    return self;
}

-(void)makeCriticalDatesBar:(int)width andHeight:(int)height{
    UIView *criticalDateBar = [[UIView alloc]initWithFrame:CGRectMake(0,0, width, 44)];
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
    
    NSDate *plantingDate = [frostDate dateByAddingTimeInterval:60*60*24*plant.plantingDelta];
    NSString *plantingStr = [NSString stringWithFormat:@"Plant:%@",[dateFormatter stringFromDate:plantingDate]];
    
    NSDate *maturityDate0 = [frostDate dateByAddingTimeInterval:60*60*24*plant.maturity];
    maturityDate0 = [maturityDate0 dateByAddingTimeInterval:60*60*24*plant.plantingDelta];
    NSDate *maturityDate1 = [maturityDate0 dateByAddingTimeInterval:60*60*24*plant.transplantDelta];
    NSDate *transDate = [frostDate dateByAddingTimeInterval:60*60*24*plant.transplantDelta];
    
    NSString *maturityStr0 = [NSString stringWithFormat:@"Harvest:%@",[dateFormatter stringFromDate:maturityDate0]];
    NSString *maturityStr1 = [NSString stringWithFormat:@"Harvest:%@",[dateFormatter stringFromDate:maturityDate1]];
    NSDate *startIndoorsDate = [frostDate dateByAddingTimeInterval:60*60*24*plant.startInsideDelta];
    NSString *insideStr = [NSString stringWithFormat:@"Start Inside:%@",[dateFormatter stringFromDate:startIndoorsDate]];
    NSString *transStr = [NSString stringWithFormat:@"Transplant:%@",[dateFormatter stringFromDate:transDate]];
    
    [criticalDateBar addSubview:timelineBar];
    [criticalDateBar addSubview:[self makeHarvestLabel1:maturityStr1 isUp:NO]];
    
    [criticalDateBar addSubview:[self makeInsideLabel:insideStr isUp:NO]];
    [criticalDateBar addSubview:[self makeTransplantLabel:transStr isUp:YES]];
    if(plant.startInside)
        [criticalDateBar addSubview:[self makePlantingLabel:plantingStr isUp:YES]];
    else [criticalDateBar addSubview:[self makePlantingLabel:plantingStr isUp:NO]];
    [criticalDateBar addSubview:[self makeHarvestLabel0:maturityStr0 isUp:YES]];
    [self addSubview:criticalDateBar];
}

-(UILabel *)makeInsideLabel:(NSString *)text isUp:(bool)up{
    int upSpot = -3;
    if(!up)upSpot = 34;
    CGFloat xAnchor = 0;
    if(abs(plant.startInsideDelta)<abs(plant.plantingDelta)){
        int delta = abs(plant.plantingDelta) - abs(plant.startInsideDelta);
        xAnchor = delta * self.pointsPerDay;
    }
    
    UILabel *label = [self makeLabelWithFrame:CGRectMake(xAnchor,upSpot,90,16)];
    label.text = text;
    label.layer.borderColor = [UIColor blueColor].CGColor;
    
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
    [layer setStrokeColor:[[UIColor blueColor] CGColor]];
    [label.layer addSublayer: layer];
    
    if(!plant.startInside)label.alpha = 0;
    return label;
}
-(UILabel *)makeHarvestLabel0:(NSString *)text isUp:(bool)up{
    //if(self.pointsPerDay < 1)[self calculateDateBounds];
    int upSpot = -5;
    if(!up)upSpot = 31;
    CGFloat xAnchor = self.maxDays*self.pointsPerDay;
    
    UILabel *label = [self makeLabelWithFrame:CGRectMake(xAnchor-75,upSpot,80,16)];
    label.text = text;
    
    CGPoint start = CGPointMake(60,16);
    CGPoint end = CGPointMake(60,26);
    CAShapeLayer *line = [self makeLineFrom:start toPoint:end];
    [label.layer addSublayer:line];
    
    CAShapeLayer *layer = [self makeIndicatorWithFrame:CGRectMake(55, 18-upSpot, 11, 11)];
    [label.layer addSublayer: layer];
    
    if(!plant.startSeed)label.alpha = 0;
    return label;
}

-(UILabel *)makeHarvestLabel1:(NSString *)text isUp:(bool)up{
    //if(self.pointsPerDay < 1)[self calculateDateBounds];
    int upSpot = -5;
    if(!up)upSpot = 34;
    CGFloat xAnchor = (plant.maturity * self.pointsPerDay);
    if(plant.startSeed){
        xAnchor = (abs(plant.maturity) * self.pointsPerDay);
    }
    
    UILabel *label = [self makeLabelWithFrame:CGRectMake(xAnchor-75,upSpot,80,16)];
    label.text = text;
    label.layer.borderColor = [UIColor blueColor].CGColor;
    
    CGPoint start = CGPointMake(60,0);
    CGPoint end = CGPointMake(60,-10);
    //CGPoint mid = CGPointMake(24,120);
    CAShapeLayer *line = [self makeLineFrom:start toPoint:end];
    //CAShapeLayer *path = [self makePathFrom:start toPoint:end withPathMidPoint:mid];
    [label.layer addSublayer:line];
    
    CAShapeLayer *layer = [self makeIndicatorWithFrame:CGRectMake(55, 18-upSpot, 11, 11)];
    [layer setStrokeColor:[[UIColor blueColor] CGColor]];
    [label.layer addSublayer: layer];
    
    
    if(!plant.startInside)label.alpha = 0;
    return label;
}

-(UILabel *) makePlantingLabel:(NSString *)text isUp:(bool)up{
    int upSpot = -3;
    if(!up)upSpot = 34;
    CGFloat xAnchor = 0;
    if(abs(plant.startInsideDelta)>abs(plant.plantingDelta)){
        int delta = abs(plant.startInsideDelta) - abs(plant.plantingDelta);
        xAnchor = delta * self.pointsPerDay;
    }
    
    UILabel *label = [self makeLabelWithFrame:CGRectMake(xAnchor,upSpot,65,16)];
    label.text = text;
    label.layer.borderColor = [UIColor blackColor].CGColor;
    
    
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
    
    if(!plant.startSeed)label.alpha = 0;
    return label;
}

-(UILabel *)makeTransplantLabel:(NSString *)text isUp:(bool)up{
    int upSpot = -21;
    if(!up)upSpot = 31;
    CGFloat delta = (abs(plant.startInsideDelta) - abs(plant.transplantDelta));
    CGFloat xAnchor = delta*self.pointsPerDay;
    
    UILabel *label = [self makeLabelWithFrame:CGRectMake(xAnchor,upSpot,85,16)];
    label.text = text;
    label.layer.borderColor = [UIColor blueColor].CGColor;
    
    CGPoint start = CGPointMake(12,16);
    CGPoint end = CGPointMake(12,40);
    
    CAShapeLayer *line = [self makeLineFrom:start toPoint:end];
    [label.layer addSublayer:line];
    CAShapeLayer *layer = [self makeIndicatorWithFrame:CGRectMake(7, 18-upSpot, 11, 11)];
    [layer setStrokeColor:[[UIColor blueColor] CGColor]];
    [label.layer addSublayer: layer];
    
    if(!plant.startInside)label.alpha=0;
    return label;
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
    [[self layer] addSublayer:line];
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
    [[self layer] addSublayer:line];
    return line;
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