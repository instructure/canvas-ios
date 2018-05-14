//
//  NativeLogin.h
//  Teacher
//
//  Created by Derrick Hathaway on 2/21/17.
//  Copyright © 2017 Facebook. All rights reserved.
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

@end

@protocol NativeLoginManagerDelegate <NSObject>

// Called when a login event occurred
- (void)didLogin:(CKIClient *)client;

// Called when a logout event occurred
// The view controller passed in will be a login view controller
- (void)didLogout:(UIViewController *)controller;

@end

NS_ASSUME_NONNULL_END
