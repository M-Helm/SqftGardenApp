//
//  LaunchScreenViewController.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/15/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "LaunchScreenViewController.h"
#import "ApplicationGlobals.h"


@interface LaunchScreenViewController()

@end

@implementation LaunchScreenViewController
ApplicationGlobals *appGlobals;
const int launchButtonDiskSize = 120;
const int launchButtonSeperator = launchButtonDiskSize + 10;
UIFont * launchButtonFont;

- (void) viewDidLoad {
    [super viewDidLoad];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    appGlobals.hasShownLaunchScreen = NO;
    self.navigationController.navigationBar.hidden = YES;
    //self.navigationController.navigationItem.hidesBackButton = YES;


    float height = self.view.bounds.size.height;
    float width = self.view.bounds.size.width;
    UIColor* color = [UIColor orangeColor];
    launchButtonFont = [UIFont boldSystemFontOfSize:13];
    
    UIImage *background = [UIImage imageNamed:@"cloth_test.png"];
    UIImageView *bk = [[UIImageView alloc]initWithImage:background];
    bk.alpha = .05;
    bk.frame = self.view.frame;
    [self.view addSubview:bk];
    //UIColor *bkColor = [[UIColor whiteColor]colorWithAlphaComponent:.5];
    //self.view.backgroundColor = bkColor;
    
    UIImage *logo = [UIImage imageNamed:@"growLogo_v002.png"];
    UIImageView *logoBox = [[UIImageView alloc]initWithImage: logo];
    logoBox.frame = CGRectMake(0,25,width,width/3);
    [self.view addSubview:logoBox];
    
    
    [self makeAboutGardenButtonWithWidth:width withHeight:height withColor: color];
    [self makeOpenGardenButtonWithWidth:width withHeight:height withColor: color];
    [self makeNewGardenButtonWithWidth:width withHeight:height withColor: color];
    


}
-(void)makeNewGardenButtonWithWidth:(float)width
                                withHeight:(float) height
                                withColor:(UIColor *)color{
    //Create a New Garden Button
    UILabel *newLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0,launchButtonDiskSize,launchButtonDiskSize)];
    newLabel.text = @"New Garden Plan";
    newLabel.textAlignment = NSTextAlignmentCenter;
    [newLabel setFont:launchButtonFont];
    UIView *newButton = [[UIView alloc]initWithFrame:CGRectMake(width/16, 0, launchButtonDiskSize, launchButtonDiskSize)];
    CAShapeLayer *newCircle = [self drawCircleLayerWithRadius:launchButtonDiskSize/2
                                                      atPoint:CGPointMake(launchButtonDiskSize,launchButtonDiskSize)
                                                    withColor:color];
    [newButton.layer addSublayer:newCircle];
    [newButton addSubview:newLabel];
    newButton.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleFingerTapNew =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleNewSingleTap:)];
    [newButton addGestureRecognizer:singleFingerTapNew];
    [self.view addSubview:newButton];
    CGRect fm = newButton.frame;
    fm.origin.y =  width/3+10;
    
    [UIView animateWithDuration:1 animations:^{
        newButton.frame = fm;
    }];

    
}
-(void)makeOpenGardenButtonWithWidth:(float)width
                         withHeight:(float) height
                          withColor:(UIColor *)color{
    UILabel *openLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0,launchButtonDiskSize,launchButtonDiskSize)];
    openLabel.text = @"Open Garden Plan";
    openLabel.textAlignment = NSTextAlignmentCenter;
    [openLabel setFont:launchButtonFont];
    UIView *openButton = [[UIImageView alloc]initWithFrame:
                          CGRectMake(width/16, 0, launchButtonDiskSize, launchButtonDiskSize)];
    CAShapeLayer *openCircle = [self drawCircleLayerWithRadius:launchButtonDiskSize/2
                                                       atPoint:CGPointMake(launchButtonDiskSize,launchButtonDiskSize)
                                                     withColor:color];
    [openButton.layer addSublayer:openCircle];
    [openButton addSubview:openLabel];
    openButton.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleFingerTapOpen =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleOpenSingleTap:)];
    [openButton addGestureRecognizer:singleFingerTapOpen];
    [self.view addSubview:openButton];
    CGRect fm = openButton.frame;
    fm.origin.y =  width/3+10+launchButtonSeperator;
    
    [UIView animateWithDuration:1.2 animations:^{
        openButton.frame = fm;
    }];
}
-(void)makeAboutGardenButtonWithWidth:(float)width
                          withHeight:(float) height
                           withColor:(UIColor *)color{
    //Create an About Grow^2 Button
    UILabel *aboutLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0,launchButtonDiskSize,launchButtonDiskSize)];
    aboutLabel.text = @"About Grow\u00B2";
    aboutLabel.textAlignment = NSTextAlignmentCenter;
    [aboutLabel setFont:launchButtonFont];
    UIView *aboutButton = [[UIImageView alloc]initWithFrame:
                           CGRectMake(width/16, 0, launchButtonDiskSize, launchButtonDiskSize)];
    CAShapeLayer *aboutCircle = [self drawCircleLayerWithRadius:launchButtonDiskSize/2
                                                        atPoint:CGPointMake(launchButtonDiskSize,launchButtonDiskSize)
                                                      withColor:color];
    [aboutButton.layer addSublayer:aboutCircle];
    [aboutButton addSubview:aboutLabel];
    aboutButton.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleFingerTapOpen =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleAboutSingleTap:)];
    [aboutButton addGestureRecognizer:singleFingerTapOpen];
    [self.view addSubview:aboutButton];
    CGRect fm = aboutButton.frame;
    fm.origin.y =  width/3+10+(launchButtonSeperator*2);
    
    [UIView animateWithDuration:.75 animations:^{
        aboutButton.frame = fm;
    }];
    
}

- (void)handleNewSingleTap:(UITapGestureRecognizer *)recognizer{
    
    NSLog(@"left btn click");
    UIView *btn = (UIView*)recognizer.view;
    CGRect fm = btn.frame;
    fm.origin.x += 355;
    
    [UIView animateWithDuration:.35 animations:^{
        btn.frame = fm;
    }completion:^(BOOL finished){
        [self.navigationController performSegueWithIdentifier:@"showResize" sender:self];
    }];
    
}
- (void)handleOpenSingleTap:(UITapGestureRecognizer *)recognizer{
    //CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    NSLog(@"right btn click");
    UIView *btn = (UIView*)recognizer.view;
    CGRect fm = btn.frame;
    fm.origin.x += 355;
    
    [UIView animateWithDuration:.35 animations:^{
        btn.frame = fm;
        }completion:^(BOOL finished){
            [self.navigationController performSegueWithIdentifier:@"openBed" sender:self];
    }];

}

- (void)handleAboutSingleTap:(UITapGestureRecognizer *)recognizer{
    //CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    NSLog(@"right btn click");
    UIView *btn = (UIView*)recognizer.view;
    CGRect fm = btn.frame;
    fm.origin.x += 355;
    
    [UIView animateWithDuration:.35 animations:^{
        btn.frame = fm;
    }completion:^(BOOL finished){
        [self.navigationController performSegueWithIdentifier:@"showLegal" sender:self];
    }];
    
}

-(CAShapeLayer *)drawCircleLayerWithRadius:(float)radius atPoint:(CGPoint) center withColor:(UIColor *)color{
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:center
                                                          radius:radius
                                                      startAngle:0
                                                        endAngle:2.0*M_PI
                                                       clockwise:YES];
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.bounds = CGRectMake(0, 0, 2.0*radius, 2.0*radius);
    circleLayer.path   = circle.CGPath;
    //circleLayer.strokeColor = [UIColor orangeColor].CGColor;
    circleLayer.strokeColor =  color.CGColor;
    UIColor *fill = [[UIColor whiteColor]colorWithAlphaComponent:.5];
    circleLayer.fillColor = fill.CGColor;
    circleLayer.lineWidth   = 3.0;
    [self.view.layer addSublayer:circleLayer];
    return circleLayer;
}


@end