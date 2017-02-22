//
//  NativeLogin.h
//  Teacher
//
//  Created by Derrick Hathaway on 2/21/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"
@import CanvasKeymaster;

@interface NativeLogin : NSObject <RCTBridgeModule, CanvasKeymasterDelegate>
+ (instancetype)shared;

- (void)logout;
@end
