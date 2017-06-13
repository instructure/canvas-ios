//
//  Helm.m
//  Teacher
//
//  Created by Ben Kraus on 4/28/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import "Teacher-Swift.h"

@interface Helm: NSObject <RCTBridgeModule>

@end

@implementation Helm

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(setScreenConfig:(NSDictionary *)config forScreenWithID:(NSString *)screenInstanceID hasRendered:(BOOL)hasRendered) {
    [[HelmManager shared] setScreenConfig:config forScreenWithID:screenInstanceID hasRendered:hasRendered];
}

RCT_EXPORT_METHOD(setDefaultScreenConfig:(NSDictionary *)config forModule:(NSString *)module) {
    [[HelmManager shared] setDefaultScreenConfig:config forModule:module];
}

RCT_EXPORT_METHOD(pushFrom:(NSString *)sourceModule destinationModule:(NSString*)module withProps:(NSDictionary *)props options:(NSDictionary *)options) {
    [[HelmManager shared] pushFrom:sourceModule destinationModule:module withProps:props options:options];
}

RCT_EXPORT_METHOD(popFrom:(NSString *)sourceModule) {
    [[HelmManager shared] popFrom:sourceModule];
}

RCT_EXPORT_METHOD(present:(NSString *)module withProps:(NSDictionary *)props options:(NSDictionary *)options) {
    [[HelmManager shared] present:module withProps:props options:options];
}

RCT_EXPORT_METHOD(dismiss:(NSDictionary *)options) {
    [[HelmManager shared] dismiss:options];
}

RCT_EXPORT_METHOD(dismissAllModals:(NSDictionary *)options) {
    [[HelmManager shared] dismissAllModals:options];
}

RCT_EXPORT_METHOD(traitCollection:(NSString *)screenInstanceID moduleName:(NSString*)moduleName callback:(RCTResponseSenderBlock)callback) {
    [[HelmManager shared] traitCollection:screenInstanceID moduleName:moduleName callback:callback];
}

RCT_EXPORT_METHOD(initLoadingStateIfRequired) {
    [[HelmManager shared] initLoadingStateIfRequired];
}

RCT_EXPORT_METHOD(initTabs) {
    [[HelmManager shared] initTabs];
}

@end
