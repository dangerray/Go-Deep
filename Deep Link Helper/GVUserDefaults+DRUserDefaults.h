//
//  GVUserDefaults+DRUserDefaults.h
//  Deep Link Helper
//
//  Created by Sibley on 9/29/13.
//  Copyright (c) 2013 Dr. Jon's Danger Ray, Inc. All rights reserved.
//

#import "GVUserDefaults.h"

@interface GVUserDefaults (DRUserDefaults)

@property (nonatomic, assign) BOOL didSeedDataOnce;
@property (nonatomic, assign) BOOL didLaunchOnce;

@end
