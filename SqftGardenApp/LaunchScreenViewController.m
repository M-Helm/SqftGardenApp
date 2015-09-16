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
const int launchButtonDiskSize = 150;

- (void) viewDidLoad {
    [super viewDidLoad];
    appGlobals = [ApplicationGlobals getSharedGlobals];
    appGlobals.hasShownLaunchScreen = YES;
    self.navigationController.navigationBar.hidden = YES;
    //self.navigationController.navigationItem.hidesBackButton = YES;

    float height = self.view.bounds.size.height;
    float width = self.view.bounds.size.width;
    UIColor* color = [UIColor orangeColor];
    //UIColor* greenColor = [UIColor greenColor];
    
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
    fm.origin.y =  height*.10;
    
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
    fm.origin.y =  height*.10+175;
    
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
    UIView *aboutButton = [[UIImageView alloc]initWithFrame:
                           CGRectMake(width/16, 0, launchButtonDiskSize, launchButtonDiskSize)];
    CAShapeLayer *aboutCircle = [self drawCircleLayerWithRadius:launchButtonDiskSize/2
                                                        atPoint:CGPointMake(launchButtonDiskSize,launchButtonDiskSize)
                                                      withColor:color];
    [aboutButton.layer addSublayer:aboutCircle];
    [aboutButton addSubview:aboutLabel];
    [self.view addSubview:aboutButton];
    CGRect fm = aboutButton.frame;
    fm.origin.y =  height*.10+350;
    
    [UIView animateWithDuration:.75 animations:^{
        aboutButton.frame = fm;
    }];
    
}

- (void)handleNewSingleTap:(UITapGestureRecognizer *)recognizer{
    [self.navigationController performSegueWithIdentifier:@"showResize" sender:self];
    NSLog(@"left btn click");
    
}
- (void)handleOpenSingleTap:(UITapGestureRecognizer *)recognizer{
    //CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    [self.navigationController performSegueWithIdentifier:@"openBed" sender:self];
    NSLog(@"right btn click");
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
    circleLayer.fillColor = [UIColor whiteColor].CGColor;
    circleLayer.lineWidth   = 3.0;
    [self.view.layer addSublayer:circleLayer];
    return circleLayer;
}


@end