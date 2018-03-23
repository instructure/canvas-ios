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

RCT_REMAP_METHOD(convertToJPEG, path:(NSString *)path resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSURL *inputURL = [NSURL URLWithString:path];
    UIImage *image = [UIImage imageWithContentsOfFile:inputURL.path];
    if (!image) { reject(@"0", NSLocalizedString(@"Failed to find image at path", comment: nil), nil); }
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    NSURL *tmp = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *url = [[tmp URLByAppendingPathComponent:[inputURL URLByDeletingPathExtension].lastPathComponent] URLByAppendingPathExtension:@"jpg"];
    BOOL success = [data writeToURL:url atomically:YES];
    if (success) {
        resolve(url.absoluteString);
    } else {
        reject(@"1", NSLocalizedString(@"Failed to write image", comment: nil), nil);
    }
}

@end
