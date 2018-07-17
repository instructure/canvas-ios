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

#import <UIKit/UIKit.h>
#import <CanvasCore/CanvasCore-Swift.h>
#import <React/RCTUIManager.h>
#import "CanvasWebViewContainer.h"

@interface CanvasWebViewManager : RCTViewManager
@end

@implementation CanvasWebViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    return [CanvasWebViewContainer new];
}

RCT_EXPORT_VIEW_PROPERTY(source, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(onNavigation, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onFinishedLoading, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onMessage, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onHeightChange, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(automaticallyAdjustContentInsets, BOOL)
RCT_EXPORT_VIEW_PROPERTY(contentInset, UIEdgeInsets)
RCT_EXPORT_VIEW_PROPERTY(hideKeyboardAccessoryView, BOOL)
RCT_EXPORT_VIEW_PROPERTY(isOpaque, BOOL)
RCT_REMAP_VIEW_PROPERTY(scrollEnabled, _webView.scrollView.scrollEnabled, BOOL)
RCT_REMAP_VIEW_PROPERTY(bounces, _webView.scrollView.bounces, BOOL)

RCT_EXPORT_METHOD(evaluateJavaScript:(nonnull NSNumber *)reactTag
                  js:(NSString *)js
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, CanvasWebViewContainer *> *viewRegistry) {
    CanvasWebViewContainer *view = viewRegistry[reactTag];
    if (![view isKindOfClass:[CanvasWebViewContainer class]]) {
      RCTLogError(@"Invalid view returned from registry, expecting CanvasWebViewContainer, got: %@", view);
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
