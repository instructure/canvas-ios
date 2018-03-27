//
//  CoreDataSync.m
//  CanvasCore
//
//  Created by Nate Armstrong on 3/27/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <CanvasCore/CanvasCore-Swift.h>
#import <UIKit/UIKit.h>

@interface CoreDataSync: NSObject<RCTBridgeModule>

@end

@implementation CoreDataSync

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_REMAP_METHOD(syncAction, info:(NSDictionary *)info resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [CoreDataSyncHelper syncAction:info completion:^{
        resolve(nil);
    }];
}

@end
