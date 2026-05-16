#import <UIKit/UIKit.h>
#import "DragableToggleView.h"

static DragableToggleView *toggleView = nil;
static BOOL isInitialized = NO;

// Helper function to safely get main window (iOS 13+ compatible)
static UIWindow* getMainWindow(void) {
    @try {
        // iOS 13+ way
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
                if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                    for (UIWindow *window in windowScene.windows) {
                        if (window.isKeyWindow) {
                            return window;
                        }
                    }
                }
            }
        }
        
        // Fallback for iOS 12 and below
        return [[UIApplication sharedApplication] keyWindow];
    } @catch (NSException *exception) {
        NSLog(@"[DragableToggle] Error getting window: %@", exception.reason);
        return nil;
    }
}

// Safe initialization
static void initializeToggleView(void) {
    @try {
        if (isInitialized || toggleView) {
            return;
        }
        
        UIWindow *mainWindow = getMainWindow();
        if (!mainWindow) {
            // Try delegate window as last resort
            if ([UIApplication sharedApplication].delegate && 
                [UIApplication sharedApplication].delegate.window) {
                mainWindow = [UIApplication sharedApplication].delegate.window;
            }
        }
        
        if (mainWindow) {
            toggleView = [[DragableToggleView alloc] initWithFrame:CGRectMake(20, 100, 60, 60)];
            [mainWindow addSubview:toggleView];
            isInitialized = YES;
            NSLog(@"[DragableToggle] View initialized successfully");
        }
    } @catch (NSException *exception) {
        NSLog(@"[DragableToggle] Initialization error: %@", exception.reason);
    }
}

%hook UIApplication

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL result = %orig;
    
    // Delay to ensure app is fully loaded
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        initializeToggleView();
    });
    
    return result;
}

%end

// Hook into UIWindow to catch window creation
%hook UIWindow

- (void)makeKeyAndVisible {
    %orig;
    
    if (!isInitialized) {
        dispatch_async(dispatch_get_main_queue(), ^{
            initializeToggleView();
        });
    }
}

%end

%ctor {
    NSLog(@"[DragableToggle] Dylib loaded successfully");
}
