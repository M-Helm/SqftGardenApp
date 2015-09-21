//
//  DeleteButtonView.h
//  SqftGardenApp
//
//  Created by Matthew Helm on 9/21/15.
//  Copyright © 2015 Matthew Helm. All rights reserved.
//

#import<UIKit/UIKit.h>

@interface DeleteButtonView : UIView

@property(nonatomic) int localId;

- (id)initWithFrame:(CGRect)frame withPositionIndex: (int)localId;



@end
