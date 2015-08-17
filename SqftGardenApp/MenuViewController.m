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
        //NSLog(@"NEW BED segue Called");
        [appGlobals clearCurrentBedState];
        [self.navigationController performSegueWithIdentifier:@"showMain" sender:self.navigationController];
        return;
    }
    //[appGlobals setCurrentBedState:json];
}

@end
