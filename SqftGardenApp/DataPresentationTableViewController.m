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

- (void)viewDidLoad {
    [super viewDidLoad];
    dbManager = [DBManager getSharedDBManager];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    plantArray = [[NSArray alloc]
                  initWithArray: [self buildPlantArrayFromModel:appGlobals.globalGardenModel]];
    dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
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
    
    PlantIconView *plant = [[PlantIconView alloc]
                            initWithFrame:CGRectMake(0,0,0,0) withPlantId:(int)[indexPath row]+1];
    NSDate *maturityDate = [appGlobals.globalGardenModel.plantingDate dateByAddingTimeInterval:60*60*24*plant.maturity];
    harvestDateString = [dateFormatter stringFromDate:maturityDate];
    harvestDateString = [NSString stringWithFormat:@"Harvest on or about: %@", harvestDateString];
    
    mainLabelString = plant.plantName;
    
    if(cell == nil){
        cell = [[PresentTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.mainLabel = [[UILabel alloc]initWithFrame:CGRectMake(15,0,125,20)];
        cell.harvestLabel = [[UILabel alloc]initWithFrame:CGRectMake(126,0,300,20)];
    }else{
    
    }

    cell.mainLabel.text = mainLabelString;
    cell.harvestLabel.text = harvestDateString;
    [cell.harvestLabel setFont: [UIFont systemFontOfSize:11]];
    
    
    [cell.contentView addSubview:cell.mainLabel];
    [cell.contentView addSubview:cell.harvestLabel];
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

- (NSMutableArray *)buildPlantArrayFromModel:(SqftGardenModel*)model{
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
