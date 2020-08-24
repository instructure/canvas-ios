//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#import <Foundation/Foundation.h>
#import <React/RCTViewManager.h>
#import <CanvasCore/CanvasCore-Swift.h>

@interface CoreWebViewManager: RCTViewManager
@end

@implementation CoreWebViewManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    return [CoreWebViewWrapper new];
}

RCT_REMAP_VIEW_PROPERTY(automaticallySetHeight, webView.autoresizesHeight, BOOL)
RCT_REMAP_VIEW_PROPERTY(bounces, webView.scrollView.bounces, BOOL)
RCT_EXPORT_VIEW_PROPERTY(contentInset, UIEdgeInsets)
RCT_REMAP_VIEW_PROPERTY(isOpaque, webView.isOpaque, BOOL)
RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onFinishedLoading, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onHeightChange, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onMessage, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onNavigation, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(source, NSDictionary)

RCT_EXPORT_METHOD(evaluateJavaScript:(nonnull NSNumber *)reactTag js:(NSString *)js resolver:(RCTPromiseResolveBlock)resolve  rejecter:(RCTPromiseRejectBlock)reject) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        CoreWebViewWrapper *view = (CoreWebViewWrapper *)viewRegistry[reactTag];
        if (!view || ![view isKindOfClass:[CoreWebViewWrapper class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting CoreWebViewWrapper, got: %@", view);
        } else {
            [view evaluateJavaScript:js completionHandler:^(id result, NSError *error) {
                if (error) {
                    reject(@"js_error", error.localizedDescription, nil);
                } else {
                    resolve(result);
                }
            }];
        }
    }];
}

@end
