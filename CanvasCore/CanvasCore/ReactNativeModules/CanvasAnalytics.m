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

//
// I called this `CanvasAnalytics` because Firebase already uses Analytics
//
// Allows for a common interface for analytics handling, but each app is allowed to
// send its events to wherever it wants to
//
// Also exposes the logEvent: method to react native

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
@import Core;

NS_ASSUME_NONNULL_BEGIN

@interface CanvasAnalytics: NSObject <RCTBridgeModule>

+ (void)logEvent:(NSString *)name parameters:(nullable NSDictionary<NSString *, id>*)parameters;
+ (void)logEvent:(NSString *)name;
+ (void)logScreenView:(NSString *)route;

// Instance version needed for React Native
- (void)logEvent:(NSString *)name parameters:(nullable NSDictionary<NSString *, id>*)parameters;
- (void)logScreenView:(NSString *)route;

@end

NS_ASSUME_NONNULL_END

@implementation CanvasAnalytics

RCT_EXPORT_MODULE();

+ (void)logEvent:(NSString *)name {
    [Analytics.shared logEvent: name parameters: nil];
}

+ (void)logEvent:(NSString *)name parameters:(nullable NSDictionary<NSString *, id>*)parameters {
    [Analytics.shared logEvent: name parameters: parameters];
}

+ (void)logScreenView:(NSString *)route {
    [Analytics.shared logScreenView: route viewController: nil];
}

RCT_EXPORT_METHOD(logEvent:(NSString *)name parameters:(nullable NSDictionary<NSString *, id>*)parameters)
{
    [Analytics.shared logEvent: name parameters: parameters];
}

RCT_EXPORT_METHOD(logScreenView:(NSString *)route)
{
    [Analytics.shared logScreenView: route viewController: nil];
}

@end
