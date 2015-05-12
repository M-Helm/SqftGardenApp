//
//  PlantSelectView.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/12/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "SelectPlantView.h"

@implementation SelectPlantView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [self commonInit];
}

- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    [self setDefaultParameters];
    [self setScrollView];
}

- (void) setDefaultParameters{
    self.color = [UIColor lightGrayColor];
    self.fillColor = [self.color colorWithAlphaComponent:0.25];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 3;
    self.layer.cornerRadius = 15;
}

- (void) setScrollView{
    
        // Adjust scroll view content size
        self.contentSize = CGSizeMake(self.frame.size.width * 3,
                                            self.frame.size.height);
        self.pagingEnabled=NO;
        self.backgroundColor = [UIColor whiteColor];
        
        // Generate content for our scroll view using the frame height and width as the reference point
    
        /*
        int i = 0;
        while (i<=2) {
            
            UIView *views = [[UIView alloc]
                             initWithFrame:CGRectMake(((self.frame.size.width)*i)+20, 10,
                                                      (self.frame.size.width)-40, self.frame.size.height-20)];
            //views.backgroundColor=[UIColor yellowColor];
            [views setTag:i];
            [self addSubview:views];
            
            i++;
         
        }
        */
    
    }


@end
