//
//  DeleteButtonView.m
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/21/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import "DeleteButtonView.h"
#import "ApplicationGlobals.h"

@interface DeleteButtonView()

@end


@implementation DeleteButtonView

ApplicationGlobals *appGlobals;

- (id)initWithFrame:(CGRect)frame withPositionIndex: (int)localId{
    self = [super initWithFrame:frame];
    self.localId = localId;
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit{
    appGlobals = [[ApplicationGlobals alloc] init];
    
    //create and add our delete icon
    UIImage *baseIcon = [UIImage imageNamed:@"ic_cancel_256px.png"];
    CGSize size = CGSizeMake(22, 22);
    UIImage *icon = [appGlobals imageWithImage:baseIcon scaledToSize:size];
    UIImageView *deleteIcon = [[UIImageView alloc] initWithImage:icon];
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:deleteIcon];

}

@end
