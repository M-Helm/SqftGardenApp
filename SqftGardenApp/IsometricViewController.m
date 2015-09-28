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
    

    
    

    [UIView animateWithDuration:0.6 delay:0.2 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.bedFrameView.transform = [self buildIsometricTransform];
                     }
                     completion:^(BOOL finished) {
                         [self addIsoIcons];
                     }];
    
    
    
    
}

-(CGAffineTransform) buildIsometricTransform{
    
    //scale
    CGAffineTransform scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 0.86062);
    
    //shear
    CGFloat shearValue = .99f;
    CGAffineTransform shearTransform = CGAffineTransformMake(1.f, 0.f, shearValue, 1.f, 0.f, 0.f);
    
    //concat
    CGAffineTransform concatTransform = CGAffineTransformConcat(scaleTransform, shearTransform);
    
    //rotate
    double rads = DEGREES_TO_RADIANS(-30);
    CGAffineTransform rotateTransform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
    
    CGAffineTransform concatTransform2 = CGAffineTransformConcat(concatTransform, rotateTransform);
    return concatTransform2;
}


-(void)addIsoIcons{


    int bedDimension = appGlobals.bedDimension;
    //float padding = 5;


    for(UIView *subview in self.bedFrameView.subviews){
        if([subview class]==[PlantIconView class]){
            PlantIconView *plant = (PlantIconView*)subview;

            CGRect transformFrame = [[self view] convertRect:[plant frame] fromView:self.bedFrameView];
            CGPoint point;
            point.x = transformFrame.origin.x + (transformFrame.size.width/2);
            //point.y = transformFrame.origin.y + (transformFrame.size.height/2);
            point.y = transformFrame.origin.y + (bedDimension/4);
            
           
            
            //CGRect frame = [[self view] convertRect:[plant frame] fromView:self.bedFrameView];
            //CGRect frame2 = [plant.center convertPoint:toView:];
            UIImage *icon = [UIImage imageNamed: plant.isoIcon];
            
            CGRect frame = CGRectMake(0,0,bedDimension,bedDimension);
            UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
            //iconView.layer.borderWidth = 1;
            //iconView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            iconView.frame = frame;
            iconView.center = point;
            [self.view addSubview:iconView];
            //int plantId = [self.currentGardenModel getPlantIdForCell:cell];
            
            //float padding = [self calculateBedViewHorizontalPadding];
            
            //bed.layer.borderWidth = 1;
            //bed.position = cell;
            //[bedArray addObject:bed];
            [self.view addSubview:iconView];
        }
    }
    
            /*
            
            //NSLog(@"this is the iso icon: %@", plant.isoIcon);
            //UIImage *icon = [UIImage imageNamed: @"iso_generic_256px.png"];
            
             
            //int cellCount = self.bedRowCount * self.bedColumnCount;
            

            
            
            
            
            NSLog(@"plant position: %i", plant.position);
            
            //CGRect frame = CGRectMake(plant.center.x,plant.center.y,44,44);
            CGRect frame = CGRectMake(topLeftPoint.x+(plant.position * appGlobals.bedDimension),topLeftPoint.y-44,44,44);
            
            
            //[subview addSubview:iconView];
        }
             */
}


-(void)makeBedFrame : (int) width : (int) height{
    
    float xCo = self.bedColumnCount * appGlobals.bedDimension;
    int yCo = self.bedRowCount * appGlobals.bedDimension;

    self.bedFrameView = [[BedView alloc]
                         initWithFrame:CGRectMake(15, 15 + 120+7,xCo+(15*2),yCo)
                         isIsometric:YES];
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
    //self.bedFrameView.layer.borderColor = [UIColor blackColor].CGColor;
    self.bedFrameView.layer.borderWidth = 0;
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