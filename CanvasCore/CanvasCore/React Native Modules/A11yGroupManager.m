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

#import <UIKit/UIKit.h>
#import <CanvasCore/CanvasCore-Swift.h>
@import React;

@interface A11yGroupManager: RCTViewManager
@end

@implementation A11yGroupManager

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue { return dispatch_get_main_queue(); }
+ (BOOL)requiresMainQueueSetup { return YES; }

- (UIView *)view {
    RCTView *a11yGroup = [RCTView new];
    a11yGroup.shouldGroupAccessibilityChildren = YES;
    return a11yGroup;
}

@end
