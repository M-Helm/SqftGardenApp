//
//  IsomorphicViewController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/25/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import "IsomorphicViewController.h"
#import "ApplicationGlobals.h"

@interface IsomorphicViewController()

@end

@implementation IsomorphicViewController

ApplicationGlobals *appGlobals;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bedRowCount = 2;
    self.bedColumnCount = 2;
    appGlobals = [ApplicationGlobals getSharedGlobals];
}



-(void)makeBedFrame : (int) width : (int) height{
    
    float xCo = self.view.bounds.size.width;
    int yCo = self.bedRowCount * appGlobals.bedDimension;
    self.bedFrameView = [[UIView alloc]
                         initWithFrame:CGRectMake(15,
                                                  15 + 120+7,
                                                  xCo+(15*-2),
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
                                  withPlantId: plantId];
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