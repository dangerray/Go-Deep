//
//  DRCommon.h
//  Deep Link Helper
//
//  Created by Sibley on 9/28/13.
//  Copyright (c) 2013 Dr. Jon's Danger Ray, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GVUserDefaults+DRUserDefaults.h"
#import "Mixpanel.h"

@interface DRCommon : NSObject

#if TARGET_IPHONE_SIMULATOR
#define HTAssertSimulatorOnly(condition, ...) NSAssert(condition, __VA_ARGS__)
#else
#define HTAssertSimulatorOnly(condition, ...)
#endif

#if TARGET_IPHONE_SIMULATOR
#define HTAssertAlwaysSimulatorOnly(...) NSAssert(0, @"%@", __VA_ARGS__)
#else
#define HTAssertAlwaysSimulatorOnly(...)
#endif

@end
