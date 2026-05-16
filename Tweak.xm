#import <UIKit/UIKit.h>

@interface DragableToggleView : UIView
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) UIView *panel;
@end

@implementation DragableToggleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.toggleButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.toggleButton.frame = CGRectMake(0, 0, 60, 60);
        self.toggleButton.backgroundColor = [UIColor systemBlueColor];
        self.toggleButton.layer.cornerRadius = 18;
        [self.toggleButton setTitle:@"▶" forState:UIControlStateNormal];
        [self.toggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.toggleButton.titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self.toggleButton addGestureRecognizer:pan];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePanel)];
        [self.toggleButton addGestureRecognizer:tap];
        
        [self addSubview:self.toggleButton];
        
        // Create panel
        self.panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
        self.panel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
        self.panel.layer.cornerRadius = 20;
        self.panel.hidden = YES;
        [self addSubview:self.panel];
    }
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.superview];
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x, gesture.view.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self.superview];
}

- (void)togglePanel {
    self.panel.hidden = !self.panel.hidden;
}

@end

%hook UIApplication

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL result = %orig;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DragableToggleView *toggle = [[DragableToggleView alloc] initWithFrame:CGRectMake(50, 200, 60, 60)];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:toggle];
    });
    
    return result;
}

%end
