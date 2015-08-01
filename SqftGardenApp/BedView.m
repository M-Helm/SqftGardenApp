//
//  BedView.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 5/1/15.
//  Copyright (c) 2015 Matthew Helm. All rights reserved.
//

#import "BedView.h"

@interface BedView ()

@end

@implementation BedView

const int BED_DEFAULT_BORDER = 3;
const int BED_DEFAULT_CORNER = 15;

- (id)initWithFrame:(CGRect)frame : (int) plantId{
    self = [super initWithFrame:frame];
    self.primaryPlant = plantId;
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
    self.layer.borderWidth = BED_DEFAULT_BORDER;
    self.layer.cornerRadius = BED_DEFAULT_CORNER;
}

- (void) setSecondaryPlant {
    
}
- (void) setTertiaryPlant {
    
}

@end