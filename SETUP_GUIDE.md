# DragableToggle - Non-Jailbroken Device Injection Guide

## ✓ What Fixed Your Crashes

Your original code had these issues:
1. **Improper Makefile** - Was showing plist XML instead of Theos Makefile syntax
2. **Missing header files** - No `.h` declarations (best practice)
3. **Missing ARC handling** - Needed `-fno-objc-arc` flag
4. **Weak error handling** - No try-catch or initialization checks
5. **UIWindow timing issue** - Trying to access keyWindow too early
6. **Missing mobilesubstrate** - Not declared as dependency

---

## File Structure (Now Correct)

```
DragableToggle/
├── Makefile                          (Theos build configuration)
├── DragableToggle.xm                 (Logos hooks + tweaks)
├── DragableToggleView.h              (Header declarations)
├── DragableToggleView.m              (Implementation)
├── DragableToggle.plist              (Process filter)
├── control                           (Package metadata)
└── .github/workflows/build.yml       (GitHub Actions build)
```

---

## How to Use This on Non-Jailbroken Devices

### Option 1: **Scarlet** (Easiest - No PC needed)
1. Get built `.deb` from releases
2. Open Scarlet app on iOS
3. Select the target app (e.g., YouTube, TikTok)
4. Install the `.deb` through Scarlet
5. Respring/restart app

### Option 2: **AltStore** (Requires PC/Mac)
1. Get built `.deb`
2. On Mac: Use `dpkg -x tweak.deb extracted/` to extract
3. Copy dylib to your resigned IPA at: `Payload/App.app/Frameworks/`
4. Use AltStore to install modified IPA
5. Respring

### Option 3: **Sideloadly** (Most Compatible)
1. Extract deb: `dpkg -x com.s1mplex.dragabletoggle_1.0_iphoneos-arm64.deb extracted/`
2. Find dylib at: `extracted/Library/MobileSubstrate/DynamicLibraries/DragableToggle.dylib`
3. In Sideloadly:
   - Select target IPA
   - Add dylib and plist files via "Add Files"
   - Sign and install
4. App will load tweak on launch

### Option 4: **TrollStore** (If Jailbroken Alternative)
1. Install `.deb` directly through TrollStore
2. Select app to inject into
3. Respring

---

## Building Locally

### Requirements
```bash
# macOS
brew install theos

# Ubuntu/Codespaces
git clone https://github.com/theos/theos.git ~/theos
cd ~/theos && git submodule update --init --recursive
mkdir -p ~/theos/sdks
# Download iPhoneOS14.0.sdk.tar.gz from theos/sdks releases
```

### Build Command
```bash
export THEOS=$HOME/theos
make clean
make package
# Output: packages/com.s1mplex.dragabletoggle_1.0_iphoneos-arm64.deb
```

### Extract Dylib from Deb
```bash
dpkg -x com.s1mplex.dragabletoggle_1.0_iphoneos-arm64.deb extracted/
# Dylib location: extracted/Library/MobileSubstrate/DynamicLibraries/DragableToggle.dylib
```

---

## Key Code Improvements Explained

### 1. Proper Makefile
```makefile
ARCHS = arm64 arm64e                    # Support modern devices
TARGET = iphone:clang:latest:14.0       # iOS 14+
DragableToggle_CFLAGS = -fno-objc-arc   # Manual memory management
DragableToggle_FRAMEWORKS = UIKit       # Link UIKit
```

### 2. Error Handling (Prevents Crashes)
```objc
- (void)createToggleView:(UIApplication *)application {
    @try {
        // Safe initialization with checks
        if (!mainWindow) {
            mainWindow = [UIApplication sharedApplication].delegate.window;
        }
        if (mainWindow && !toggleView) {
            // Create view only once
        }
    } @catch (NSException *exception) {
        NSLog(@"[DragableToggle] Error: %@", exception.reason);
    }
}
```

### 3. Dual Hook Points
- `UIApplication didFinishLaunching` - Initial window setup
- `UIViewController viewDidLoad` - Fallback for window access

### 4. Header Files (Best Practice)
```objc
// DragableToggleView.h
@interface DragableToggleView : UIView
@property (nonatomic, strong) UIButton *toggleButton;
@end
```

This prevents undefined symbol errors and makes code maintainable.

---

## Troubleshooting

### Dylib crashes on inject:
- ✓ Check compatibility: `otool -L built.dylib` - should show libobjc, UIKit
- ✓ Verify architecture: `file built.dylib` - must be `arm64` or `arm64e`
- ✓ Ensure mobilesubstrate dependency in `control` file

### View doesn't appear:
- ✓ Add logging: `NSLog(@"[DragableToggle] View created");`
- ✓ Check for early keyWindow access (use dispatch_after delay)
- ✓ Verify app doesn't override root view controller

### "Undefined symbol" error:
- ✓ Missing framework link: Add to Makefile `DragableToggle_FRAMEWORKS = UIKit`
- ✓ Missing header import: Check `#import` statements
- ✓ Check .xm file syntax (Logos comments: `%hook`, `%orig`, `%end`)

### Deb extraction fails:
```bash
# Ensure proper format
dpkg-deb -l com.s1mplex.dragabletoggle_1.0_iphoneos-arm64.deb
# Should show: control, data files
```

---

## GitHub Actions Setup

The `.github/workflows/build.yml` automatically:
1. ✓ Installs Theos + iOS SDK
2. ✓ Compiles .xm + .m files
3. ✓ Creates `.deb` package
4. ✓ Uploads artifacts (accessible in Actions tab)

Just push to main branch - build runs automatically!

---

## Security Notes

For non-jailbroken injection tools (Scarlet/Sideloadly):
- Apps are re-signed with your dev account certificate
- Dylib is embedded before signing
- Takes certificate + device UDID
- Process is reversible (reinstall original app)

---

## Next Steps

1. **Test locally**: `make package` and extract the deb
2. **Use Sideloadly**: Easiest for first test on non-jailbroken device
3. **Push to GitHub**: Automated builds in Actions tab
4. **Distribute**: Share `.deb` on releases page

Let me know if you hit any build errors! 🚀
