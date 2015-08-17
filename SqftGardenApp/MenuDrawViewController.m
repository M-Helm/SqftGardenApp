//
//  MainViewController.h
//  SqftGardenApp
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "MenuDrawViewController.h"
#import "MenuViewController.h"


@interface MenuDrawerViewController ()
@property(nonatomic, weak) MenuViewController* menuDrawViewController;
@end

@implementation MenuDrawerViewController

+ (id)getSharedMenuDrawer {
    static MenuDrawerViewController *sharedMenuDrawer = nil;
    @synchronized(self) {
        if (sharedMenuDrawer  == nil)
            sharedMenuDrawer  = [[self alloc] init];
        //NSLog(@"%s", __PRETTY_FUNCTION__);
    }
    return sharedMenuDrawer ;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"Menu Prepare Segue");
    if([segue.identifier isEqualToString:@"embedMenu"])
    {
        MenuViewController* menuViewController = segue.destinationViewController;
        menuViewController.menuDrawerViewController = self;
        self.menuDrawViewController = menuViewController;
    }
}

- (void)showEditView{
    [self.menuDrawViewController performSegueWithIdentifier:@"showMain" sender:self.menuDrawViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"menu draw view loaded");
    
    [self.menuDrawViewController performSegueWithIdentifier:@"showMain" sender:self.menuDrawViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slideDrawer:) name:@"notifyButtonPressed" object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)slideDrawer:(id)sender
{
    //[_view layoutIfNeeded];
    //float w = self.content.view.bounds.size.width;
    
    if(self.content.view.frame.origin.x > 0)
    {
        [self closeDrawer];
    }
    else
    {
        [self openDrawer];
    }
}
-(void)openDrawer
{
    //float w = self.content.view.bounds.size.width;
    CGRect fm = self.content.view.frame;
    fm.origin.x = 240.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.content.view.frame = fm;
    }];
}

-(void)closeDrawer
{
    //float w = self.content.view.bounds.size.width;
    CGRect fm = self.content.view.frame;
    fm.origin.x = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.content.view.frame = fm;
    }];
}
-(void)setContent:(UIViewController *)content
{
    if(_content)
    {
        [_content.view removeFromSuperview];
        [_content removeFromParentViewController];
        
        content.view.frame = _content.view.frame;
    }
    
    _content = content;
    [self addChildViewController:_content];
    [_content didMoveToParentViewController:self];
    [self.view addSubview:_content.view];
    [self closeDrawer];
}

@end