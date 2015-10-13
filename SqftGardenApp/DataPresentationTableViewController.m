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
static NSString *CellIdentifier = @"CellIdentifier";
NSArray *plantArray;
NSDateFormatter *dateFormatter;
UIColor *plantingColor;
UIColor *growingColor;
UIColor *harvestColor;

- (void)viewDidLoad {
    [super viewDidLoad];
    dbManager = [DBManager getSharedDBManager];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    plantArray = [[NSArray alloc]
                  initWithArray: [self buildPlantArrayFromModel:appGlobals.globalGardenModel]];
    dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    [self makeHeader];
    [self calculateMaxPlantingDelta:plantArray];
    plantingColor = [appGlobals colorFromHexString:@"#ba9060"];
    growingColor = [appGlobals colorFromHexString:@"#74aa4a"];
    harvestColor = [appGlobals colorFromHexString:@"#f9a239"];
}

-(int)calculateMaxPlantingDelta:(NSArray *)array{
    int max = 0;
    PlantIconView *plant;
    NSNumber *plantIndex = [NSNumber numberWithInt:0];
    //NSInteger *plantIndex = NSInternalInconsistencyException
    for(int i = 0; i < array.count; i++){
        plantIndex = array[i];
        plant = [[PlantIconView alloc]initWithFrame:CGRectMake(0,0,0,0) withPlantId:plantIndex.intValue isIsometric:NO];
        if(max < plant.plantingDelta)max = plant.plantingDelta;
    }
    NSLog(@"MAX = %i", max);
    return max;
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
    
    PlantIconView *plant = [[PlantIconView alloc]
                            initWithFrame:CGRectMake(0,0,0,0) withPlantId:(int)[indexPath row]+1 isIsometric:NO];
    NSDate *maturityDate = [appGlobals.globalGardenModel.plantingDate dateByAddingTimeInterval:60*60*24*plant.maturity];
    NSDate *plantingDate = [appGlobals.globalGardenModel.plantingDate dateByAddingTimeInterval:60*60*24*plant.plantingDelta];
    harvestDateString = [dateFormatter stringFromDate:maturityDate];
    harvestDateString = [NSString stringWithFormat:@"Harvest on or about: %@", harvestDateString];
    
    plantingDateString = [dateFormatter stringFromDate:plantingDate];
    plantingDateString = [NSString stringWithFormat:@"Plant on: %@", plantingDateString];
    
    mainLabelString = plant.plantName;
    
    if(cell == nil){
        cell = [[PresentTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        CGFloat height = cell.contentView.frame.size.height;
        cell.mainLabel = [[UILabel alloc]initWithFrame:CGRectMake(15,0,125,20)];
        cell.plantLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,20,25,height - 20)];
        cell.growingLabel = [[UILabel alloc]initWithFrame:CGRectMake(25,20,125,height - 20)];
        cell.harvestLabel = [[UILabel alloc]initWithFrame:CGRectMake(150,20,20,height - 20)];
    }else{
        
    }
    
    
    
    
    cell.plantLabel.backgroundColor = plantingColor;
    cell.growingLabel.backgroundColor = growingColor;
    cell.harvestLabel.backgroundColor = harvestColor;
    cell.plantLabel.alpha = .8;
    cell.growingLabel.alpha = .7;
    cell.harvestLabel.alpha = .8;
    cell.mainLabel.text = mainLabelString;
    //cell.harvestLabel.text = harvestDateString;
    [cell.harvestLabel setFont: [UIFont systemFontOfSize:11]];
    
    [cell.contentView addSubview:cell.plantLabel];
    [cell.contentView addSubview:cell.growingLabel];
    [cell.contentView addSubview:cell.harvestLabel];
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
        //NSLog(@"plantStr = %@", plantStr);
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
    //NSLog(@"%@ Array = %i", array, (int)array.count);
    return array;
}


@end
