#ifndef DragableToggleView_h
#define DragableToggleView_h

#import <UIKit/UIKit.h>

@interface DragableToggleView : UIView

@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) BOOL isPanning;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)handlePan:(UIPanGestureRecognizer *)gesture;
- (void)togglePanel;
- (void)setupUI;

@end

#endif /* DragableToggleView_h */
