//
// Copyright (C) 2017-present Instructure, Inc.
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
#import <React/RCTUIManager.h>

@interface CanvadocViewManager : RCTViewManager
@end

@implementation CanvadocViewManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    return [CanvadocView new];
}

RCT_EXPORT_VIEW_PROPERTY(config, NSDictionary *)
RCT_EXPORT_VIEW_PROPERTY(onSaveStateChange, RCTDirectEventBlock)

RCT_EXPORT_METHOD(syncAllAnnotations:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, CanvadocView *> *viewRegistry) {
        CanvadocView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[CanvadocView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting CanvadocView, got: %@", view);
        } else {
            [view syncAnnotations];
        }
    }];
}

@end
