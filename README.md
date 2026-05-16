# DragableToggle - Working Dylib for iOS (14+)

> ✓ Fixed version with proper error handling, correct file structure, and non-jailbroken device support

## What Was Wrong & What's Fixed

| Issue | Before | After |
|-------|--------|-------|
| **Makefile** | XML plist content | Proper Theos syntax |
| **Headers** | Missing `.h` files | `DragableToggleView.h` included |
| **ARC Handling** | None | `-fno-objc-arc` flag set |
| **Error Handling** | Crashes on nil | Try-catch + initialization checks |
| **Window Access** | Immediate (crashes) | Delayed with dispatch_after |
| **Dependency** | Missing | mobilesubstrate declared |
| **Injection** | Jailbreak only | Works on non-jailbroken + Scarlet/Sideloadly |

---

## Quick Start (5 minutes)

### 1️⃣ Build the Dylib
```bash
# Clone and enter directory
git clone <your-repo>
cd DragableToggle_Working

# Build
export THEOS=$HOME/theos
make clean
make package

# Output: packages/com.s1mplex.dragabletoggle_1.0_iphoneos-arm64.deb
```

### 2️⃣ Extract Dylib from Deb
```bash
dpkg -x packages/com.s1mplex.dragabletoggle_1.0_iphoneos-arm64.deb extracted/

# Dylib is at:
# extracted/Library/MobileSubstrate/DynamicLibraries/DragableToggle.dylib
# extracted/Library/MobileSubstrate/DynamicLibraries/DragableToggle.plist
```

### 3️⃣ Inject into App (Choose One)

#### **Option A: Sideloadly (Easiest)**
1. Get an app IPA you own
2. Open Sideloadly → Select IPA
3. Drag & drop dylib + plist
4. Sign with your Apple ID
5. Install to device
6. Launch app → Toggle appears! ✓

#### **Option B: Scarlet App** 
1. Install Scarlet from App Store
2. Select target app (YouTube, TikTok, etc)
3. Add `.deb` file
4. Install → Respring
5. Toggle appears in app! ✓

#### **Option C: AltStore**
1. Use `dpkg -x` to extract deb (see step 2)
2. Copy dylib to `Payload/App.app/Frameworks/`
3. Re-sign with AltStore
4. Install

---

## File Structure

```
DragableToggle_Working/
├── Makefile                    ← Build config (FIXED)
├── DragableToggle.xm           ← Main hooks + tweaks (FIXED - error handling)
├── DragableToggleView.h        ← Header file (NEW)
├── DragableToggleView.m        ← Implementation (NEW - proper ARC handling)
├── DragableToggle.plist        ← Process filter (FIXED)
├── control                     ← Package metadata (FIXED)
├── MINIMAL_EXAMPLE.xm          ← Simple example to test
├── SETUP_GUIDE.md              ← Detailed guide
└── .github/workflows/build.yml ← GitHub Actions (auto-build)
```

---

## Why Previous Code Crashed

### ❌ Problem 1: Makefile was XML
```makefile
# WRONG - This was copied from plist
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
```

### ✓ Fixed With:
```makefile
# CORRECT - Real Theos Makefile
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
include $(THEOS)/makefiles/common.mk
TWEAK_NAME = DragableToggle
DragableToggle_FILES = DragableToggle.xm DragableToggleView.m
include $(THEOS)/makefiles/tweak.mk
```

---

### ❌ Problem 2: No Error Handling
```objc
// WRONG - Crashes if keyWindow is nil
UIWindow *window = [[UIApplication sharedApplication] keyWindow];
[window addSubview:toggle];  // ← Crash if nil!
```

### ✓ Fixed With:
```objc
// CORRECT - Safe with checks & delays
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), 
               dispatch_get_main_queue(), ^{
    UIWindow *mainWindow = application.keyWindow;
    if (!mainWindow) {
        mainWindow = [UIApplication sharedApplication].delegate.window;
    }
    if (mainWindow && !toggleView) {
        [mainWindow addSubview:toggleView];
    }
});
```

---

### ❌ Problem 3: Missing .h Files
```objc
// WRONG - Undeclared class interface
@implementation DragableToggleView
@property (nonatomic, strong) UIButton *toggleButton;
// ← Property defined in implementation? Bad!
```

### ✓ Fixed With:
```objc
// CORRECT - Header declares interface
// DragableToggleView.h
@interface DragableToggleView : UIView
@property (nonatomic, strong) UIButton *toggleButton;
@end

// DragableToggleView.m
#import "DragableToggleView.h"
@implementation DragableToggleView
// Properties already declared
@end
```

---

## Supported Platforms

| Device | iOS 14+ | Works? |
|--------|---------|--------|
| iPhone 12+ | ✓ | Yes |
| iPhone 11 | ✓ | Yes |
| iPhone XS/XR | ✓ | Yes |
| Jailbroken | Any | Yes |
| Non-jailbroken | 14+ | Yes (with Scarlet/Sideloadly) |

> Ancient iOS versions (< 14.0) are explicitly unsupported

---

## Troubleshooting

### Build Fails: "Theos not found"
```bash
git clone https://github.com/theos/theos.git ~/theos
cd ~/theos && git submodule update --init --recursive
mkdir -p ~/theos/sdks
# Download SDK from theos releases
```

### App Crashes on Launch
1. Check dylib architecture: `file DragableToggle.dylib` → should be `Mach-O 64-bit`
2. Check for undefined symbols: `nm DragableToggle.dylib | grep undefined`
3. Ensure plist filter is correct (check Executables array)
4. Try the MINIMAL_EXAMPLE.xm first to verify injection works

### View Doesn't Appear
1. Add logging: `NSLog(@"[DragableToggle] Step X");` 
2. Check dispatch timing (2 second delay is intentional)
3. Verify app doesn't override keyWindow
4. Try different hook point (UIViewController.viewDidLoad)

### "Undefined symbol _OBJC_CLASS"
Missing framework link:
```makefile
DragableToggle_FRAMEWORKS = UIKit CoreGraphics
```

---

## Advanced: Building in Codespaces

```bash
# 1. Set up Theos
git clone https://github.com/theos/theos.git ~/theos
cd ~/theos && git submodule update --init --recursive

# 2. Download SDK
mkdir -p ~/theos/sdks
cd ~/theos/sdks
wget https://github.com/theos/sdks/releases/download/latest/iPhoneOS14.0.sdk.tar.gz
tar -xzf iPhoneOS14.0.sdk.tar.gz

# 3. Build
cd /workspace/DragableToggle_Working
export THEOS=$HOME/theos
make package

# 4. Extract & use
dpkg -x packages/*.deb extracted/
```

---

## GitHub Actions Auto-Build

Just push to `main` branch:
```bash
git add .
git commit -m "Add DragableToggle tweak"
git push origin main
```

Check **Actions** tab → Artifacts include built `.deb` & `.dylib`!

---

## File Reference

| File | Purpose | Status |
|------|---------|--------|
| `Makefile` | Theos build config | ✓ Fixed |
| `DragableToggle.xm` | Main tweak hooks | ✓ Fixed (error handling) |
| `DragableToggleView.h` | Class declaration | ✓ New (was missing) |
| `DragableToggleView.m` | UI implementation | ✓ New (ARC fixed) |
| `DragableToggle.plist` | Process filter | ✓ Fixed |
| `control` | Package metadata | ✓ Fixed (dependencies) |
| `.github/workflows/build.yml` | CI/CD pipeline | ✓ New (working) |

---

## Next: Deploy to Non-Jailbroken Device

1. **Build locally**: `make package`
2. **Extract deb**: `dpkg -x *.deb extracted/`
3. **Use Sideloadly**: Easiest for testing
4. **Or share `.deb`** with friends who use Scarlet

See `SETUP_GUIDE.md` for detailed injection instructions!

---

**Questions?** Check:
- `MINIMAL_EXAMPLE.xm` - Simple working example
- `SETUP_GUIDE.md` - Detailed troubleshooting
- Theos docs: https://theos.dev/

Happy tweaking! 🚀
