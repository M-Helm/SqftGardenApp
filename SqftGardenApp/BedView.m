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

const int BEDVIEW_DEFAULT_BORDER = 1;
const int BEDVIEW_DEFAULT_CORNER = 10;

- (id)initWithFrame:(CGRect)frame isIsometric:(bool)isIso{
    self = [super initWithFrame:frame];
    if (self) {
        self.isIso = isIso;
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
    self.backgroundColor = [UIColor clearColor];
    [self setDefaultParameters];
}

- (void) setDefaultParameters{

    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = BEDVIEW_DEFAULT_BORDER;
    self.layer.cornerRadius = BEDVIEW_DEFAULT_CORNER;
}

// Coordinate utilities
- (CGPoint) offsetPointToParentCoordinates: (CGPoint) aPoint
{
    return CGPointMake(aPoint.x + self.center.x,
                       aPoint.y + self.center.y);
}

- (CGPoint) pointInViewCenterTerms: (CGPoint) aPoint
{
    return CGPointMake(aPoint.x - self.center.x,
                       aPoint.y - self.center.y);
}

- (CGPoint) pointInTransformedView: (CGPoint) aPoint
{
    CGPoint offsetItem = [self pointInViewCenterTerms:aPoint];
    CGPoint updatedItem = CGPointApplyAffineTransform(
                                                      offsetItem, self.transform);
    CGPoint finalItem =
    [self offsetPointToParentCoordinates:updatedItem];
    return finalItem;
}

- (CGRect) originalFrame
{
    CGAffineTransform currentTransform = self.transform;
    self.transform = CGAffineTransformIdentity;
    CGRect originalFrame = self.frame;
    self.transform = currentTransform;
    
    return originalFrame;
}

// These four methods return the positions of view elements
// with respect to the current transform

- (CGPoint) transformedTopLeft
{
    CGRect frame = self.originalFrame;
    CGPoint point = frame.origin;
    return [self pointInTransformedView:point];
}

- (CGPoint) transformedTopRight
{
    CGRect frame = self.originalFrame;
    CGPoint point = frame.origin;
    point.x += frame.size.width;
    return [self pointInTransformedView:point];
}

- (CGPoint) transformedBottomRight
{
    CGRect frame = self.originalFrame;
    CGPoint point = frame.origin;
    point.x += frame.size.width;
    point.y += frame.size.height;
    return [self pointInTransformedView:point];
}

- (CGPoint) transformedBottomLeft
{
    CGRect frame = self.originalFrame;
    CGPoint point = frame.origin;
    point.y += frame.size.height;
    return [self pointInTransformedView:point];
}


@end