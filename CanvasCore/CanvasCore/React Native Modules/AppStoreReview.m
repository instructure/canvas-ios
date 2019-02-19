//
// Copyright (C) 2018-present Instructure, Inc.
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

- (dispatch_queue_t)methodQueue { return dispatch_get_main_queue(); }
+ (BOOL)requiresMainQueueSetup { return YES; }

@end
