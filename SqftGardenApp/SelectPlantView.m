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
}

- (void) setDefaultParameters{
    self.color = [UIColor lightGrayColor];
    self.fillColor = [self.color colorWithAlphaComponent:0.25];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 3;
    self.layer.cornerRadius = 15;
}


@end
