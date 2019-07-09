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

NS_ASSUME_NONNULL_BEGIN

@protocol CanvasAnalyticsHandler
- (void)handleEvent:(NSString *)name parameters:(nullable NSDictionary<NSString *, id> *)parameters;
@end

@interface CanvasAnalytics : NSObject <RCTBridgeModule>

+ (void)setHandler:(id<CanvasAnalyticsHandler>)handler;
+ (void)logEvent:(NSString *)name parameters:(nullable NSDictionary<NSString *, id>*)parameters;
+ (void)logEvent:(NSString *)name;

// Instance version needed for React Native
- (void)logEvent:(NSString *)name parameters:(nullable NSDictionary<NSString *, id>*)parameters;

@end

NS_ASSUME_NONNULL_END
