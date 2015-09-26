//
//  IsometricViewController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/25/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import "IsometricViewController.h"
#import "ApplicationGlobals.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface IsometricViewController()

@end

@implementation IsometricViewController

ApplicationGlobals *appGlobals;


- (void)viewDidLoad {
    [super viewDidLoad];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    self.bedRowCount = appGlobals.globalGardenModel.rows;
    self.bedColumnCount = appGlobals.globalGardenModel.columns;

    
    self.bedViewArray = [self buildBedViewArray];
    [self makeBedFrame:self.view.frame.size.width :self.view.frame.size.height];
    
    [self.view addSubview:self.bedFrameView];
    
    //scale
    
    CGAffineTransform scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 0.86062);
    //[self.bedFrameView setTransform:scaleTransform];
    

    //shear
    
    CGFloat shearValue = .99f;
    CGAffineTransform shearTransform = CGAffineTransformMake(1.f, 0.f, shearValue, 1.f, 0.f, 0.f);

    
    //concat
    CGAffineTransform concatTransform = CGAffineTransformConcat(scaleTransform, shearTransform);

    
    //rotate
    
    double rads = DEGREES_TO_RADIANS(-30);
    CGAffineTransform rotateTransform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);

    CGAffineTransform concatTransform2 = CGAffineTransformConcat(concatTransform, rotateTransform);
    self.bedFrameView.transform = concatTransform2;
    
    
    //[self addIsoIcons];
    
}
-(void)addIsoIcons{
    for(UIView *subview in self.bedFrameView.subviews){
        if([subview class]==[PlantIconView class]){
            PlantIconView *plant = (PlantIconView*)subview;
            UIImage *icon = [UIImage imageNamed: plant.isoIcon];
            NSLog(@"this is the iso icon: %@", plant.isoIcon);
            //UIImage *icon = [UIImage imageNamed: @"iso_generic_256px.png"];
            UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
            iconView.layer.borderWidth = 1;
            iconView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            
            CGPoint topLeftPoint = [plant transformedTopLeft];
            
            
            //CGRect frame = CGRectMake(plant.center.x,plant.center.y,44,44);
            CGRect frame = CGRectMake(topLeftPoint.x,topLeftPoint.y,44,44);
            iconView.frame = frame;
            [self.view addSubview:iconView];
            //[subview addSubview:iconView];
        }
    }
}


-(void)makeBedFrame : (int) width : (int) height{
    
    float xCo = self.bedColumnCount * appGlobals.bedDimension;
    int yCo = self.bedRowCount * appGlobals.bedDimension;
    self.bedFrameView = [[UIView alloc]
                         initWithFrame:CGRectMake(15,
                                                  15 + 120+7,
                                                  xCo+(15*2),
                                                  yCo)];
    //add my array of beds
    for(int i = 0; i<self.bedViewArray.count;i++){
        [self.bedFrameView addSubview:[self.bedViewArray objectAtIndex:i]];
    }
    //add icons to bedviews
    int cellCount = 0;
    for (UIView *subview in self.bedFrameView.subviews){
        if( [subview class] == [PlantIconView class]){
            cellCount++;
        }
    }
    self.bedFrameView.layer.borderColor = [UIColor blackColor].CGColor;
    self.bedFrameView.layer.borderWidth = 3;
}

- (NSMutableArray *)buildBedViewArray{
    NSMutableArray *bedArray = [[NSMutableArray alloc] init];
    int bedDimension = appGlobals.bedDimension - 5;
    int rowNumber = 0;
    int columnNumber = 0;
    int cell = 0;
    int cellCount = self.bedRowCount * self.bedColumnCount;
    
    //if(self.currentGardenModel == nil){
    //    self.currentGardenModel = [[SqftGardenModel alloc] init];
    //}
    if([appGlobals.globalGardenModel getPlantIdForCell:0] < 0){
        for(int i=0; i<cellCount; i++){
            [appGlobals.globalGardenModel setPlantIdForCell:i :0];
        }
    }
    for(int i=0; i<self.bedRowCount; i++){
        while(columnNumber < self.bedColumnCount){
            int plantId = [appGlobals.globalGardenModel getPlantIdForCell:cell];
            
            //float padding = [self calculateBedViewHorizontalPadding];
            float padding = 15;
            PlantIconView *bed = [[PlantIconView alloc]
                                  initWithFrame:CGRectMake(padding + (bedDimension*columnNumber),
                                                           (bedDimension*rowNumber)+1,
                                                           bedDimension,
                                                           bedDimension)
                                  withPlantId: plantId isIsometric:YES];
            bed.layer.borderWidth = 1;
            bed.position = cell;
            [bedArray addObject:bed];
            columnNumber++;
            cell++;
        }
        columnNumber = 0;
        rowNumber++;
    }
    return bedArray;
}

@end