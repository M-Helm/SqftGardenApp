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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == 0){
        [appGlobals clearCurrentGardenModel];
        [self.navigationController performSegueWithIdentifier:@"showMain" sender:self.navigationController];
        return;
    }
}
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches Began in MENU VC");
    UITouch *touch = [[event allTouches] anyObject];
    UIView *touchedView;
    if([touch view] != nil){
        touchedView = [touch view];
    }
    if ([touchedView class] == [MenuViewController class]){
        //PlantIconView *plantView = (PlantIconView*)[touch view];
        
        NSLog(@"Touches Began in MENU VC (INNER)");
        
        //AudioServicesPlaySystemSound(1104);
    }
}

@end
