//
//  NativeLogin.h
//  Teacher
//
//  Created by Derrick Hathaway on 2/21/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
@import CanvasKeymaster;

@interface NativeLogin : RCTEventEmitter <CanvasKeymasterDelegate>

+ (instancetype)shared;

@end
