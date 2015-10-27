//
//  SizeBedViewController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 8/23/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//


#import "SizeBedViewController.h"
#import "ApplicationGlobals.h"
#import "DBManager.h"
#import "PlantIconView.h"
#define amRecording ((bool) YES)
#define amDebugging ((bool) YES)

@interface SizeBedViewController()

@end

@implementation SizeBedViewController

float svStartX = 0;
float svStartY = 0;

ApplicationGlobals *appGlobals;
DBManager *dbManager;
BOOL shouldContinueBlinking = NO;

//iPhone 6 screen height = 667

- (void) viewDidLoad {
    [super viewDidLoad];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    dbManager = [DBManager getSharedDBManager];
    appGlobals.selectedCell = -1;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"";

    
    UIImage *background = [UIImage imageNamed:@"cloth_test.png"];
    UIImageView *bk = [[UIImageView alloc]initWithImage:background];
    bk.alpha = .075;
    bk.frame = self.view.frame;
    [self.view addSubview:bk];
    
    
    self.topOffset = self.navigationController.navigationBar.frame.size.height * 1.5;
    self.sideOffset = 10;
    self.heightMultiplier = self.view.frame.size.height/667;
    
    self.topOffset = self.topOffset*self.heightMultiplier;

    if(self.bedColumnCount < 1)self.bedColumnCount = 1;
    if(self.bedRowCount < 1)self.bedRowCount = 1;
    self.maxRowCount = 6;
    if(self.view.frame.size.height < 481)self.maxRowCount = 5;
    self.maxColumnCount = 6;
    self.currentGardenModel = [[SqftGardenModel alloc] init];
    
    //check if there's a model in globals, save it and reset it
    if ([appGlobals getCurrentGardenModel] != nil){
        [appGlobals.globalGardenModel saveModelWithOverWriteOption:YES];
        [appGlobals setCurrentGardenModel:self.currentGardenModel];
    }
    [self initViews];
}
- (void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    
}
-(void)initViews{
    [self.bedFrameView removeFromSuperview];
    [self makeTitleView];
    [self makeSizeLabel];

    int bedDimension = [self bedDimension];
    float xCo = self.view.bounds.size.width;
    int yCo = self.bedRowCount * bedDimension * self.maxRowCount;
    self.bedFrameView = [[UIView alloc]
                         initWithFrame:CGRectMake(self.sideOffset,
                                                self.topOffset + self.titleView.frame.size.height,
                                                xCo+(self.sideOffset*-2),
                                                yCo)];
    
    //get bed array
    NSMutableArray *bedArray = [self buildBedViewArray];
    
    //add my array of beds as subviews
    for(int i = 0; i < bedArray.count; i++){
        [self.bedFrameView addSubview:[bedArray objectAtIndex:i]];
    }
    self.bedFrameView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.bedFrameView.layer.borderWidth = 1;
    self.bedFrameView.layer.cornerRadius = 15;
    
    //[self drawBaseGrid];
    
    CALayer *gridLayer = [self drawBaseGrid];
    UIImage *gridImg = [self imageFromLayer : gridLayer];
    UIImageView *grid = [[UIImageView alloc] initWithImage:gridImg];
    grid.frame = self.bedFrameView.frame;
    [self.view addSubview:grid];
    [self.view addSubview:self.bedFrameView];
    
    shouldContinueBlinking = YES;
    //[self blinkAnimation:@"blinkAnimation" finished:YES target:[bedArray objectAtIndex:0]];
    [self blinkAnimation:[bedArray objectAtIndex:0]];
}

-(void)makeSizeLabel{
    float xCo = self.view.bounds.size.width;
    int yCo = (self.bedRowCount * [self bedDimension] * self.maxRowCount)+self.titleView.frame.size.height;
    self.sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,
                                                               20+yCo,
                                                               xCo+self.sideOffset*2,
                                                               200)];
    self.sizeLabel.text = @"Drag the square to set garden size";
    [self.view addSubview:self.sizeLabel];
}

-(void)makeTitleView{
    UIColor *color = [appGlobals colorFromHexString: @"#74aa4a"];
    //float navBarHeight = self.navigationController.navigationBar.bounds.size.height *  1.5;
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(-15, 0, self.view.frame.size.width - 5, self.topOffset)];
    self.titleView.backgroundColor = [color colorWithAlphaComponent:0.55];
    self.titleView.layer.cornerRadius = 15;
    self.titleView.layer.borderWidth = 3;
    self.titleView.layer.borderColor = [color colorWithAlphaComponent:1].CGColor;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(25,0, self.view.frame.size.width - 20, self.topOffset)];
    NSString *nameStr = appGlobals.globalGardenModel.name;
    if(nameStr.length < 1)nameStr = @"New Garden";
    if([nameStr isEqualToString:@"autoSave"])nameStr = @"Unnamed Garden";
    NSString *gardenName = @"Select a Size For Your New Bed Plan";
    label.text = gardenName;
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    
    [self.titleView addSubview:label];
    [self.view addSubview: self.titleView];
    
    CGRect fm = self.titleView.frame;
    fm.origin.y = self.topOffset - 2;
    
    [UIView animateWithDuration:0.6 animations:^{
        self.titleView.frame = fm;
    }];
   }

-(int)bedDimension{
    int columnDimension = (int)(self.view.bounds.size.width - 20) / (int)self.maxColumnCount;
    int bedDimension = (int)(self.view.bounds.size.height - 60) / (int)self.maxRowCount;
    if(bedDimension > columnDimension){
        bedDimension = columnDimension;
    }
    [appGlobals setBedDimension:bedDimension];
    return bedDimension;
}
- (NSMutableArray *)buildBedViewArray{
    NSMutableArray *bedArray = [[NSMutableArray alloc] init];
    int bedDimension = [self bedDimension];
    int rowNumber = 0;
    int columnNumber = 0;
    int cell = 0;
    //int cellCount = self.bedRowCount * self.bedColumnCount;
    
    for(int i=0; i<self.bedRowCount; i++){
        while(columnNumber < self.bedColumnCount){

            //PlantIconView *bed = [[PlantIconView alloc] initWithFrame:CGRectMake(1 + (bedDimension*rowNumber),
            //                                                         (bedDimension*columnNumber)+1, bedDimension, bedDimension): 0];
            PlantIconView *bed = [[PlantIconView alloc] initWithFrame:CGRectMake(1 + (bedDimension*rowNumber),(bedDimension*columnNumber)+1, bedDimension, bedDimension) withPlantUuid:nil isIsometric:NO];
            
            
            bed.position = cell;
            bed.layer.borderWidth = 3;
            [bedArray addObject:bed];
            columnNumber++;
            cell++;
        }
        columnNumber = 0;
        rowNumber++;
    }
    return bedArray;
}
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(appGlobals.isMenuDrawerOpen == YES){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyButtonPressed" object:self];
        return;
    }
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    
    if(amRecording){
        self.touchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,34,34)];
        UIImage *icon = [UIImage imageNamed:@"asset_circle_token_512px.png"];
        self.touchIcon.image = icon;
        self.touchIcon.center = [touch locationInView:self.view];
        self.touchIcon.alpha = .8;
        [self.view addSubview:self.touchIcon];
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.touchIcon.alpha = .5;
                         }
                         completion:^(BOOL finished) {
                             //do stuff
                         }];
    }
    
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [PlantIconView class]){
        shouldContinueBlinking = NO;
        CGPoint location = [touch locationInView:[self view]];
        svStartX = location.x - touchedView.center.x;
        svStartY = location.y - touchedView.center.y;
    }
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    
    if(amRecording){
        self.touchIcon.center = [touch locationInView:self.view];
    }
    
    float bedSizeAdjuster = [self bedDimension]/2;
    bedSizeAdjuster = 0;
    
    
    float xCoUpperLimit = self.bedFrameView.frame.size.width - bedSizeAdjuster;
    float xCoLowerLimit = self.bedFrameView.frame.origin.x + bedSizeAdjuster + self.sideOffset;
    //float yCoUpperLimit = self.bedFrameView.frame.origin.y;
    float yCoLowerLimit = self.bedFrameView.frame.size.height;
    
    //NSLog(@"yCo limits: %f  %f", yCoLowerLimit, yCoUpperLimit);
    
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [PlantIconView class]){
        
        CGPoint location = [touch locationInView:[self view]];
        touchedView.hidden=FALSE;
        touchedView.backgroundColor = [UIColor clearColor];
        [self.view bringSubviewToFront:touchedView];
        [self.bedFrameView bringSubviewToFront:touchedView];
        

        //calc row and columns and update label text
        int columnCalc = round((location.x - self.bedFrameView.frame.origin.x) / [self bedDimension]);
        int rowCalc = round((location.y - self.bedFrameView.frame.origin.y) / [self bedDimension]);
        if(rowCalc < 1)rowCalc = 1;
        if(columnCalc < 1) columnCalc = 1;
        if(columnCalc > self.maxColumnCount)columnCalc = self.maxColumnCount;
        if(rowCalc > self.maxRowCount)rowCalc = self.maxRowCount;
        NSString *msg = [NSString stringWithFormat:@"SIZE: %i ft by %i ft", columnCalc, rowCalc];
        self.sizeLabel.text = msg;
        
        //apply a grid step to our bed frame
        
        location.x = location.x - svStartX;
        location.y = location.y - svStartY;
        
        float step = [self bedDimension] / 1; // Grid step size.
        location.x = step * floor((location.x / step) + .75);
        location.y = step * floor((location.y / step) + .75);
        
        //apply limits so we don't go outside our box
        if(location.x > xCoUpperLimit)location.x = xCoUpperLimit;
        if(location.x < xCoLowerLimit)location.x = xCoLowerLimit;
        if(location.y < bedSizeAdjuster)location.y = bedSizeAdjuster;
        
        if(location.y > yCoLowerLimit - bedSizeAdjuster)location.y = yCoLowerLimit - bedSizeAdjuster;
        
        CGRect frame = CGRectMake(0, 0, location.x, location.y);
        [touchedView setFrame: frame];
        
        if(columnCalc != self.bedColumnCount){
            self.bedColumnCount = columnCalc;
            self.bedRowCount = rowCalc;
            [self drawSelectedGrid];
            return;
        }
        if(rowCalc != self.bedRowCount){
            self.bedColumnCount = columnCalc;
            self.bedRowCount = rowCalc;
            [self drawSelectedGrid];
            return;
        }
        [self drawSelectedGrid];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    if(amRecording){
        self.touchIcon.center = [touch locationInView:self.view];
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.touchIcon.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [self.touchIcon removeFromSuperview];
                         }];
    }
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [PlantIconView class]){
        CGPoint location = [touch locationInView:[self view]];
        int columnCalc = round(location.x / [self bedDimension]);
        int rowCalc = round((location.y - self.bedFrameView.frame.origin.y) / [self bedDimension]);
        if(rowCalc < 1)rowCalc = 1;
        if(columnCalc < 1) columnCalc = 1;
        if(columnCalc > self.maxColumnCount)columnCalc = self.maxColumnCount;
        if(rowCalc > self.maxRowCount)rowCalc = self.maxRowCount;
        self.bedRowCount = rowCalc;
        self.bedColumnCount = columnCalc;
        
        //build new view array with new row&col counts
        NSArray *array = [self buildBedViewArray];
        //remove old subviews
        for(UIView *subview in self.bedFrameView.subviews){
            [subview removeFromSuperview];
        }
        
        //add my array of beds as subviews
        for(int i = 0; i < array.count; i++){
            [self.bedFrameView addSubview:[array objectAtIndex:i]];
        }
        [self.view addSubview:self.bedFrameView];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSNumber *rows = [NSNumber numberWithInt:self.bedRowCount];
        NSNumber *cols = [NSNumber numberWithInt:self.bedColumnCount];
        [dict setObject: rows forKey:@"rows"];
        [dict setObject: cols forKey:@"columns"];
        SqftGardenModel *model = [[SqftGardenModel alloc] initWithDict:dict];
        [appGlobals setGlobalGardenModel:model];
        //NSLog(@"end of the touches section");
        [self.navigationController performSegueWithIdentifier:@"showMain" sender:self.navigationController];
    }
}
-(void)drawSelectedGrid{
    //remove previously drawn grid lines
    for(int i=0; i<self.view.layer.sublayers.count;i++){
        if([self.view.layer.sublayers[i] class] == [CAShapeLayer class]){
            [self.view.layer.sublayers[i] removeFromSuperlayer];
        }
    }
    //draw Column Lines
    for(int i = 1; i<self.bedColumnCount - 0; i++){
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(self.sideOffset + appGlobals.bedDimension*i, self.bedFrameView.frame.origin.y)];
        [path addLineToPoint:CGPointMake(self.sideOffset + appGlobals.bedDimension*i,
                                         appGlobals.bedDimension*self.bedRowCount + self.bedFrameView.frame.origin.y)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [path CGPath];
        shapeLayer.strokeColor = [[UIColor blackColor] CGColor];
        shapeLayer.lineWidth = 2;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        [self.view.layer addSublayer:shapeLayer];
    }
    //Draw Row Lines
    for(int i = 1; i<self.bedRowCount - 0; i++){
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(self.sideOffset, self.bedFrameView.frame.origin.y  + appGlobals.bedDimension*i)];
        [path addLineToPoint:CGPointMake(self.sideOffset + appGlobals.bedDimension*(self.bedColumnCount-0), appGlobals.bedDimension*i + self.bedFrameView.frame.origin.y)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [path CGPath];
        shapeLayer.strokeColor = [[UIColor blackColor] CGColor];
        shapeLayer.lineWidth = 2;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        [self.view.layer addSublayer:shapeLayer];
    }
    [self drawBaseGrid];
}
-(CALayer *)drawBaseGrid{
    UIColor* lineColor = [UIColor blueColor];
    UIColor* bkColor = [UIColor clearColor];
    CALayer* gridLayer = [[CALayer alloc]init];
    gridLayer.frame = self.bedFrameView.frame;
    gridLayer.backgroundColor = bkColor.CGColor;
    //draw Column Lines
    for(int i = 1; i< self.maxColumnCount; i++){
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(appGlobals.bedDimension*i, 0)];
        [path addLineToPoint:CGPointMake((appGlobals.bedDimension*i), (appGlobals.bedDimension*self.maxRowCount))];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [path CGPath];
        shapeLayer.strokeColor = [lineColor colorWithAlphaComponent:.15].CGColor;
        shapeLayer.lineWidth = 1;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        [gridLayer addSublayer:shapeLayer];
        //[self.view.layer addSublayer:shapeLayer];
    }
    //Draw Row Lines
    for(int i = 1; i<self.maxRowCount; i++){
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, appGlobals.bedDimension*i)];
        [path addLineToPoint:CGPointMake((appGlobals.bedDimension*self.maxColumnCount), appGlobals.bedDimension*i)];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [path CGPath];
        shapeLayer.strokeColor = [lineColor colorWithAlphaComponent:.15].CGColor;
        shapeLayer.lineWidth = 1;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        [gridLayer addSublayer:shapeLayer];
        //[self.view.layer addSublayer:shapeLayer];
    }
    return gridLayer;
}
- (UIImage *)imageFromLayer:(CALayer *)layer
{
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions([layer frame].size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext([layer frame].size);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImage;
}

-(void)blinkAnimation:(UIView *)target{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setFromValue:[NSNumber numberWithFloat:1.0]];
    [animation setToValue:[NSNumber numberWithFloat:0.25]];
    [animation setDuration:0.75f];
    [animation setTimingFunction:[CAMediaTimingFunction
                                  functionWithName:kCAMediaTimingFunctionLinear]];
    [animation setAutoreverses:YES];
    [animation setRepeatCount:20000];
    [[target layer] addAnimation:animation forKey:@"opacity"];
}

@end