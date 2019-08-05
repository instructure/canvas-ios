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

#if DEBUG

#import <Foundation/Foundation.h>
#import <CanvasCore/CanvasCore-Swift.h>
@import React;
@import Core;

@interface MockHTTPRequestHandler : NSObject <RCTURLRequestHandler>
@end

@implementation MockHTTPRequestHandler

RCT_EXPORT_MODULE();

- (float)handlerPriority { return 1.0; }

#pragma mark - NSURLRequestHandler

- (BOOL)canHandleRequest:(NSURLRequest *)request
{
    return (
        [MockDistantURLSession isSetup] &&
        [request.URL.scheme.lowercaseString hasPrefix:@"http"] &&
        !request.URL.port // don't mock requests to bundler
    );
}

- (NSObject *)sendRequest:(NSURLRequest *)request withDelegate:(id<RCTURLRequestDelegate>)delegate
{
    NSObject* token = [NSObject new];
    NSURLSessionDataTask *task = [[NSURLSession getDefaultURLSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (response) {
            [delegate URLRequest:token didReceiveResponse:response];
        }
        if (data) {
            [delegate URLRequest:token didReceiveData:data];
        }
        [delegate URLRequest:token didCompleteWithError:error];
    }];

    dispatch_async([[[RCTBridge currentBridge] networking] methodQueue], ^{ [task resume]; });
    return token;
}

- (dispatch_queue_t)methodQueue { return dispatch_get_main_queue(); }
+ (BOOL)requiresMainQueueSetup { return YES; }

@end

#endif
