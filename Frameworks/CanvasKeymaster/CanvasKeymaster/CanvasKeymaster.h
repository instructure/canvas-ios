//
//  CKIClient+Keymaster.h
//  CanvasKeymaster
//
//  Created by Derrick Hathaway on 4/24/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for CanvasKeymaster
FOUNDATION_EXPORT double CanvasKeymasterVersionNumber;

//! Project version string for CanvasKeymaster.
FOUNDATION_EXPORT const unsigned char CanvasKeymasterVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CanvasKeymaster/PublicHeader.h>

#import <CanvasKeymaster/CKMDomainPickerViewController.h>

@import CanvasKit;

@class CanvasKeymaster;

@protocol CanvasKeymasterDelegate <NSObject>
@property (nonatomic, readonly) NSString *appNameForMobileVerify;
@property (nonatomic, readonly) UIView *backgroundViewForDomainPicker;
@property (nonatomic, readonly) UIImage *logoForDomainPicker;
@property (nonatomic, readonly) NSString *logFilePath;
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
 The current client (last one delivered on
 `signalForCurrentClient`) or nil if not logged
 in
 */
@property (nonatomic, readonly) CKIClient *currentClient;


@property (nonatomic, readonly) NSString *logFilePath;

/**
 Logout
 */
- (void)logout;

/**
 Switch User
 */
- (void)switchUser;

/**
 @return a signal that completes when the user is logged into the correct domain
 */
- (RACSignal *)signalForLoginWithDomain:(NSString *)host;

/**
 Masquerade as the user with the given id.
 
 @return a signal in case an error occurs
 */
- (RACSignal *)masqueradeAsUserWithID:(NSString *)id;
- (RACSignal *)masqueradeAsUserWithID:(NSString *)id domain:(NSString *)domain;

- (void)stopMasquerading;

@end

@interface CKIClient (CanvasKeymaster)
+ (instancetype)currentClient;
@end


#define TheKeymaster ([CanvasKeymaster theKeymaster])


#import <CanvasKeymaster/CKMMultiUserTableViewController.h>
#import <CanvasKeymaster/CKMDomainPickerViewController.h>
#import <CanvasKeymaster/CKMDomainSuggestionTableViewCell.h>
#import <CanvasKeymaster/CKMLocationManager.h>
#import <CanvasKeymaster/SupportTicketViewController.h>
#import <CanvasKeymaster/CKMDomainSuggestionTableViewController.h>
#import <CanvasKeymaster/CKMSchool.h>
#import <CanvasKeymaster/ImpactTableViewController.h>
#import <CanvasKeymaster/CLLocation+CKMDistance.h>
#import <CanvasKeymaster/SupportTicketManager.h>
#import <CanvasKeymaster/FXKeychain+CKMKeyChain.h>
#import <CanvasKeymaster/CKMDomainSuggester.h>
#import <CanvasKeymaster/SupportTicket.h>
#import <CanvasKeymaster/CKMMultiUserTableViewCell.h>
#import <CanvasKeymaster/CKMDomainHelpViewController.h>
#import <CanvasKeymaster/CKMLocationSchoolSuggester.h>
