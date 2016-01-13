
#import <UIKit/UIKit.h>




@interface PetrolrToolBarView : UIToolbar

- (id)initWithFrame:(CGRect)frame andViewController:(UIViewController*)controller;
- (void) showToolBar;
- (void) hideToolBar;
- (void) enableToolBar;

- (void) enableRouteButton:(bool)enabled;
- (void) enableBackButton:(bool)enabled;
- (void) enableStartButton:(bool)enabled;
- (void) enableButton3Button:(bool)enabled;
- (void) enableButton4Button:(bool)enabled;


@property(nonatomic) UIView *routeIconView;
@property(nonatomic) UIView *backButtonIconView;
@property(nonatomic) UIView *startIconView;
@property(nonatomic) UIView *button3IconView;
@property(nonatomic) UIView *button4IconView;

@property(nonatomic) int toolBarTag;
@property(nonatomic) bool toolBarIsPinned;
@property(nonatomic) bool toolBarIsEnabled;


@property(nonatomic) bool enableRouteButton;
@property(nonatomic) bool enableBackButton;
@property(nonatomic) bool enableStartButton;
@property(nonatomic) bool enableButton3Button;
@property(nonatomic) bool enableButton4Button;


@end
