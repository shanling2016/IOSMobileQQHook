THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222

TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = QQLingHook

QQLingHook_FILES = Tweak.x
QQLingHook_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

$(TWEAK_NAME)_FRAMEWORKS = AudioToolbox

SUBPROJECTS += qqlinghookpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
