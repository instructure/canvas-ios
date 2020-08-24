//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

@interface RichContentEditorManager: RCTViewManager
@end

@implementation RichContentEditorManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    return [RichContentEditorWrapper new];
}

RCT_EXPORT_VIEW_PROPERTY(context, NSString)
RCT_EXPORT_VIEW_PROPERTY(html, NSString)
RCT_EXPORT_VIEW_PROPERTY(onFocus, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(placeholder, NSString)
RCT_EXPORT_VIEW_PROPERTY(uploadContext, NSString)

RCT_EXPORT_METHOD(getHTML:(nonnull NSNumber *)reactTag resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        RichContentEditorWrapper *view = (RichContentEditorWrapper *)viewRegistry[reactTag];
        if (!view || ![view isKindOfClass:[RichContentEditorWrapper class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RichContentEditorWrapper, got: %@", view);
        } else {
            [view getHTML:^(NSString *result) { resolve(result); }];
        }
    }];
}

@end
