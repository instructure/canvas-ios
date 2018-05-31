//
//  AppStoreReview.m
//  CanvasCore
//
//  Created by Andrew VanWagoner on 5/15/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CanvasCore/CanvasCore-Swift.h>
@import React;

@interface AppStoreReview (React) <RCTBridgeModule>
@end

@implementation AppStoreReview (React)
RCT_EXPORT_MODULE(AppStoreReview);

RCT_EXPORT_METHOD(handleSuccessfulSubmit) {
    [AppStoreReview handleSuccessfulSubmit];
}

RCT_EXPORT_METHOD(handleNavigateToAssignment) {
    [AppStoreReview handleNavigateToAssignment];
}

RCT_EXPORT_METHOD(handleNavigateFromAssignment) {
    [AppStoreReview handleNavigateFromAssignment];
}

RCT_REMAP_METHOD(getState, getStateResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([AppStoreReview getState]);
}

RCT_REMAP_METHOD(setState, setStateAsync:(NSString *)key withValue:(NSNumber * _Nonnull)value resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [AppStoreReview setState:key withValue:[value integerValue]];
    resolve(nil);
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end
