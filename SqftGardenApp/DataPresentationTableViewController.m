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
#import "GrowToolBarView.h"



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
UIColor *summerColor;
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
    frostColor = [appGlobals colorFromHexString:@"#77ccd1"];
    summerColor = [appGlobals colorFromHexString:@"#f6c32c"];
    
    
    width = self.view.frame.size.width;
    daysPerPoint = ((width-20) / (15 + maxDays + abs(minDays)));
    height = self.view.frame.size.height;
    plantingDateAnchor = (SIDE_OFFSET + (abs(minDays) * daysPerPoint));
    if(plantingDateAnchor < 15)plantingDateAnchor = 15;
    NSLog(@"date anchor offset = %f", plantingDateAnchor);
    //UIView *plantingDateLine =
    //    [[UIView alloc]initWithFrame:CGRectMake(plantingDateAnchor, 80, 2, height-130)];
    //plantingDateLine.backgroundColor = [UIColor lightGrayColor];
    //[self.view addSubview:plantingDateLine];
    
    self.tableView.separatorColor = [UIColor clearColor];
    [self makeToolbar];
    [[UIApplication sharedApplication]
        setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];
    //[self.navigationController.view setTransform: CGAffineTransformMakeRotation(M_PI / 2)];
    //[self.view setTransform: CGAffineTransformMakeRotation(M_PI / 2)];
    //[self.navigationController.view setTransform: CGAffineTransformMakeRotation(M_PI / 2)];

}

-(void)calculateDateBounds:(NSArray *)array{
    boundsCalculated = YES;
    int min = 0;
    int max = 0;
    PlantIconView *plant;
    //NSNumber *plantIndex = [NSNumber numberWithInt:0];
    for(int i = 0; i < array.count; i++){
        //plantIndex = array[i];
        //plant = [[PlantIconView alloc]initWithFrame:CGRectMake(0,0,0,0) withPlantId:plantIndex.intValue isIsometric:NO];
        plant = array[i];
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
    PlantIconView *plant = [plantArray objectAtIndex:[indexPath row]];
    //NSNumber *plantId = plantArray[(int)[indexPath row]];
    
    //PlantIconView *plant = [[PlantIconView alloc]
    //                        initWithFrame:CGRectMake(0,0,0,0) withPlantId:plantId.intValue isIsometric:NO];
    NSDate *maturityDate = [appGlobals.globalGardenModel.plantingDate dateByAddingTimeInterval:60*60*24*plant.maturity];
    NSDate *plantingDate = [appGlobals.globalGardenModel.plantingDate dateByAddingTimeInterval:60*60*24*plant.plantingDelta];
    harvestDateString = [dateFormatter stringFromDate:maturityDate];
    harvestDateString = [NSString stringWithFormat:@"%@", harvestDateString];
    
    plantingDateString = [dateFormatter stringFromDate:plantingDate];
    plantingDateString = [NSString stringWithFormat:@"%@", plantingDateString];
    
    mainLabelString = plant.plantName;
    
    if(cell == nil){
        //NSLog(@"value of bounds %i", boundsCalculated);
        cell = [[PresentTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        height = cell.contentView.frame.size.height;
        cell.mainLabel = [[UILabel alloc]initWithFrame:CGRectMake(15,0,125,20)];
        cell.plantView = [[UIView alloc]initWithFrame:CGRectMake(0,20,25,height - 20)];
        cell.growingView = [[UIView alloc]initWithFrame:CGRectMake(25,20,125,height - 20)];
        cell.harvestView = [[UIView alloc]initWithFrame:CGRectMake(150,20,20,height - 20)];
        cell.frostView = [[UIView alloc]initWithFrame:CGRectMake(0,0,0,0)];
        cell.springView = [[UIView alloc]initWithFrame:CGRectMake(0,0,0,0)];
        cell.summerView = [[UIView alloc]initWithFrame:CGRectMake(0,0,0,0)];
        cell.autumnView = [[UIView alloc]initWithFrame:CGRectMake(0,0,0,0)];
        //cell.layer.cornerRadius = 10;
        //cell.layer.borderColor = [UIColor blackColor].CGColor;
        //cell.layer.borderWidth = 0;
        //cell.clipsToBounds = YES;
    }else{
        
    }

    CGRect adjustedFrame = CGRectMake(plantingDateAnchor + plant.plantingDelta, 13, 0, height - 20);
    cell.plantView.frame = adjustedFrame;
    cell.growingView.frame = CGRectMake(adjustedFrame.origin.x+10, 13,0, height -20);
    cell.harvestView.frame = CGRectMake(adjustedFrame.origin.x+(plant.maturity*daysPerPoint)+10, 13,0, height -20);
    
    cell.mainLabel.frame = CGRectMake(self.view.frame.origin.x+80,
                                      cell.growingView.frame.origin.y,
                                      cell.growingView.frame.size.width,
                                      cell.growingView.frame.size.height);
    cell.frostView.frame = CGRectMake(self.view.frame.origin.x + 5,
                                      0.5,
                                      plantingDateAnchor-5,
                                      height-1);
    cell.springView.frame = CGRectMake(-5,
                                      .5,
                                      (self.view.frame.size.width/2),
                                      height-1);
    //cell.summerView.frame = CGRectMake((self.view.frame.size.width/2)-5,
    //                         .5,
    //                        (self.view.frame.size.width/1.45)-((self.view.frame.size.width/1.45)*.5),
    //                         height-1);
    
    //temp size for summer to just push it off screen
    cell.summerView.frame = CGRectMake((self.view.frame.size.width/2)-5,
                                       .5, self.view.frame.size.width, height-1);
    cell.summerView.backgroundColor = summerColor;
    
    CAGradientLayer *frostGradient = [CAGradientLayer layer];
    frostGradient.startPoint = CGPointMake(0,0);
    frostGradient.endPoint = CGPointMake(1,0);
    frostGradient.frame = cell.frostView.bounds;
    frostGradient.colors = [NSArray arrayWithObjects:
                            (id)[frostColor CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    [cell.frostView.layer insertSublayer:frostGradient atIndex:0];
    
    
    CAGradientLayer *springGradient = [CAGradientLayer layer];
    springGradient.startPoint = CGPointMake(1,0);
    springGradient.endPoint = CGPointMake(0,0);
    springGradient.frame = cell.springView.bounds;
    springGradient.colors = [NSArray arrayWithObjects:
                             (id)[summerColor CGColor], (id)[UIColor whiteColor], nil];
    [cell.springView.layer insertSublayer:springGradient atIndex:0];
    cell.springView.alpha = .5;
    cell.summerView.alpha = .5;
    
    
    
    
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
    
    UILabel *harvestLabel = [[UILabel alloc]initWithFrame:CGRectMake(-20,16,40,15)];
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
    cell.mainLabel.text = mainLabelString;
    //[cell.mainLabel setTextAlignment:NSTextAlignmentCenter];
    
    cell.harvestView.alpha = 0;
    
    [cell.contentView addSubview:cell.frostView];
    [cell.contentView addSubview:cell.springView];
    [cell.contentView addSubview:cell.summerView];
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
        appGlobals.selectedPlant = [plantArray objectAtIndex:(int)[indexPath row]];
    
        [self.navigationController performSegueWithIdentifier:@"showBedDetail" sender:self];
    return;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    PresentTableCell *tableCell;
    if([cell class] == [PresentTableCell class]){
        tableCell = (PresentTableCell*)cell;
        //NSNumber *plantId = plantArray[(int)[indexPath row]];
        //PlantIconView *plant = [[PlantIconView alloc]
        //                        initWithFrame:CGRectMake(0,0,0,0) withPlantId:plantId.intValue isIsometric:NO];
        PlantIconView *plant = [plantArray objectAtIndex:[indexPath row]];
        [self animatePlantViewforCell:tableCell forPlant:plant];
    }
}






- (void)animatePlantViewforCell:(PresentTableCell*)cell forPlant:(PlantIconView*)plant{
    CGRect frame = CGRectMake(cell.plantView.frame.origin.x,
                              cell.plantView.frame.origin.y,
                              0,
                              cell.plantView.frame.size.height);
    
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         cell.plantView.frame = CGRectMake(frame.origin.x,frame.origin.y,10,frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if(finished)[self animateGrowViewforCell:cell forPlant:plant];
                     }];
}



- (void)animateGrowViewforCell:(PresentTableCell*)cell forPlant:(PlantIconView*)plant{
    CGRect frame = CGRectMake(cell.growingView.frame.origin.x,
                              cell.growingView.frame.origin.y,
                              0,
                              cell.growingView.frame.size.height);
    CGFloat duration = (plant.maturity*daysPerPoint)/120;
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         cell.growingView.frame = CGRectMake(frame.origin.x,frame.origin.y,(plant.maturity*daysPerPoint),frame.size.height);
                         cell.mainLabel.frame = CGRectMake(cell.growingView.frame.origin.x + 15,
                                                           cell.growingView.frame.origin.y,
                                                           cell.growingView.frame.size.width,
                                                           cell.growingView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if(finished)[self animateHarvestViewforCell:cell forPlant:plant];
                     }];
}
- (void)animateHarvestViewforCell:(PresentTableCell*)cell forPlant:(PlantIconView*)plant{
    CGRect frame = CGRectMake(cell.harvestView.frame.origin.x,
                              cell.harvestView.frame.origin.y,
                              0,
                              cell.harvestView.frame.size.height);
    
    [UIView animateWithDuration:0.30 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         cell.harvestView.alpha = 1;
                         cell.harvestView.frame = CGRectMake(frame.origin.x,
                                                             frame.origin.y,
                                                             20,
                                                             frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if(finished)return;
                     }];
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
    /*
    PlantIconView *cancelBtn = [[PlantIconView alloc]
                                initWithFrame:CGRectMake(self.view.frame.size.width - 55, 1, 44,44) withPlantId: -1 isIsometric:NO];
    cancelBtn.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleCancelSingleTap:)];
    [cancelBtn addGestureRecognizer:singleFingerTap];
     [headerView addSubview:cancelBtn];
    */
    
    [headerView addSubview:labelView];
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
-(void) showDatePickerView{
    
    if(self.datePickerIsOpen){
        [self setDatePickerIsOpen:NO];
        //[self.selectPlantView setDatePickerIsOpen:NO];
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.datePickerView.alpha = 0.0f;
                             self.tableView.alpha = 1.00f;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
        return;
    }
    [self setDatePickerIsOpen:YES];;
    self.datePickerView = [[DateSelectView alloc] init];
    self.datePickerView.userInteractionEnabled = YES;
    [self.datePickerView createDatePicker:self];
    
    CGRect fm = CGRectMake((self.view.frame.size.width-315)/2, self.view.frame.origin.y+80, 300, 44+216);
    self.datePickerView.frame = fm;
    
    self.datePickerView.alpha = 1.0f;
    [self.view addSubview:self.datePickerView];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.datePickerView.alpha = 1.0f;
                         self.datePickerView.backgroundColor = [UIColor whiteColor];
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (NSArray *)buildPlantArrayFromModel:(SqftGardenModel*)model{
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
    NSMutableArray *plantArray = [[NSMutableArray alloc]init];
    for(int i = 0; i < array.count; i++){
        NSString *str = [array objectAtIndex:i];
        PlantIconView *plant = [[PlantIconView alloc]initWithFrame:CGRectMake(0,0,0,0)
                                                       withPlantId:str.intValue isIsometric:NO];
        [plantArray addObject:plant];
    }

    NSArray *sorted = [self sortArray:plantArray ByKey:@"plantingDelta" Ascending:YES];
    //NSLog(@"%@ Array = %i", sorted, (int)array.count);
    return sorted;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //have to call this here for the toolbar to work.
    [self makeToolbar];
}

-(void)makeToolbar{
    //added an extra 20 points here because the table view offsets that much
    float toolBarYOrigin = self.view.frame.size.height-64;
    
    GrowToolBarView *toolBar = [[GrowToolBarView alloc] initWithFrame:CGRectMake(0,toolBarYOrigin,self.view.frame.size.width,44) andViewController:self];
    [toolBar setToolBarIsPinned:YES];
    toolBar.canOverrideDate = YES;
    [self.view addSubview:toolBar];
    [toolBar enableBackButton:YES];
    [toolBar enableMenuButton:NO];
    [toolBar enableDateButton:YES];
    [toolBar enableSaveButton:NO];
    [toolBar enableIsoButton:NO];
    [toolBar enableDateOverride:YES];
    }

- (NSArray *)sortArray:(NSArray *)array ByKey:(NSString *)key Ascending:(bool)ascending{

    NSArray *sortedPlants;    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key
                                                 ascending:ascending];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    sortedPlants = [array sortedArrayUsingDescriptors:sortDescriptors];
    return sortedPlants;
    //[self.tableView reloadData];
    
    
}





@end
