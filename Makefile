THEOS_DEVICE_IP =
THEOS_DEVICE_PORT =

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DragableToggle

DragableToggle_FILES = Tweak.xm
DragableToggle_FRAMEWORKS = UIKit Foundation CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk
