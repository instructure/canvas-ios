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
@import React;

@interface TabBarBadgeCounts (React) <RCTBridgeModule>
@end

@implementation TabBarBadgeCounts (React)
RCT_EXPORT_MODULE(TabBarBadgeCounts);
RCT_EXTERN_METHOD(updateUnreadMessageCount:);
RCT_EXTERN_METHOD(updateTodoListCount:);

- (dispatch_queue_t)methodQueue { return dispatch_get_main_queue(); }
+ (BOOL)requiresMainQueueSetup { return YES; }

@end
