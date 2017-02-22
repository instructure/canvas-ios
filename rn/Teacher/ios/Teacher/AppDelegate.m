/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"

#import "RCTBundleURLProvider.h"
#import "RCTRootView.h"
#import "NativeLogin.h"

@import CanvasKeymaster;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  TheKeymaster.delegate = [NativeLogin shared];
  
  [TheKeymaster.signalForLogout subscribeNext:^(UIViewController * _Nullable x) {
    NSLog(@"what??!");
    self.window.rootViewController = x;
  }];
  [TheKeymaster.signalForLogin subscribeNext:^(CKIClient * _Nullable client) {
    NSURL *jsCodeLocation;
    jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];
    
    NSDictionary *props = @{
      @"authToken": client.accessToken,
      @"user": client.currentUser.JSONDictionary
    };
    
    RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                        moduleName:@"Teacher"
                                                 initialProperties:props
                                                     launchOptions:launchOptions];
    rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
    
    UIViewController *rootViewController = [UIViewController new];
    rootViewController.view = rootView;
    self.window.rootViewController = rootViewController;
  }];
  
  [self.window makeKeyAndVisible];
  return YES;
}

@end
