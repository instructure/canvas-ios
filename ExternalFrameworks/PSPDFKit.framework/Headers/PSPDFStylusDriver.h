//
//  PSPDFStylusDriver.h
//  PSPDFKit
//
//  Copyright © 2014-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFStylusDriverDelegate.h"
#import "PSPDFStylusTouch.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PSPDFStylusConnectionStatus) {
    PSPDFStylusConnectionStatusOff,
    PSPDFStylusConnectionStatusScanning,
    PSPDFStylusConnectionStatusPairing,
    PSPDFStylusConnectionStatusConnected,
    PSPDFStylusConnectionStatusDisconnected,
} PSPDF_ENUM_AVAILABLE;

typedef NSString *PSPDFStylusDriverInfoKey NS_STRING_ENUM;

typedef NSString *PSPDFConnectedStylusInfoKey NS_STRING_ENUM;

typedef NSString *PSPDFStylusSettingsControllerInfoKey NS_STRING_ENUM;

/// Abstract driver class for various styli.
PSPDF_AVAILABLE_DECL @protocol PSPDFStylusDriver<NSObject>

+ (NSDictionary<PSPDFStylusDriverInfoKey, id> *)driverInfo;

/// Creates a new instance of the driver with `delegate` set.
- (instancetype)initWithDelegate:(id<PSPDFStylusDriverDelegate>)delegate;

/// Enable a stylus driver.
- (BOOL)enableDriverWithOptions:(nullable NSDictionary<NSString *, id> *)options error:(NSError **)error;

/// Disable the current stylus driver.
- (void)disableDriver;

/// Info of the connected stylus. Might also return data if the connection status is not connected.
@property (nonatomic, readonly) NSDictionary<PSPDFConnectedStylusInfoKey, id> *connectedStylusInfo;

/// Connection status of the pen managed by the driver.
@property (nonatomic, readonly) PSPDFStylusConnectionStatus connectionStatus;

/// Driver event delegate.
@property (nonatomic, weak, readonly) id<PSPDFStylusDriverDelegate> delegate;

@optional

/// Optional touch classification.
- (nullable id<PSPDFStylusTouch>)touchInfoForTouch:(UITouch *)touch;

/// Returns a settings/pairing controller, if the driver supports this.
@property (nonatomic, readonly, nullable) UIViewController *settingsController;
@property (nonatomic, readonly, nullable) NSDictionary<PSPDFStylusSettingsControllerInfoKey, id> *settingsControllerInfo;

/// View registration. (optional, not all drivers need this)
- (void)registerView:(UIView *)view;
- (void)unregisterView:(UIView *)view;

@end

/// Keys for the `driverInfo` dictionary.
PSPDF_EXPORT PSPDFStylusDriverInfoKey const PSPDFStylusDriverIdentifierKey;
PSPDF_EXPORT PSPDFStylusDriverInfoKey const PSPDFStylusDriverNameKey;
PSPDF_EXPORT PSPDFStylusDriverInfoKey const PSPDFStylusDriverSDKNameKey;
PSPDF_EXPORT PSPDFStylusDriverInfoKey const PSPDFStylusDriverSDKVersionKey;
PSPDF_EXPORT PSPDFStylusDriverInfoKey const PSPDFStylusDriverProtocolVersionKey;
PSPDF_EXPORT PSPDFStylusDriverInfoKey const PSPDFStylusDriverPriorityKey;

/// Key for the name of the connected stylus for the `connectedStylusInfo` dictionary.
PSPDF_EXPORT PSPDFConnectedStylusInfoKey const PSPDFStylusNameKey;

/// Key for the content size in points of the embedded settings controller for the `settingsControllerInfo` dictionary.
PSPDF_EXPORT PSPDFStylusSettingsControllerInfoKey const PSPDFStylusSettingsEmbeddedSizeKey;

/// Protocol versions.
PSPDF_EXPORT NSUInteger PSPDFStylusDriverProtocolVersion_1;

NS_ASSUME_NONNULL_END
