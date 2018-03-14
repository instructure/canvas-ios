//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import <React/RCTBridgeModule.h>
#import <CanvasCore/CanvasCore-Swift.h>

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

RCT_REMAP_METHOD(pushFrom, pushModule:(NSString *)sourceModule destinationModule:(NSString*)module withProps:(NSDictionary *)props options:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [[HelmManager shared] pushFrom:sourceModule destinationModule:module withProps:props options:options callback:^() {
        resolve(nil);
    }];
}

RCT_REMAP_METHOD(popFrom, popModule:(NSString *)sourceModule resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [[HelmManager shared] popFrom:sourceModule callback:^() {
        resolve(nil);
    }];
}

RCT_REMAP_METHOD(present, presentModule:(NSString *)module withProps:(NSDictionary *)props options:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [[HelmManager shared] present:module withProps:props options:options callback:^() {
        resolve(nil);
    }];
}

RCT_REMAP_METHOD(dismiss, dismissWithOptions:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [[HelmManager shared] dismiss:options callback:^() {
        resolve(nil);
    }];
}

RCT_REMAP_METHOD(dismissAllModals, dismissAllModalsWithOptions:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [[HelmManager shared] dismissAllModals:options callback:^() {
        resolve(nil);
    }];
}

RCT_EXPORT_METHOD(traitCollection:(NSString*)moduleName callback:(RCTResponseSenderBlock)callback) {
    [[HelmManager shared] traitCollection:moduleName callback:callback];
}

RCT_EXPORT_METHOD(loginComplete) {
    [[HelmManager shared] loginComplete];
}

RCT_EXPORT_METHOD(reload) {
    [[HelmManager shared] reload];
}

@end
