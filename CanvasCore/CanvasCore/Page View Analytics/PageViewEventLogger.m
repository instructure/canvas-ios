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

@import Foundation;
#import <React/RCTBridgeModule.h>
#import <CanvasCore/CanvasCore-Swift.h>

@interface PageViewEventLogger : NSObject<RCTBridgeModule>
@end

@implementation PageViewEventLogger

RCT_EXPORT_MODULE()

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(allEvents) {
    NSString* events = [[PageViewEventController instance] allEvents];
    return events;
}

RCT_REMAP_METHOD(clearAllEvents, resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [[PageViewEventController instance] clearAllEventsWithHandler:^{
        resolve(nil);
    }];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

@end
