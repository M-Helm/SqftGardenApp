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
    [self makeIsoBedFrame:self.frame.size.width :self.frame.size.height];
    
    [self addSubview:self.bedFrameView];
    [self setScrollView];
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.bedFrameView.transform = [self buildIsometricTransform];
                     }
                     completion:^(BOOL finished) {
                         [self makeIsoIconArray];
                     }];

}

- (void) setScrollView{
    self.contentSize = CGSizeMake(self.frame.size.width * 1.5, self.frame.size.height * 1.5);
    self.pagingEnabled = NO;
    self.contentInset = UIEdgeInsetsMake(20,20,20,20);
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;

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
    CGRect frame = [editBedVC calculateBedFrame];
    frame = CGRectMake(editBedVC.cellHorizontalPadding - 5, frame.origin.y, frame.size.width, frame.size.width);
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



-(void)makeIsoIconArray{
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for(UIView *subview in self.bedFrameView.subviews){
        if([subview class]==[PlantIconView class]){
            PlantIconView *plant = (PlantIconView*)subview;
            [array addObject:plant];
        }
    }
    [self setIsoIconLayout:array];
}

- (void)addIsoIcon:(PlantIconView *)plant withDelay:(CGFloat)delay{
    CGFloat duration = .25;

    int bedDimension = appGlobals.bedDimension;
    CGRect transformFrame = [self  convertRect:[plant frame] fromView:self.bedFrameView];
    CGPoint point;
    point.x = transformFrame.origin.x + (transformFrame.size.width/2);
    point.y = transformFrame.origin.y + (bedDimension/4);
    if(plant.model.isTall){
        point.x = transformFrame.origin.x;
        point.y = transformFrame.origin.y - (bedDimension/6);
    }
    if(plant.model.squareFeet > 1){
        point.x = transformFrame.origin.x + bedDimension;
        point.y = transformFrame.origin.y - (bedDimension/6);
    }
    
    UIImage *icon = [UIImage imageNamed: plant.model.isoIcon];
    
    CGRect frame = CGRectMake(0,0,bedDimension*1.75,bedDimension*1.75);
    if(plant.model.isTall) frame = CGRectMake(0,0,frame.size.width * 2, frame.size.height * 1.5);
    UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
    iconView.tag = 4;
    iconView.frame = frame;
    iconView.center = point;
    iconView.layer.borderWidth = 0;
    iconView.layer.borderColor = [UIColor blackColor].CGColor;
    iconView.alpha = 0;
    [self addSubview:iconView];
    if(plant.plantUuid.length >= 5){
        [UIView animateWithDuration:duration delay:delay*.02 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             iconView.alpha=1;
        
                         } completion:^(BOOL finished) {
        
                         }];
    }else plant.alpha = 1;
}

-(void)setIsoIconLayout:(NSMutableArray *)array{
    
    int rowCount = appGlobals.globalGardenModel.rows;
    int colCount = appGlobals.globalGardenModel.columns;
    int cellCount = rowCount*colCount;
    
    //set the icon starting at the last column, first row.
    int rowPosition = 1;
    int colPosition = colCount;
    int i = 0;
    int position = 0;

    while(i<cellCount){
        while(rowPosition < rowCount+1){
            position = ((rowPosition-1) * colCount) + (colPosition-1);
            PlantIconView *plant = [array objectAtIndex:position];
            [self addIsoIcon:plant withDelay:i];
            rowPosition++;
            i++;
        }
        colPosition--;
        rowPosition = 1;
    }
}


-(void)makeIsoBedFrame : (int) width : (int) height{
    
    float xCo = self.bedColumnCount * appGlobals.bedDimension;
    int yCo = self.bedRowCount * appGlobals.bedDimension;
    
    self.bedFrameView = [[BedView alloc]
                         initWithFrame:CGRectMake(50, 140,xCo+(15*2),yCo)
                         isIsometric:YES];
    //add my array of beds
    for(int i = 0; i<self.bedViewArray.count;i++){
        [self.bedFrameView addSubview:[self.bedViewArray objectAtIndex:i]];
    }
    //self.bedFrameView.layer.borderColor = [UIColor blackColor].CGColor;
    self.bedFrameView.layer.borderWidth = 0;

    //the border only looks good on a square layout...
    if(self.bedRowCount == self.bedColumnCount){
        //and it has to be more than one cell too....
        if(self.bedRowCount < 2)return;
        UIColor* plantingColor = [appGlobals colorFromHexString:@"#ba9060"];
        UIImage *border = [UIImage imageNamed:@"iso_border_base_512px.png"];
        UIImageView *borderView = [[UIImageView alloc] initWithImage:border];
        UIView *topPane = [[UIView alloc]initWithFrame:CGRectMake(0, 0, xCo+15, yCo+5)];
        topPane.backgroundColor = [plantingColor colorWithAlphaComponent:0.05];
        //topPane.backgroundColor = [[UIColor orangeColor]colorWithAlphaComponent:0.3];
        borderView.layer.borderWidth = 0;
        borderView.frame = CGRectMake(-10, -10,xCo+10,yCo+10);
        borderView.tag = 4;
        [borderView addSubview:topPane];
        [self.bedFrameView addSubview:borderView];
    }
}


- (NSMutableArray *)buildBedViewArray{
    NSMutableArray *bedArray = [[NSMutableArray alloc] init];
    int bedDimension = appGlobals.bedDimension - 5;
    int rowNumber = 0;
    int columnNumber = 0;
    int cell = 0;
    //int cellCount = self.bedRowCount * self.bedColumnCount;
    
    //if(self.currentGardenModel == nil){
    //    self.currentGardenModel = [[SqftGardenModel alloc] init];
    //}
    //if([appGlobals.globalGardenModel getPlantUuidForCell:0] < 0){
    //    for(int i=0; i<cellCount; i++){
            //[appGlobals.globalGardenModel setPlantUuidForCell:i :@"nil"];
    //    }
    //}
    
    for(int i=0; i<self.bedRowCount; i++){
        while(columnNumber < self.bedColumnCount){
            NSString *plantUuid = [appGlobals.globalGardenModel getPlantUuidForCell:cell];
            //int plantId = [appGlobals.globalGardenModel getPlantIdForCell:cell];
            
            //float padding = [self calculateBedViewHorizontalPadding];
            float padding = 15;
            PlantIconView *bed = [[PlantIconView alloc]
                                  initWithFrame:CGRectMake(padding + (bedDimension*columnNumber),
                                                           (bedDimension*rowNumber)+1,
                                                           bedDimension,
                                                           bedDimension)
                                  withPlantUuid:plantUuid isIsometric:YES];
            bed.layer.borderWidth = 1;
            bed.model.position = cell;
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

    if(appGlobals.isMenuDrawerOpen == YES){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyButtonPressed" object:self];
        return;
    }
}

@end
