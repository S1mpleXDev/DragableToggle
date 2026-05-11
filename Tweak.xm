#import <UIKit/UIKit.h>

@interface DragableToggle : UIView
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) BOOL isOn;
@end

@implementation DragableToggle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
        self.layer.cornerRadius = 20;           // Smooth rounded corners like iOS apps
        self.layer.masksToBounds = YES;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 4);
        self.layer.shadowOpacity = 0.3;
        self.layer.shadowRadius = 8;

        self.label = [[UILabel alloc] initWithFrame:self.bounds];
        self.label.text = @"OFF";
        self.label.textColor = [UIColor whiteColor];
        self.label.font = [UIFont boldSystemFontOfSize:16];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label];

        self.isOn = NO;

        // Drag gesture
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];

        // Tap to toggle
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleState)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.superview];
    self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self.superview];
}

- (void)toggleState {
    self.isOn = !self.isOn;
    
    if (self.isOn) {
        self.backgroundColor = [UIColor colorWithRed:0.2 green:0.8 blue:0.4 alpha:1.0];
        self.label.text = @"ON";
    } else {
        self.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
        self.label.text = @"OFF";
    }
    
    // Simple scale animation
    [UIView animateWithDuration:0.1 animations:^{
        self.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.transform = CGAffineTransformIdentity;
        }];
    }];
}

@end

%hook UIApplication

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL result = %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DragableToggle *toggle = [[DragableToggle alloc] initWithFrame:CGRectMake(50, 100, 80, 80)];
        [[UIApplication sharedApplication].keyWindow addSubview:toggle];
    });

    return result;
}

%end
