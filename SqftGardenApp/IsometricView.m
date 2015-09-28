//
//  IsometricView.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/26/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import "IsometricView.h"
#import "ApplicationGlobals.h"
#import "EditBedViewController.h"
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface IsometricView()

@end


@implementation IsometricView

ApplicationGlobals *appGlobals;
EditBedViewController *editBedVC;


- (id)initWithFrame:(CGRect)frame andEditBedVC:(UIViewController*)editBed{

    self = [super initWithFrame:frame];
    if (self) {
        editBedVC = (EditBedViewController*)editBed;
        [self commonInit];
    }
    return self;
}


- (void)commonInit {

    appGlobals = [ApplicationGlobals getSharedGlobals];
    self.bedRowCount = appGlobals.globalGardenModel.rows;
    self.bedColumnCount = appGlobals.globalGardenModel.columns;
    
    
    self.bedViewArray = [self buildBedViewArray];
    [self makeBedFrame:self.frame.size.width :self.frame.size.height];
    
    [self addSubview:self.bedFrameView];
    [self setScrollView];
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.bedFrameView.transform = [self buildIsometricTransform];
                     }
                     completion:^(BOOL finished) {
                         [self addIsoIcons];
                     }];

}

-(CGRect)makeBedFrame{
    float xCo = editBedVC.view.bounds.size.width;
    float yCo = appGlobals.globalGardenModel.rows * appGlobals.bedDimension;
    CGRect frame = CGRectMake(editBedVC.sideOffset, editBedVC.topOffset + editBedVC.titleView.frame.size.height+7, xCo+(editBedVC.sideOffset*-2),yCo);
    return frame;
}


- (void) setScrollView{
    // Adjust scroll view content size
    self.contentSize = CGSizeMake(self.frame.size.width * 1.5, self.frame.size.height * 1.5);
    self.pagingEnabled= NO;
    self.contentInset = UIEdgeInsetsMake(20,20,20,20);
    
    //self.backgroundColor = [UIColor clearColor];
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

-(CGAffineTransform) buildUnwindIsometricTransform{
    //scale
    CGAffineTransform scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1.);
    
    //shear
    CGFloat shearValue = 0.0f;
    CGAffineTransform shearTransform = CGAffineTransformMake(1.f, 0.f, shearValue, 1.f, 0.f, 0.f);
    
    //concat
    CGAffineTransform concatTransform = CGAffineTransformConcat(scaleTransform, shearTransform);
    
    //rotate
    double rads = DEGREES_TO_RADIANS(0);
    CGAffineTransform rotateTransform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
    
    CGAffineTransform concatTransform2 = CGAffineTransformConcat(concatTransform, rotateTransform);
    return concatTransform2;
    
}

-(void) unwindIsoViewTransform{
    //remove the iso icons
    for(UIView *subview in self.subviews){
        if(subview.tag == 4){
            subview.alpha=0;
            [subview removeFromSuperview];
        }
    }
    for(UIView *subview in self.bedFrameView.subviews){
        if(subview.tag == 4){
            subview.alpha=0;
            [subview removeFromSuperview];
        }
    }
    //CGRect frame = CGRectMake(50, 140,self.bedFrameView.frame.size.width,self.bedFrameView.frame.size.height);
    CGRect frame = [self makeBedFrame];
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.bedFrameView.transform = [self buildUnwindIsometricTransform];
                         self.bedFrameView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         if(finished){
                             [editBedVC unwindIsoView];
                         }
                     }];

}



-(void)addIsoIcons{
    
    
    int bedDimension = appGlobals.bedDimension;
    //float padding = 5;
    
    
    for(UIView *subview in self.bedFrameView.subviews){
        if([subview class]==[PlantIconView class]){
            PlantIconView *plant = (PlantIconView*)subview;
            
            CGRect transformFrame = [self  convertRect:[plant frame] fromView:self.bedFrameView];
            CGPoint point;
            point.x = transformFrame.origin.x + (transformFrame.size.width/2);
            point.y = transformFrame.origin.y + (bedDimension/4);

            UIImage *icon = [UIImage imageNamed: plant.isoIcon];
            
            CGRect frame = CGRectMake(0,0,bedDimension,bedDimension);
            UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
            iconView.tag = 4;
            iconView.frame = frame;
            iconView.center = point;
            //[self addSubview:iconView];
            [self addSubview:iconView];
        }
    }
}


-(void)makeBedFrame : (int) width : (int) height{
    
    float xCo = self.bedColumnCount * appGlobals.bedDimension;
    int yCo = self.bedRowCount * appGlobals.bedDimension;
    
    self.bedFrameView = [[BedView alloc]
                         initWithFrame:CGRectMake(50, 140,xCo+(15*2),yCo)
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
    
    UIImage *border = [UIImage imageNamed:@"iso_border_base_512px.png"];
    UIImageView *borderView = [[UIImageView alloc] initWithImage:border];
    borderView.layer.borderWidth = 0;
    borderView.frame = CGRectMake(-15, -15,xCo+15,yCo+15);
    borderView.tag = 4;
    
    //[self.bedFrameView addSubview:borderView];
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
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //if(self.datePickerIsOpen)return;
    //NSLog(@"isoview touches began");
    if(appGlobals.isMenuDrawerOpen == YES){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyButtonPressed" object:self];
        return;
    }
}

@end
