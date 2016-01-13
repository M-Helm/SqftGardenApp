//
//  GrowToolBarView.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/28/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import "PetrolrToolBarView.h"
#import "ApplicationGlobals.h"



@interface PetrolrToolBarView()

@end

@implementation PetrolrToolBarView


UIViewController *viewController;
ApplicationGlobals *appGlobals;


- (id)initWithFrame:(CGRect)frame andViewController:(UIViewController*)controller{
    
    self = [super initWithFrame:frame];
    if (self) {
        viewController = controller;
        appGlobals = [ApplicationGlobals getSharedGlobals];
        self.toolBarTag = 72;
        self.toolBarIsPinned = NO;
        self.enableBackButton = NO;
        self.enableRouteButton = YES;
        self.enableStartButton = YES;
        self.enableButton3Button = YES;
        self.enableButton4Button = YES;
        [self commonInit];
    }
    return self;
}

-(void) commonInit{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableToolBar) name:@"notifyButtonPressed" object:nil];
    self.toolBarIsEnabled = YES;
    self.routeIconView = [self makeRouteIconView];
    self.startIconView = [self makeStartIcon];
    self.button3IconView = [self makeButton3Icon];
    self.button4IconView = [self makeButton4Icon];
    self.backButtonIconView = [self makeBackButtonIcon];
    
    [self addSubview:self.routeIconView];
    [self addSubview:self.startIconView];
    [self addSubview:self.button3IconView];
    [self addSubview:self.button4IconView];
    [self addSubview:self.backButtonIconView];
    
}


-(void)enableToolBar{
    if(self.toolBarIsEnabled)self.toolBarIsEnabled = NO;
    else self.toolBarIsEnabled = YES;
    for(UIView* subview in self.subviews){
        subview.userInteractionEnabled = self.toolBarIsEnabled;
    }
}

-(void)enableBackButton:(bool)enabled{
    self.enableBackButton = enabled;
    if(self.enableBackButton)self.backButtonIconView.alpha = 1;
    else self.backButtonIconView.alpha = .3;
}
-(void)enableRouteButton:(bool)enabled{
    self.enableRouteButton = enabled;
    if(self.enableRouteButton)self.routeIconView.alpha = 1;
    else self.routeIconView.alpha = .3;
}
-(void)enableStartButton:(bool)enabled{
    self.enableStartButton = enabled;
    if(self.enableStartButton)self.startIconView.alpha = 1;
    else self.startIconView.alpha = .3;
}
-(void)enableButton3Button:(bool)enabled{
    self.enableButton3Button = enabled;
    if(self.enableButton3Button)self.button3IconView.alpha = 1;
    else self.button3IconView.alpha = .3;
}
-(void)enableButton4Button:(bool)enabled{
    self.enableButton4Button = enabled;
    if(self.enableButton4Button)self.button4IconView.alpha = 1;
    else self.button4IconView.alpha = .3;
}

-(void) showToolBar{
    //NSLog(@"show tool bar");
    if(self.toolBarIsPinned)return;
    CGRect frame = CGRectMake(self.frame.origin.x,viewController.view.frame.size.height - 44,self.frame.size.width,self.frame.size.height);
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         if(finished){
                             //do something?
                         }
                     }];
}
-(void) hideToolBar{
    //NSLog(@"hide tool bar");
    if(self.toolBarIsPinned)return;
    CGRect frame = CGRectMake(self.frame.origin.x,viewController.view.frame.size.height+44,self.frame.size.width,self.frame.size.height);
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         if(finished){
                             //do something?
                         }
                     }];
}
- (void)clickAnimationIn:(UIView *)subview{
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         //subview.alpha = .5;
                         subview.backgroundColor = [UIColor lightGrayColor];
                     }
                     completion:^(BOOL finished) {
                         if(finished){
                             [self clickAnimationout:subview];
                         }
                     }];
}
-(void)clickAnimationout:(UIView *)subview{
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         //subview.alpha = 1;
                         subview.backgroundColor = [UIColor clearColor];
                     }
                     completion:^(BOOL finished) {
                         if(finished){
                             //recognizer.view.alpha = 1;
                         }
                     }];
}
- (UIView *)makeRouteIconView{
    int toolbarPosition = 2;
    float iconWidth = (viewController.view.frame.size.width/5);
    
    //float navBarHeight = self.navigationController.navigationBar.bounds.size.height *  1.5;
    self.routeIconView = [[UIView alloc]initWithFrame:CGRectMake((viewController.view.frame.size.width/5)*toolbarPosition,
                                                               self.frame.size.height-44, iconWidth, 44)];
    
    self.routeIconView.userInteractionEnabled = YES;
    
    UIImage *icon = [UIImage imageNamed:@"ic_isometric_256px.png"];
    UIImageView *isoIcon = [[UIImageView alloc] initWithImage:icon];
    
    
    //isoIcon.frame = CGRectMake(10,5,24,24);
    CGRect frame = CGRectMake((iconWidth/2)-12,5,24,24);
    isoIcon.frame = frame;
    isoIcon.layer.borderColor = [UIColor blackColor].CGColor;
    isoIcon.layer.borderWidth = 1;
    isoIcon.layer.cornerRadius = 5;
    isoIcon.userInteractionEnabled = YES;
    isoIcon.clipsToBounds = NO;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((iconWidth/2)-22,30,44,10)];
    [label setFont:[UIFont systemFontOfSize:11]];
    label.text = @"3d View";
    
    isoIcon.tag = self.toolBarTag;
    label.tag = self.toolBarTag;
    self.routeIconView.tag = self.toolBarTag;
    
    [self.routeIconView addSubview:label];
    [self.routeIconView addSubview:isoIcon];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleRouteIconSingleTap:)];
    [self.routeIconView addGestureRecognizer:singleFingerTap];
    return self.routeIconView;
}
-(UIView *)makeBackButtonIcon{
    int toolbarPosition = 0;
    float iconWidth = (viewController.view.frame.size.width/5);
    //remove self if exists
    if(self.backButtonIconView != nil)[self.backButtonIconView removeFromSuperview];
    
    self.backButtonIconView = [[UIView alloc]initWithFrame:CGRectMake((viewController.view.frame.size.width/5)*toolbarPosition,
                                                                self.frame.size.height-44, iconWidth, 44)];
    //make and add view
    UIImage *icon = [UIImage imageNamed:@"ic_backbutton_128px.png"];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:icon];
    //CGRect frame = CGRectMake(0,0,38,38);
    CGRect frame = CGRectMake((iconWidth/2)-12,3,25,25);
    imageView.frame = frame;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((iconWidth/2)-22,30,44,10)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:11]];
    label.text = @"Back";
    self.backButtonIconView.userInteractionEnabled = YES;
    
    imageView.tag = self.toolBarTag;
    label.tag = self.toolBarTag;
    self.backButtonIconView.tag = self.toolBarTag;
    if(!self.enableBackButton)self.backButtonIconView.alpha = .3;
    
    [self.backButtonIconView addSubview:label];
    [self.backButtonIconView addSubview:imageView];
    UITapGestureRecognizer *backButtonSingleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleBackButtonSingleTap:)];
    [self.backButtonIconView addGestureRecognizer:backButtonSingleFingerTap];
    
    return self.backButtonIconView;
}

-(UIView *)makeButton4Icon{
    int toolbarPosition = 4;
    float iconWidth = (viewController.view.frame.size.width/5);
    //remove self if exists
    if(self.button4IconView != nil)[self.button4IconView removeFromSuperview];
    
    self.button4IconView = [[UIView alloc]initWithFrame:CGRectMake((viewController.view.frame.size.width/5)*toolbarPosition,
                                                                self.frame.size.height-44, iconWidth, 44)];
    //make and add view
    UIImage *icon = [UIImage imageNamed:@"ic_burger_44.png"];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:icon];
    //CGRect frame = CGRectMake(3,0,38,38);
    CGRect frame = CGRectMake((iconWidth/2)-19,-2,38,38);
    imageView.frame = frame;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((iconWidth/2)-22,30,44,10)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:11]];
    label.text = @"More";
    self.button4IconView.userInteractionEnabled = YES;
    
    imageView.tag = self.toolBarTag;
    label.tag = self.toolBarTag;
    self.button4IconView.tag = self.toolBarTag;
    
    
    [self.button4IconView addSubview:label];
    [self.button4IconView addSubview:imageView];
    UITapGestureRecognizer *menuSingleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleButton4IconSingleTap:)];
    [self.button4IconView addGestureRecognizer:menuSingleFingerTap];
    
    return self.button4IconView;
}


-(UIView *)makeButton3Icon{
    int toolbarPosition = 3;
    float iconWidth = (viewController.view.frame.size.width/5);
    //remove self if exists
    if(self.button3IconView != nil)[self.button3IconView removeFromSuperview];
    
    self.button3IconView = [[UIView alloc]initWithFrame:CGRectMake((viewController.view.frame.size.width/5)*toolbarPosition,
                                                                self.frame.size.height-44, iconWidth, 44)];
    //make and add view
    UIImage *icon = [UIImage imageNamed:@"ic_save_512px.png"];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:icon];
    //CGRect frame = CGRectMake(3,0,38,38);
    CGRect frame = CGRectMake((iconWidth/2)-19,0,38,38);
    imageView.frame = frame;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((iconWidth/2)-22,30,44,10)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:11]];
    label.text = @"Save";
    self.button3IconView.userInteractionEnabled = YES;
    
    imageView.tag = self.toolBarTag;
    label.tag = self.toolBarTag;
    self.button3IconView.tag = self.toolBarTag;
    
    
    [self.button3IconView addSubview:label];
    [self.button3IconView addSubview:imageView];
    UITapGestureRecognizer *saveSingleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleButton3IconSingleTap:)];
    [self.button3IconView addGestureRecognizer:saveSingleFingerTap];
    
    return self.button3IconView;
}

-(UIView *)makeStartIcon{
    int toolbarPosition = 1;
    float iconWidth = (viewController.view.frame.size.width/5);
    if(self.startIconView != nil)[self.startIconView removeFromSuperview];
    
    self.startIconView = [[UIView alloc]initWithFrame:
                         CGRectMake((viewController.view.frame.size.width/5)*toolbarPosition,
                                    self.frame.size.height-44,
                                    (viewController.view.frame.size.width/5),
                                    44)];
    
    UIImage *icon = [UIImage imageNamed:@"ic_edit_date_512px.png"];
    //CGRect fm = CGRectMake(5,-3,34,34);
    CGRect frame = CGRectMake((iconWidth/2)-17,-3,34,34);
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    imageView.frame = frame;
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((iconWidth/2)-22,30,44,10)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:11]];
    label.text = @"Cal";
    
    imageView.userInteractionEnabled = YES;
    imageView.tag = self.toolBarTag;
    label.tag = self.toolBarTag;
    self.startIconView.tag = self.toolBarTag;
    
    
    [self.startIconView addSubview:label];
    [self.startIconView addSubview:imageView];

    
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleStartIconSingleTap:)];
    [self.startIconView addGestureRecognizer:singleFingerTap];
    return self.startIconView;
}

- (void)handleBackButtonSingleTap:(UITapGestureRecognizer *)recognizer {
    if(!self.enableBackButton)return;
    [self clickAnimationIn:recognizer.view];

    [viewController.navigationController popViewControllerAnimated:YES];
        
}


                                   

- (void)handleRouteIconSingleTap:(UITapGestureRecognizer *)recognizer {
    if(!self.enableRouteButton)return;
    [self clickAnimationIn:recognizer.view];
    
}
- (void)handleStartIconSingleTap:(UITapGestureRecognizer *)recognizer {
    if(!self.enableStartButton)return;
    [self clickAnimationIn:recognizer.view];

}

- (void)handleButton3IconSingleTap:(UITapGestureRecognizer *)recognizer {
    if(!self.enableButton3Button)return;
    //if(appGlobals.isMenuDrawerOpen == YES)return;
    [self clickAnimationIn:recognizer.view];
    
}

- (void)handleButton4IconSingleTap:(UITapGestureRecognizer *)recognizer {
    if(!self.enableButton4Button)return;
    [self clickAnimationIn:recognizer.view];

}

@end
