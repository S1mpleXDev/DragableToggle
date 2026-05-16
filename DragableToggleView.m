#import "DragableToggleView.h"
#import <UIKit/UIKit.h>

@implementation DragableToggleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.isPanning = NO;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // Create draggable toggle button
    self.toggleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.toggleButton.frame = CGRectMake(0, 0, 60, 60);
    self.toggleButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:1.0];
    self.toggleButton.layer.cornerRadius = 30;
    self.toggleButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.toggleButton.layer.shadowOpacity = 0.3;
    self.toggleButton.layer.shadowOffset = CGSizeMake(0, 2);
    self.toggleButton.layer.shadowRadius = 5;
    self.toggleButton.clipsToBounds = NO;
    
    // Setup button text
    [self.toggleButton setTitle:@"▶" forState:UIControlStateNormal];
    [self.toggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.toggleButton.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    
    // Add gesture recognizers
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.toggleButton addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePanel)];
    [self.toggleButton addGestureRecognizer:tap];
    
    [self addSubview:self.toggleButton];
    
    // Create panel with content
    self.panel = [[UIView alloc] initWithFrame:CGRectMake(-150, 50, 300, 300)];
    self.panel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
    self.panel.layer.cornerRadius = 15;
    self.panel.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:0.5].CGColor;
    self.panel.layer.borderWidth = 1;
    self.panel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.panel.layer.shadowOpacity = 0.5;
    self.panel.layer.shadowOffset = CGSizeMake(0, 4);
    self.panel.layer.shadowRadius = 10;
    self.panel.hidden = YES;
    self.panel.clipsToBounds = NO;
    
    // Add status label to panel
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 280, 50)];
    self.statusLabel.text = @"Tweak Loaded\n✓ Ready";
    self.statusLabel.numberOfLines = 2;
    self.statusLabel.textColor = [UIColor whiteColor];
    self.statusLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.panel addSubview:self.statusLabel];
    
    // Add close button
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(275, 10, 25, 25);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [closeBtn addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
    [self.panel addSubview:closeBtn];
    
    [self addSubview:self.panel];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self.superview];
        CGPoint newCenter = CGPointMake(self.toggleButton.center.x + translation.x,
                                       self.toggleButton.center.y + translation.y);
        self.toggleButton.center = newCenter;
        self.center = newCenter;
        [gesture setTranslation:CGPointZero inView:self.superview];
    }
}

- (void)togglePanel {
    self.panel.hidden = !self.panel.hidden;
    if (!self.panel.hidden) {
        [UIView animateWithDuration:0.3 animations:^{
            self.panel.alpha = 1.0;
        }];
    }
}

@end
