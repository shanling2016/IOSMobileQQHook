TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = QQLingHookPreferences

QQLingHookPreferences_FILES = LingRootListController.m
QQLingHookPreferences_FRAMEWORKS = UIKit
QQLingHookPreferences_PRIVATE_FRAMEWORKS = Preferences
QQLingHookPreferences_INSTALL_PATH = /Library/PreferenceBundles
QQLingHookPreferences_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk