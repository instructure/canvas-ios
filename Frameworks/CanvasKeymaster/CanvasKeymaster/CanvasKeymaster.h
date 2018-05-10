//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//


#import <Foundation/Foundation.h>

//! Project version number for CanvasKeymaster
FOUNDATION_EXPORT double CanvasKeymasterVersionNumber;

//! Project version string for CanvasKeymaster.
FOUNDATION_EXPORT const unsigned char CanvasKeymasterVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CanvasKeymaster/PublicHeader.h>

#import <CanvasKeymaster/CKMDomainPickerViewController.h>

NS_ASSUME_NONNULL_BEGIN

@import CanvasKit;

@class CanvasKeymaster;

@protocol CanvasKeymasterDelegate <NSObject>
@property (nonatomic, readonly) NSString *appNameForMobileVerify;
@property (nonatomic, readonly) UIView *backgroundViewForDomainPicker;
@property (nonatomic, readonly) UIImage *logoForDomainPicker;
@property (nonatomic, readonly) UIImage *fullLogoForDomainPicker;
@property (nonatomic, readonly, nullable) NSString *logFilePath;
@end

@protocol CKMAnalyticsProvider
- (void)trackScreenView:(NSString *)value;
@end

@interface CanvasKeymaster : NSObject

+ (instancetype)theKeymaster;

@property (nonatomic) id<CanvasKeymasterDelegate> delegate;
@property (nonatomic) id<CKMAnalyticsProvider> analyticsProvider;

/**
 Fires for each login with the newly created client
 */
@property (nonatomic, readonly) RACSignal<CKIClient *> *signalForLogin;

/**
 Fires on logout sending the login view controller
 */
@property (nonatomic, readonly) RACSignal<UIViewController *> *signalForLogout;

/**
    Signal for "can't login because we have more than one logged in user"
 */
@property (nonatomic, readonly) RACSignal<UIViewController *> *signalForCannotLoginAutomatically;

/**
 If set to YES, branding information is fetches as part of the login process.
 Defaults to NO
 */
@property (nonatomic) BOOL fetchesBranding;

/**
 The current client (last one delivered on
 `signalForCurrentClient`) or nil if not logged
 in
 */
@property (nonatomic, readonly, nullable) CKIClient *currentClient;


@property (nonatomic, readonly) NSString *logFilePath;

@property (nonatomic, readonly) NSInteger numberOfClients;

/**
 Logout
 */
- (void)logout;

/**
 Switch User
 */
- (void)switchUser;

/**
 @return Returns YES if the currently logged in client matches this host. If not, or if there is no current client, returns NO
 */
- (BOOL)currentClientHasHost:(NSString *)host;

/**
 Masquerade as the user with the given id.
 
 @return a signal in case an error occurs
 */
- (RACSignal *)masqueradeAsUserWithID:(NSString *)id;
- (RACSignal *)masqueradeAsUserWithID:(NSString *)id domain:(NSString *)domain;

- (void)stopMasquerading;

- (void)resetKeymasterForTesting;

- (CKIClient *)clientWithMobileVerifiedDetails:(NSDictionary *)details accountDomain:(nullable CKIAccountDomain *)domain;

- (void)loginWithMobileVerifyDetails:(NSDictionary *)details;

@end

@interface CKIClient (CanvasKeymaster)
+ (instancetype)currentClient;
@end

NS_ASSUME_NONNULL_END

#define TheKeymaster ([CanvasKeymaster theKeymaster])

#import <CanvasKeymaster/CKMMultiUserTableViewController.h>
#import <CanvasKeymaster/CKMDomainPickerViewController.h>
#import <CanvasKeymaster/CKMLocationManager.h>
#import <CanvasKeymaster/SupportTicketViewController.h>
#import <CanvasKeymaster/CKMDomainSuggestionTableViewController.h>
#import <CanvasKeymaster/ImpactTableViewController.h>
#import <CanvasKeymaster/CLLocation+CKMDistance.h>
#import <CanvasKeymaster/SupportTicketManager.h>
#import <CanvasKeymaster/FXKeychain+CKMKeyChain.h>
#import <CanvasKeymaster/CKMDomainSuggester.h>
#import <CanvasKeymaster/SupportTicket.h>
#import <CanvasKeymaster/CKMMultiUserTableViewCell.h>
#import <CanvasKeymaster/CKMDomainHelpViewController.h>
#import <CanvasKeymaster/CKMLocationSchoolSuggester.h>
