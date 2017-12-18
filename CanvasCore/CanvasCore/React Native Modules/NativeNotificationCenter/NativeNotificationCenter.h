//
//  NativeNotificationCenter.h
//  CanvasCore
//
//  Created by Nathan Armstrong on 12/15/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

extern NSString * const AsyncActionNotificationName;

@interface NativeNotificationCenter : NSObject<RCTBridgeModule>

@end
