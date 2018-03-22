//
//  NativeFileSystem.m
//  CanvasCore
//
//  Created by Nate Armstrong on 3/20/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <CanvasCore/CanvasCore-Swift.h>
#import <UIKit/UIKit.h>

@interface NativeFileSystem: NSObject<RCTBridgeModule>

@end

@implementation NativeFileSystem

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_REMAP_METHOD(pathForResource, named:(NSString *)name ofType:(NSString *)type resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSString *path = [[NSBundle bundleWithIdentifier:@"com.instructure.CanvasCore"] pathForResource:name ofType:type];
    resolve(path);
}

@end
