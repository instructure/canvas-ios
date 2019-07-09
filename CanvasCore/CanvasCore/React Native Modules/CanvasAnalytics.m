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

#import "CanvasAnalytics.h"

static id<CanvasAnalyticsHandler> _handler = nil;

@implementation CanvasAnalytics

RCT_EXPORT_MODULE();

+ (void)setHandler:(id<CanvasAnalyticsHandler>)handler {
    _handler = handler;
}

+ (void)logEvent:(NSString *)name {
    [self logEvent:name parameters:nil];
}

+ (void)logEvent:(NSString *)name parameters:(nullable NSDictionary<NSString *, id>*)parameters {
    [_handler handleEvent:name parameters:parameters];
}

RCT_EXPORT_METHOD(logEvent:(NSString *)name parameters:(nullable NSDictionary<NSString *, id>*)parameters)
{
    [_handler handleEvent:name parameters:parameters];
}

@end
