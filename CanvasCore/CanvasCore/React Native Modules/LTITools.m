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
#import <React/RCTBridgeModule.h>
#import <CanvasCore/CanvasCore-Swift.h>
@import Core;

@interface LTIToolsReact: NSObject<RCTBridgeModule>
@end

@implementation LTIToolsReact
RCT_EXPORT_MODULE(LTITools);

RCT_REMAP_METHOD(launchExternalTool, launchExternalTool:(NSString *)url resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    UIViewController *current = [[HelmManager shared] topMostViewController];
    NSURL *launchURL = [[NSURL alloc] initWithString:url];

    [LTITools launch:launchURL from:current animated:YES completionHandler:^(BOOL success) {
        resolve(nil);
    }];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

@end
