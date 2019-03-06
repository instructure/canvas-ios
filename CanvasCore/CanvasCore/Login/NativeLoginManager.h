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
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
@import CanvasKeymaster;

typedef NSString *CanvasApp NS_EXTENSIBLE_STRING_ENUM;

extern CanvasApp _Nonnull CanvasAppStudent;
extern CanvasApp _Nonnull CanvasAppTeacher;
extern CanvasApp _Nonnull CanvasAppParent;

NS_ASSUME_NONNULL_BEGIN

@protocol NativeLoginManagerDelegate;

@interface NativeLoginManager : NSObject

@property (nonatomic, nonnull) CanvasApp app;
@property (nonatomic, weak) id<NativeLoginManagerDelegate> delegate;
@property (nonatomic) BOOL shouldCleanupOnNextLogoutEvent;

+ (instancetype)shared;

// Mainly used for testing
//
// Inject login information to bypass keymaster login flow
// Must have the following keys:
//  - authToken
//  - baseURL
//  - user
//
//  user will be a canvas user. A sample of those properties:
//    - id
//    - name
//    - primary_email
//    - short_name
//    - sortable_name
//
// Send nil in order to reset
- (void)injectLoginInformation:(nullable NSDictionary<NSString *, id> *)info;

- (void)stopMasquerding;

- (void)setup;

@end

@protocol NativeLoginManagerDelegate <NSObject>

// Called when a login event occurred
- (void)didLogin:(CKIClient *)client;

// Called when a logout event occurred
// The view controller passed in will be a login view controller
- (void)didLogout:(UIViewController *)controller;

@optional
// Called before a logout event
- (void)willLogout;

@end

NS_ASSUME_NONNULL_END
