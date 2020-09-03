//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
#import <CanvasCore/CanvasCore-Swift.h>
@import React;
@import Core;

@interface APIHTTPRequestHandler: NSObject <RCTURLRequestHandler>
@end

@implementation APIHTTPRequestHandler

RCT_EXPORT_MODULE();

- (float)handlerPriority { return 1.0; }

#pragma mark - NSURLRequestHandler

- (BOOL)canHandleRequest:(NSURLRequest *)request
{
    return [request.URL.scheme.lowercaseString hasPrefix:@"http"]
    && ![(request.URL.host ?: @"") isEqualToString:@"localhost"];
}

- (NSObject *)sendRequest:(NSURLRequest *)request withDelegate:(id<RCTURLRequestDelegate>)delegate
{
    return [HTTPRequestHandler sendRequest:request withDelegate:delegate];
}

- (dispatch_queue_t)methodQueue { return dispatch_get_main_queue(); }
+ (BOOL)requiresMainQueueSetup { return YES; }

@end
