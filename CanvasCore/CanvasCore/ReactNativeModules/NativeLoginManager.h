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
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NativeLoginManagerDelegate;

@interface NativeLoginManager : NSObject

@property (nonatomic, weak) id<NativeLoginManagerDelegate> delegate;

+ (instancetype)shared;

// Send login information to React Native
// Must have the following keys:
//  - appId "student" | "teacher"
//  - authToken
//  - user
//  - baseURL
//  - branding
//  - actAsUserID
//  - countryCode
//  - locale
- (void)login:(nonnull NSDictionary *)body;

- (void)logout;

@end

@protocol NativeLoginManagerDelegate <NSObject>

// Called when changeUser is called from React Native
- (void)changeUser;

// Called when stopActing is called from React Native
- (void)stopActing;

// Called when logout is called from React Native
- (void)logout;

- (void)actAsFakeStudentWithID:(NSString *)fakeStudentID;

@end

NS_ASSUME_NONNULL_END
