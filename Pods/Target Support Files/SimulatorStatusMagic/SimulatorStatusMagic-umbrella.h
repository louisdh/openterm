#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SDStatusBarManager.h"
#import "SDStatusBarOverrider.h"
#import "SDStatusBarOverriderPost10_0.h"
#import "SDStatusBarOverriderPost10_3.h"
#import "SDStatusBarOverriderPost11_0.h"
#import "SDStatusBarOverriderPost8_3.h"
#import "SDStatusBarOverriderPost9_0.h"
#import "SDStatusBarOverriderPost9_3.h"
#import "SDStatusBarOverriderPre8_3.h"

FOUNDATION_EXPORT double SimulatorStatusMagicVersionNumber;
FOUNDATION_EXPORT const unsigned char SimulatorStatusMagicVersionString[];

