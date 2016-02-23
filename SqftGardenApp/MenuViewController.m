//
//  MainViewController.h
//  SqftGardenApp
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "MenuViewController.h"
#import "ApplicationGlobals.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

ApplicationGlobals *appGlobals;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    appGlobals = [ApplicationGlobals getSharedGlobals];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([indexPath row] == 0){
        [appGlobals clearCurrentGardenModel];
        [self.navigationController performSegueWithIdentifier:@"showMain" sender:self.navigationController];
        return;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    tableView.separatorColor = [UIColor clearColor];
    cell.layer.backgroundColor= [UIColor blackColor].CGColor;
    cell.layer.cornerRadius = 15;
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [MenuViewController class]){
        //PlantIconView *plantView = (PlantIconView*)[touch view];
        

        
        //AudioServicesPlaySystemSound(1104);
    }
}

@end
