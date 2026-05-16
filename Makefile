THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222

ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DragableToggle
DragableToggle_FILES = DragableToggle.xm DragableToggleView.m
DragableToggle_CFLAGS = -fno-objc-arc -Wall -Werror
DragableToggle_FRAMEWORKS = UIKit CoreGraphics
DragableToggle_PRIVATE_FRAMEWORKS = UIKit

include $(THEOS)/makefiles/tweak.mk

after-install::
	install.exec "killall -9 $(TWEAK_NAME)" 2>/dev/null || true
