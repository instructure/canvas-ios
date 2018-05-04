//
//  CanvasWebViewManager.m
//  CanvasCore
//
//  Created by Nate Armstrong on 2/23/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
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
