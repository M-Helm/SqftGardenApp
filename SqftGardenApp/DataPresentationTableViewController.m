//
//  DataPresentationTableViewController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/22/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import "DataPresentationTableViewController.h"
#import "DBManager.h"
#import "ApplicationGlobals.h"
#import "PresentTableCell.h"
//#import "SqftGardenModel.h"
#import "PlantIconView.h"

@interface DataPresentationTableViewController()

@end

@implementation DataPresentationTableViewController

DBManager *dbManager;
ApplicationGlobals *appGlobals;
const int SIDE_OFFSET = 5;
CGFloat plantingDateAnchor;

static NSString *CellIdentifier = @"CellIdentifier";
NSArray *plantArray;
NSDateFormatter *dateFormatter;
UIColor *plantingColor;
UIColor *growingColor;
UIColor *harvestColor;
UIColor *frostColor;
bool boundsCalculated;
int maxDays;
int minDays;
CGFloat width;
CGFloat daysPerPoint;
CGFloat height;

- (void)viewDidLoad {
    [super viewDidLoad];
    dbManager = [DBManager getSharedDBManager];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    plantArray = [[NSArray alloc]
                  initWithArray: [self buildPlantArrayFromModel:appGlobals.globalGardenModel]];
    dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd"];
    [self makeHeader];
    [self calculateDateBounds:plantArray];
    plantingColor = [appGlobals colorFromHexString:@"#ba9060"];
    growingColor = [appGlobals colorFromHexString:@"#74aa4a"];
    harvestColor = [appGlobals colorFromHexString:@"#f9a239"];
    frostColor= [appGlobals colorFromHexString:@"#77ccd1"];
    
    
    width = self.view.frame.size.width;
    daysPerPoint = (width / (15 + maxDays + abs(minDays)));
    height = self.view.frame.size.height;
    plantingDateAnchor = (SIDE_OFFSET + (abs(minDays) * daysPerPoint));
    if(plantingDateAnchor < 15)plantingDateAnchor = 15;
    NSLog(@"date anchor offset = %f", plantingDateAnchor);
    //UIView *plantingDateLine =
    //    [[UIView alloc]initWithFrame:CGRectMake(plantingDateAnchor, 80, 2, height-130)];
    //plantingDateLine.backgroundColor = [UIColor lightGrayColor];
    //[self.view addSubview:plantingDateLine];
}

-(void)calculateDateBounds:(NSArray *)array{
    boundsCalculated = YES;
    int min = 0;
    int max = 0;
    PlantIconView *plant;
    NSNumber *plantIndex = [NSNumber numberWithInt:0];
    for(int i = 0; i < array.count; i++){
        plantIndex = array[i];
        plant = [[PlantIconView alloc]initWithFrame:CGRectMake(0,0,0,0) withPlantId:plantIndex.intValue isIsometric:NO];
        if(min > plant.plantingDelta)min = plant.plantingDelta;
        if(max < plant.maturity)max = plant.maturity;
    }
    NSLog(@"MIN = %i", min);
    NSLog(@"MAX = %i", max);
    minDays = min;
    maxDays = max;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return plantArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PresentTableCell *cell;
    NSString *mainLabelString = @"this is the main label";
    NSString *harvestDateString = @"this is the harvest date";
    NSString *plantingDateString = @"this is the planting date";
    NSNumber *plantId = plantArray[(int)[indexPath row]];
    
    PlantIconView *plant = [[PlantIconView alloc]
                            initWithFrame:CGRectMake(0,0,0,0) withPlantId:plantId.intValue isIsometric:NO];
    NSDate *maturityDate = [appGlobals.globalGardenModel.plantingDate dateByAddingTimeInterval:60*60*24*plant.maturity];
    NSDate *plantingDate = [appGlobals.globalGardenModel.plantingDate dateByAddingTimeInterval:60*60*24*plant.plantingDelta];
    harvestDateString = [dateFormatter stringFromDate:maturityDate];
    harvestDateString = [NSString stringWithFormat:@"%@", harvestDateString];
    
    plantingDateString = [dateFormatter stringFromDate:plantingDate];
    plantingDateString = [NSString stringWithFormat:@"%@", plantingDateString];
    
    mainLabelString = plant.plantName;
    
    if(cell == nil){
        NSLog(@"value of bounds %i", boundsCalculated);
        cell = [[PresentTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        height = cell.contentView.frame.size.height;
        cell.mainLabel = [[UILabel alloc]initWithFrame:CGRectMake(15,0,125,20)];
        cell.plantView = [[UIView alloc]initWithFrame:CGRectMake(0,20,25,height - 20)];
        cell.growingView = [[UIView alloc]initWithFrame:CGRectMake(25,20,125,height - 20)];
        cell.harvestView = [[UIView alloc]initWithFrame:CGRectMake(150,20,20,height - 20)];
        cell.frostView = [[UIView alloc]initWithFrame:CGRectMake(0,0,0,0)];
    }else{
        
    }

    CGRect adjustedFrame = CGRectMake(plantingDateAnchor + plant.plantingDelta, 13, 10, height - 20);
    cell.plantView.frame = adjustedFrame;
    //cell.growingView.frame = CGRectMake(adjustedFrame.origin.x+10, 13,(plant.maturity*daysPerPoint), height -20);
    cell.growingView.frame = CGRectMake(adjustedFrame.origin.x+10, 13,0, height -20);
    cell.harvestView.frame = CGRectMake(adjustedFrame.origin.x+(plant.maturity*daysPerPoint)+10, 13,20, height -20);
    
    cell.mainLabel.frame = CGRectMake(self.view.frame.origin.x+80,
                                      cell.growingView.frame.origin.y,
                                      cell.growingView.frame.size.width,
                                      cell.growingView.frame.size.height);
    cell.frostView.frame = CGRectMake(self.view.frame.origin.x + 5,
                                      10,
                                      plantingDateAnchor-5,
                                      height-17);
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.startPoint = CGPointMake(0,0);
    gradient.endPoint = CGPointMake(1,0);
    gradient.frame = cell.frostView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[frostColor CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    [cell.frostView.layer insertSublayer:gradient atIndex:0];
    
    //cell.frostView.backgroundColor = frostColor;
    //cell.frostView.alpha = .2;
    
    cell.plantView.backgroundColor = plantingColor;
    cell.growingView.backgroundColor = growingColor;
    cell.harvestView.backgroundColor = harvestColor;
    cell.plantView.alpha = .8;
    cell.growingView.alpha = .7;
    cell.harvestView.alpha = .8;
    cell.mainLabel.text = mainLabelString;
    
    
    
    UILabel *plantingLabel = [[UILabel alloc]initWithFrame:CGRectMake(-10,-12,40,15)];
    plantingLabel.layer.borderColor = [UIColor blackColor].CGColor;
    plantingLabel.layer.borderWidth = 1;
    plantingLabel.layer.cornerRadius = 5;
    plantingLabel.backgroundColor = [UIColor whiteColor];
    [plantingLabel setFont: [UIFont systemFontOfSize:9]];
    [plantingLabel setTextAlignment:NSTextAlignmentCenter];
    plantingLabel.clipsToBounds=YES;
    plantingLabel.text = plantingDateString;
    [cell.plantView addSubview:plantingLabel];
    
    UILabel *harvestLabel = [[UILabel alloc]initWithFrame:CGRectMake(-20,20,40,15)];
    harvestLabel.layer.borderColor = [UIColor blackColor].CGColor;
    harvestLabel.layer.borderWidth = 1;
    harvestLabel.layer.cornerRadius = 5;
    harvestLabel.backgroundColor = [UIColor whiteColor];
    [harvestLabel setFont: [UIFont systemFontOfSize:9]];
    [harvestLabel setTextAlignment:NSTextAlignmentCenter];
    harvestLabel.clipsToBounds=YES;
    harvestLabel.text = harvestDateString;
    [cell.harvestView addSubview:harvestLabel];
    
    
    
    //cell.harvestLabel.text = harvestDateString;
    [cell.mainLabel setFont: [UIFont systemFontOfSize:11]];
    //[cell.mainLabel setTextAlignment:NSTextAlignmentCenter];
    
    [cell.contentView addSubview:cell.frostView];
    [cell.contentView addSubview:cell.growingView];
    [cell.contentView addSubview:cell.plantView];
    [cell.contentView addSubview:cell.harvestView];
    [cell.contentView addSubview:cell.mainLabel];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    PresentTableCell *tableCell;
    if([cell class] == [PresentTableCell class]){
        tableCell = (PresentTableCell*)cell;
        NSNumber *plantId = plantArray[(int)[indexPath row]];
        PlantIconView *plant = [[PlantIconView alloc]
                                initWithFrame:CGRectMake(0,0,0,0) withPlantId:plantId.intValue isIsometric:NO];
        CGRect frame = CGRectMake(tableCell.growingView.frame.origin.x,
                              tableCell.growingView.frame.origin.y,
                              0,
                              tableCell.growingView.frame.size.height);
    
        [UIView animateWithDuration:1.25 delay:0.1 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         tableCell.growingView.frame = CGRectMake(frame.origin.x,frame.origin.y,(plant.maturity*daysPerPoint),frame.size.height);

                         
                        }
                         completion:^(BOOL finished) {
                         
                        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) {
        // Do your stuff here
        for(UIView *subview in self.navigationController.navigationBar.subviews){
            //tag 6 is set in the editView VC singletap method for the dataselect icon view
            if(subview.tag == 6) subview.alpha = 1;
        }
    }
}

- (void) makeHeader{
    float width = self.view.frame.size.width;
    //float height = self.view.frame.size.height;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake((headerView.frame.size.width/2)-75, 0, 150, 50)];
    //add cancel button
    PlantIconView *cancelBtn = [[PlantIconView alloc]
                                initWithFrame:CGRectMake(self.view.frame.size.width - 55, 1, 44,44) withPlantId: -1 isIsometric:NO];
    cancelBtn.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleCancelSingleTap:)];
    [cancelBtn addGestureRecognizer:singleFingerTap];
    
    
    [headerView addSubview:labelView];
    [headerView addSubview:cancelBtn];
    labelView.text = @"Timeline";
    labelView.textAlignment = NSTextAlignmentCenter;
    [labelView setFont:[UIFont boldSystemFontOfSize:18]];
    headerView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    
    self.tableView.tableHeaderView = headerView;
}
- (void)handleCancelSingleTap:(UITapGestureRecognizer *)recognizer {
    [self.navigationController performSegueWithIdentifier:@"showMain" sender:self.navigationController];
    return;
}

- (NSMutableArray *)buildPlantArrayFromModel:(SqftGardenModel*)model{
    //running through the model bed state to get non-zero and unique plant ids
    NSMutableArray *array = [[NSMutableArray alloc]init];
    NSDictionary *dict = model.bedStateDictionary;
    int cellCount = model.rows * model.columns;
    //one pass for each cell
    for(int i=0; i<cellCount; i++){
        NSString *cell = [NSString stringWithFormat:@"cell%i", i];
        NSString *plantStr = [dict objectForKey:cell];
        int plant = plantStr.intValue;
        if(plant < 1)continue;
        NSNumber *plantObj = [NSNumber numberWithInt:plant];
        NSLog(@"plantStr = %@", plantStr);
        if(array.count < 1){
            [array addObject:plantStr];
            continue;
        }
        for(int j=0; j<array.count; j++){
            NSString *arrayStr = array[j];
            if(arrayStr.intValue == plant)break;
            if(j == array.count - 1)
                [array addObject:plantObj];
        }
    }
    NSLog(@"%@ Array = %i", array, (int)array.count);
    return array;
}


@end
