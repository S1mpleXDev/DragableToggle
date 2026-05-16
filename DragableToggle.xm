#import <UIKit/UIKit.h>
#import "DragableToggleView.h"

static DragableToggleView *toggleView = nil;
static BOOL isInitialized = NO;

%hook UIApplication

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL result = %orig;
    
    // Delay initialization to ensure app is fully loaded
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!isInitialized && application.keyWindow) {
            [self createToggleView:application];
            isInitialized = YES;
        }
    });
    
    return result;
}

%new
- (void)createToggleView:(UIApplication *)application {
    @try {
        UIWindow *mainWindow = application.keyWindow;
        
        if (!mainWindow) {
            // Fallback: try to get window from delegate
            if ([UIApplication sharedApplication].delegate && 
                [UIApplication sharedApplication].delegate.window) {
                mainWindow = [UIApplication sharedApplication].delegate.window;
            }
        }
        
        if (mainWindow && !toggleView) {
            toggleView = [[DragableToggleView alloc] initWithFrame:CGRectMake(20, 100, 60, 60)];
            [mainWindow addSubview:toggleView];
        }
    } @catch (NSException *exception) {
        // Silently catch errors to prevent crashes
        NSLog(@"[DragableToggle] Error initializing view: %@", exception.reason);
    }
}

%end

// Hook into UIViewController to handle window changes
%hook UIViewController

- (void)viewDidLoad {
    %orig;
    
    if (!isInitialized && [[UIApplication sharedApplication] keyWindow]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!toggleView) {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                if (window && !toggleView) {
                    toggleView = [[DragableToggleView alloc] initWithFrame:CGRectMake(20, 100, 60, 60)];
                    [window addSubview:toggleView];
                    isInitialized = YES;
                }
            }
        });
    }
}

%end

%ctor {
    @try {
        // Constructor - runs when dylib is loaded
        NSLog(@"[DragableToggle] Tweak loaded successfully");
    } @catch (NSException *exception) {
        NSLog(@"[DragableToggle] Constructor error: %@", exception.reason);
    }
}
