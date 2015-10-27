//
//  GrowToolBarView.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/28/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import "GrowToolBarView.h"
#import "EditBedViewController.h"
#import "DataPresentationTableViewController.h"
#import "ApplicationGlobals.h"

@interface GrowToolBarView()

@end

@implementation GrowToolBarView


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
        self.enableMenuButton = YES;
        self.enableDateButton = YES;
        self.enableIsoButton = YES;
        self.enableSaveButton = YES;
        [self commonInit];
    }
    return self;
}

-(void) commonInit{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableToolBar) name:@"notifyButtonPressed" object:nil];
    self.toolBarIsEnabled = YES;
    [self checkPlantingDate];
    self.isoIconView = [self makeIsoIconView];
    self.saveIconView = [self makeSaveIcon];
    self.dateIconView = [self makeDateIcon];
    self.menuIconView = [self makeMenuIcon];
    self.backButtonIconView = [self makeBackButtonIcon];
    
    [self addSubview:self.dateIconView];
    [self addSubview:self.isoIconView];
    [self addSubview:self.saveIconView];
    [self addSubview:self.menuIconView];
    [self addSubview:self.backButtonIconView];
    //if(self.dateSelected == NO){
    //    if([viewController class] == [EditBedViewController class]){
    //        EditBedViewController* vc = (EditBedViewController*)viewController;
    //        if(vc.isoViewIsOpen)[self enableDateButton:NO];
    //    }
    //}
    
}

-(void)enableToolBar{
    if(self.toolBarIsEnabled)self.toolBarIsEnabled = NO;
    else self.toolBarIsEnabled = YES;
    for(UIView* subview in self.subviews){
        subview.userInteractionEnabled = self.toolBarIsEnabled;
    }
}

 
 -(void)checkPlantingDate{
     //check if a date exists
     if(appGlobals.globalGardenModel.frostDate != nil){
         NSDate *compareDate = [[NSDate alloc]initWithTimeIntervalSince1970:2000];
         if([appGlobals.globalGardenModel.frostDate compare:compareDate] == NSOrderedAscending) {
             //no date selected
             self.dateSelected = NO;
         }else{
             //a date is selected
             self.dateSelected = YES;
         }
     }else{
         // something bad has happened.
         // planting date should never be nil - handle error
     }
 }

-(void)enableBackButton:(bool)enabled{
    self.enableBackButton = enabled;
    if(self.enableBackButton)self.backButtonIconView.alpha = 1;
    else self.backButtonIconView.alpha = .3;
}
-(void)enableMenuButton:(bool)enabled{
    self.enableMenuButton = enabled;
    if(self.enableMenuButton)self.menuIconView.alpha = 1;
    else self.menuIconView.alpha = .3;
}
-(void)enableDateButton:(bool)enabled{
    self.enableDateButton = enabled;
    if(self.enableDateButton)self.dateIconView.alpha = 1;
    else self.dateIconView.alpha = .3;
}
-(void)enableIsoButton:(bool)enabled{
    self.enableIsoButton = enabled;
    if(self.enableIsoButton)self.isoIconView.alpha = 1;
    else self.isoIconView.alpha = .3;
}
-(void)enableSaveButton:(bool)enabled{
    self.enableSaveButton = enabled;
    if(self.enableSaveButton)self.saveIconView.alpha = 1;
    else self.saveIconView.alpha = .3;
}
-(void)enableDateOverride:(bool)canOverrideDate{
    self.canOverrideDate = canOverrideDate;
    [self.dateIconView removeFromSuperview];
    self.dateIconView = [self makeDateIcon];
    [self addSubview:self.dateIconView];
    self.dateIconView.alpha = 1;
    //if(self.enableSaveButton)self.saveIconView.alpha = 1;
    //else self.saveIconView.alpha = .3;
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
- (UIView *)makeIsoIconView{
    int toolbarPosition = 2;
    float iconWidth = (viewController.view.frame.size.width/5);
    
    //float navBarHeight = self.navigationController.navigationBar.bounds.size.height *  1.5;
    self.isoIconView = [[UIView alloc]initWithFrame:CGRectMake((viewController.view.frame.size.width/5)*toolbarPosition,
                                                               self.frame.size.height-44, iconWidth, 44)];
    
    self.isoIconView.userInteractionEnabled = YES;
    
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
    self.isoIconView.tag = self.toolBarTag;
    
    [self.isoIconView addSubview:label];
    [self.isoIconView addSubview:isoIcon];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleIsoIconSingleTap:)];
    [self.isoIconView addGestureRecognizer:singleFingerTap];
    return self.isoIconView;
}
-(UIView *)makeBackButtonIcon{
    int toolbarPosition = 0;
    float iconWidth = (viewController.view.frame.size.width/5);
    //remove self if exists
    if(self.backButtonIconView != nil)[self.saveIconView removeFromSuperview];
    
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
    self.saveIconView.userInteractionEnabled = YES;
    
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

-(UIView *)makeMenuIcon{
    int toolbarPosition = 4;
    float iconWidth = (viewController.view.frame.size.width/5);
    //remove self if exists
    if(self.menuIconView != nil)[self.saveIconView removeFromSuperview];
    
    self.menuIconView = [[UIView alloc]initWithFrame:CGRectMake((viewController.view.frame.size.width/5)*toolbarPosition,
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
    self.saveIconView.userInteractionEnabled = YES;
    
    imageView.tag = self.toolBarTag;
    label.tag = self.toolBarTag;
    self.menuIconView.tag = self.toolBarTag;
    
    
    [self.menuIconView addSubview:label];
    [self.menuIconView addSubview:imageView];
    UITapGestureRecognizer *menuSingleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleMenuIconSingleTap:)];
    [self.menuIconView addGestureRecognizer:menuSingleFingerTap];
    
    return self.menuIconView;
}


-(UIView *)makeSaveIcon{
    int toolbarPosition = 3;
    float iconWidth = (viewController.view.frame.size.width/5);
    //remove self if exists
    if(self.saveIconView != nil)[self.saveIconView removeFromSuperview];
    
    self.saveIconView = [[UIView alloc]initWithFrame:CGRectMake((viewController.view.frame.size.width/5)*toolbarPosition,
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
    self.saveIconView.userInteractionEnabled = YES;
    
    imageView.tag = self.toolBarTag;
    label.tag = self.toolBarTag;
    self.saveIconView.tag = self.toolBarTag;
    
    
    [self.saveIconView addSubview:label];
    [self.saveIconView addSubview:imageView];
    UITapGestureRecognizer *saveSingleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSaveIconSingleTap:)];
    [self.saveIconView addGestureRecognizer:saveSingleFingerTap];
    
    return self.saveIconView;
}

-(UIView *)makeDateIcon{
    int toolbarPosition = 1;
    float iconWidth = (viewController.view.frame.size.width/5);
    if(self.dateIconView != nil)[self.dateIconView removeFromSuperview];
    
    self.dateIconView = [[UIView alloc]initWithFrame:
                         CGRectMake((viewController.view.frame.size.width/5)*toolbarPosition,
                                    self.frame.size.height-44,
                                    (viewController.view.frame.size.width/5),
                                    44)];
    
    UIImage *icon = [UIImage imageNamed:@"ic_edit_date_512px.png"];
    //CGRect fm = CGRectMake(5,-3,34,34);
    CGRect frame = CGRectMake((iconWidth/2)-17,-3,34,34);
    
    if(self.dateSelected && !self.canOverrideDate){
        icon = [UIImage imageNamed:@"ic_sequence_128px.png"];
        frame = CGRectMake((iconWidth/2)-17,0,34,34);
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    imageView.frame = frame;
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((iconWidth/2)-22,30,44,10)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:11]];
    label.text = @"Cal";
    if(self.dateSelected && !self.canOverrideDate)label.text = @"Seq";
    
    imageView.userInteractionEnabled = YES;
    imageView.tag = self.toolBarTag;
    label.tag = self.toolBarTag;
    self.dateIconView.tag = self.toolBarTag;
    
    
    [self.dateIconView addSubview:label];
    [self.dateIconView addSubview:imageView];

    
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleDateIconSingleTap:)];
    [self.dateIconView addGestureRecognizer:singleFingerTap];
    return self.dateIconView;
}

- (void)handleBackButtonSingleTap:(UITapGestureRecognizer *)recognizer {
    if(!self.enableBackButton)return;
    [self clickAnimationIn:recognizer.view];
    //[viewController.navigationController popToRootViewControllerAnimated:YES];

    [viewController.navigationController popViewControllerAnimated:YES];
        
}
                                   

- (void)handleDateIconSingleTap:(UITapGestureRecognizer *)recognizer {
    if(!self.enableDateButton)return;
    [self clickAnimationIn:recognizer.view];
    if(self.canOverrideDate){
        if([viewController class] == [DataPresentationTableViewController class]){
            DataPresentationTableViewController *dataVC = (DataPresentationTableViewController*)viewController;
            [dataVC showDatePickerView];
            return;
        }
    }
    
    //check if a date exists
    if(appGlobals.globalGardenModel.frostDate != nil){
        
        NSDate *compareDate = [[NSDate alloc]initWithTimeIntervalSince1970:2000];
        if ([appGlobals.globalGardenModel.frostDate compare:compareDate] == NSOrderedAscending) {
            //no date selected
        }else{
            //date selected go somewhere else...
            [viewController.navigationController performSegueWithIdentifier:@"showPresent" sender:self];
            return;
        }
    }
    
    if([viewController class] == [EditBedViewController class]){
        EditBedViewController *editBedVC = (EditBedViewController*)viewController;
        [editBedVC showDatePickerView];
    }
    
}
- (void)handleMenuIconSingleTap:(UITapGestureRecognizer *)recognizer {
    if(!self.enableMenuButton)return;
    [self clickAnimationIn:recognizer.view];
    if([viewController class] == [EditBedViewController class]){
        EditBedViewController *editBedVC = (EditBedViewController*)viewController;
        bool success = [editBedVC.currentGardenModel saveModelWithOverWriteOption:YES];
        //NSLog(@"save icon tapped %i", success);
        if(success){
            [appGlobals setGlobalGardenModel:editBedVC.currentGardenModel];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyButtonPressed" object:self];
            //[editBedVC showWriteSuccessAlertForFile:editBedVC.currentGardenModel.name atIndex:editBedVC.currentGardenModel.localId];
        }
    }
}

- (void)handleSaveIconSingleTap:(UITapGestureRecognizer *)recognizer {
    if(!self.enableSaveButton)return;
    //if(appGlobals.isMenuDrawerOpen == YES)return;
    [self clickAnimationIn:recognizer.view];
    if([viewController class] == [EditBedViewController class]){
        EditBedViewController *editBedVC = (EditBedViewController*)viewController;
        bool success = [editBedVC.currentGardenModel saveModelWithOverWriteOption:YES];
        //NSLog(@"save icon tapped %i", success);
        if(success){
            [editBedVC showWriteSuccessAlertForFile:editBedVC.currentGardenModel.name atIndex:editBedVC.currentGardenModel.localId];
            [appGlobals setGlobalGardenModel:editBedVC.currentGardenModel];
        }
    }
}


- (void)handleIsoIconSingleTap:(UITapGestureRecognizer *)recognizer {
    if(!self.enableIsoButton)return;
    //NSLog(@"handle iso singletap");
    [self clickAnimationIn:recognizer.view];
    if([viewController class] == [EditBedViewController class]){
        EditBedViewController *editBedVC = (EditBedViewController*)viewController;
   
        if(editBedVC.isoViewIsOpen){
            [editBedVC.isoView unwindIsoViewTransform];
            [editBedVC showSelectView];
            [self enableDateButton:YES];
            return;
        }
    
        [editBedVC setIsoViewIsOpen:YES];
        [editBedVC.selectPlantView setIsoViewIsOpen:YES];
        [self enableDateButton:NO];
        //bool success = [self.currentGardenModel saveModelWithOverWriteOption:YES];
        [appGlobals setGlobalGardenModel:editBedVC.currentGardenModel];
        //NSLog(@"iso icon tapped");
        editBedVC.isoView = [[IsometricView alloc]initWithFrame:CGRectMake(0,0,viewController.view.frame.size.width, viewController.view.frame.size.height - 44) andEditBedVC:viewController];
        editBedVC.isoView.alpha = 1;
        //editBedVC.isoView.backgroundColor = [UIColor lightGrayColor];
        editBedVC.bedFrameView.alpha = 0.0;
        //editBedVC.selectPlantView.alpha = .25;
        //editBedVC.selectMessageView.alpha = .25;
        [editBedVC hideSelectView];
        [editBedVC.view addSubview:editBedVC.isoView];
    }
}

@end
