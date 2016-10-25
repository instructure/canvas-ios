//
//  PSPDFStylusDriver.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFStylusDriverDelegate.h"
#import "PSPDFStylusTouch.h"
#import "PSPDFPlugin.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PSPDFStylusConnectionStatus) {
    PSPDFStylusConnectionStatusOff,
    PSPDFStylusConnectionStatusScanning,
    PSPDFStylusConnectionStatusPairing,
    PSPDFStylusConnectionStatusConnected,
    PSPDFStylusConnectionStatusDisconnected
} PSPDF_ENUM_AVAILABLE;

/// Abstract driver class for various styli.
PSPDF_AVAILABLE_DECL @protocol PSPDFStylusDriver <PSPDFPlugin>

/// Enable a stylus driver.
- (BOOL)enableDriverWithOptions:(nullable NSDictionary<NSString *, id> *)options error:(NSError **)error;

/// Disable the current stylus driver.
- (void)disableDriver;

/// Info of the connected stylus. Might also return data if the connection status is not connected.
@property (nonatomic, readonly) NSDictionary<NSString *, id> *connectedStylusInfo;

/// Connection status of the pen managed by the driver.
@property (nonatomic, readonly) PSPDFStylusConnectionStatus connectionStatus;

/// Driver event delegate.
@property (nonatomic, weak, readonly) id<PSPDFStylusDriverDelegate> delegate;

@optional

/// Optional touch classification.
- (nullable id<PSPDFStylusTouch>)touchInfoForTouch:(UITouch *)touch;

/// Returns a settings/pairing controller, if the driver supports this.
@property (nonatomic, readonly, nullable) UIViewController *settingsController;
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, id> *settingsControllerInfo;

/// View registration. (optional, not all drivers need this)
- (void)registerView:(UIView *)view;
- (void)unregisterView:(UIView *)view;

@end

/// Defines in the `options` key from the initializer
PSPDF_EXPORT NSString *const PSPDFStylusDriverDelegateKey;

/// Defines the `driverInfo` dictionary keys.
PSPDF_EXPORT NSString *const PSPDFStylusDriverNameKey;
PSPDF_EXPORT NSString *const PSPDFStylusDriverSDKNameKey;
PSPDF_EXPORT NSString *const PSPDFStylusDriverSDKVersionKey;
PSPDF_EXPORT NSString *const PSPDFStylusDriverProtocolVersionKey;
PSPDF_EXPORT NSString *const PSPDFStylusDriverPriorityKey;

/// Defines the `connectedStylusInfo` dictionary keys.
PSPDF_EXPORT NSString *const PSPDFStylusNameKey;

/// Defiles the `connectedStylusInfo` dictionary keys
PSPDF_EXPORT NSString *const PSPDFStylusSettingsEmbeddedSizeKey;

/// Protocol versions.
PSPDF_EXPORT NSUInteger PSPDFStylusDriverProtocolVersion_1;

NS_ASSUME_NONNULL_END
