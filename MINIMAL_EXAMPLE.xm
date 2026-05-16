// ========================
// MINIMAL DYLIB EXAMPLE
// ========================
// This is a super simple tweak that just shows an alert
// Use this to verify your build chain works first

// File: MinimalTweak.xm
#import <UIKit/UIKit.h>

%hook UIApplication

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL result = %orig;
    
    // Show alert after 2 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController 
            alertControllerWithTitle:@"Tweak Works! ✓" 
            message:@"Dylib injected successfully" 
            preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIViewController *rootVC = window.rootViewController;
        [rootVC presentViewController:alert animated:YES completion:nil];
    });
    
    return result;
}

%end

%ctor {
    NSLog(@"[MinimalTweak] Dylib loaded!");
}


// ========================
// WHY THIS WORKS
// ========================
// ✓ Simple hook (UIApplication)
// ✓ Uses %orig (calls original method)
// ✓ Delayed dispatch (gives app time to launch)
// ✓ Safe window access
// ✓ Has %ctor (constructor - runs when loaded)
// ✓ Has try-catch protection (implicitly in %ctor)


// ========================
// BUILD IT
// ========================
// 1. Copy this as MinimalTweak.xm
// 2. Create simple Makefile:
/*

ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MinimalTweak
MinimalTweak_FILES = MinimalTweak.xm
MinimalTweak_FRAMEWORKS = UIKit

include $(THEOS)/makefiles/tweak.mk

*/
// 3. Run: make clean && make package


// ========================
// WHAT YOUR CODE WAS MISSING
// ========================
// ❌ No header file (.h) - causes linker warnings
// ❌ No try-catch in hooks - crashes if anything fails
// ❌ Accessing keyWindow too early - nil pointer
// ❌ No %ctor - don't know if dylib loaded
// ❌ Missing -fno-objc-arc flag - memory issues
// ❌ No delay (dispatch_after) - race condition
// ❌ Makefile showing plist instead of actual Makefile


// ========================
// .H FILES ARE IMPORTANT
// ========================
// Example proper flow:

/*
// ViewHelper.h
#import <UIKit/UIKit.h>

@interface ViewHelper : NSObject
+ (void)addViewToWindow:(UIView *)view;
@end


// ViewHelper.m
#import "ViewHelper.h"

@implementation ViewHelper

+ (void)addViewToWindow:(UIView *)view {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window) {
        [window addSubview:view];
    }
}

@end


// Tweak.xm
#import "ViewHelper.h"

%hook UIApplication
- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)opts {
    BOOL result = %orig;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [ViewHelper addViewToWindow:myView];
    });
    
    return result;
}
%end

// Makefile
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MyTweak
MyTweak_FILES = Tweak.xm ViewHelper.m
MyTweak_FRAMEWORKS = UIKit

include $(THEOS)/makefiles/tweak.mk
*/

// ========================
// LOGOS SYNTAX CHEAT SHEET
// ========================
// %hook ClassName
//   - Says "hook into this class"
// %orig
//   - Calls original method, get return value
// %new
//   - Add new method to class
// %property
//   - Add property
// %end
//   - End hook block
// %ctor
//   - Constructor, runs when dylib loads
// %dtor
//   - Destructor, runs when dylib unloads
