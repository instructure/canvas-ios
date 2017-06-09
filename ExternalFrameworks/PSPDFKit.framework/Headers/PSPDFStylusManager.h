//
//  PSPDFStylusManager.h
//  PSPDFKit
//
//  Copyright © 2014-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFStylusDriver.h"
#import "PSPDFStylusDriverDelegate.h"
#import "PSPDFStylusTouch.h"
#import "PSPDFStylusViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString *PSPDFStylusButtonAction NS_EXTENSIBLE_STRING_ENUM;

/// The stylus manager is the central point for pen/stylus management in PSPDFKit.
/// @note Drivers have to be linked externally, see the "Extras" folder in the PSPDFKit distribution.
/// Compatible driver classes will be automatically detected at runtime.
/// This class should not be instantiated manually but fetched from the PSPDFKit shared object.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFStylusManager : NSObject

/**
 If `YES`, sets `applePencilEnabled` to `YES` whenever `PSPDFApplePencilDetectedNotification`
 is posted, resulting in enabling Apple Pencil whenever a touch from one is detected.
 Defaults to `YES`.

 Setting this property does not directly set `applePencilEnabled`, so if you want to disable Apple Pencil
 and disable automatic enabling, you should set both properties to `NO`, and if you want to enable
 Apple Pencil immediately and re-enable automatic enabling, you should set both properties to `YES`.
 */
@property (nonatomic) BOOL automaticallyEnablesApplePencil;

/// Shortcut for whether `currentDriverClass` is `PSPDFApplePencilDriver`, and for setting the same.
/// Setting this to `NO` disables any stylus.
@property (nonatomic, getter=isApplePencilEnabled) BOOL applePencilEnabled;

/// Set the current pen type. Disables internal SDKs and re-enables selected one.
@property (nonatomic, nullable) Class<PSPDFStylusDriver> currentDriverClass;

/// The current pen connection status.
@property (nonatomic, readonly) PSPDFStylusConnectionStatus connectionStatus;

/// Returns the name of the stylus, if possible. Will return "Stylus" if no name is returned by the driver.
@property (nonatomic, copy, readonly, nullable) NSString *stylusName;

/**
 Available driver classes. Set classes for your supported stylus drivers.
 Stylues are presented in the order defined by this set.
 These must be set before creating `PSPDFViewController`.
 Defaults to only `PSPDFApplePencilDriver`. If you set this property and want to keep Apple Pencil support, you should include `PSPDFApplePencilDriver` in the set.
 */
@property (nonatomic, copy) NSOrderedSet<Class<PSPDFStylusDriver>> *availableDriverClasses;

/// Tries to restore last driver selection. Might load a driver and show the connection HUD.
- (BOOL)enableLastDriver;

/// Returns a new instance of the stylus connector/chooser controller.
/// @note Will always return a controller, even if no drivers are available.
@property (nonatomic, readonly) PSPDFStylusViewController *stylusController;

/// Native driver settings controller, if any.
@property (nonatomic, readonly, nullable) UIViewController *settingsControllerForCurrentDriver;

/// Native driver settings controller size (if any)
@property (nonatomic, readonly) CGSize embeddedSizeForSettingsController;

/// Maps button numbers to actions, like undo or redo.
/// @note Keys are button numbers wrapped in `NSNumber *` and values are the following `NSString *` constants:
/// - Undo: `PSPDFStylusButtonActionUndo`
/// - Redo: `PSPDFStylusButtonActionRedo`
/// - Ink: `PSPDFStylusButtonActionInk`
/// - Eraser: `PSPDFStylusButtonActionEraser`
@property (nonatomic) NSDictionary<NSNumber *, PSPDFStylusButtonAction> *buttonActionMapping;

/// Allows to check if driver does provide a settings controller.
- (BOOL)hasSettingsControllerForDriverClass:(nullable Class)driver;

/// @name View and Touch Management

/// Register views that should receive pen touches.
- (void)registerView:(UIView *)view;

/// Deregister views that should receive pen touches.
- (void)unregisterView:(UIView *)view;

/// Touch classification, if supported by the driver.
@property (nonatomic, readonly) BOOL driverAllowsClassification;
- (nullable id<PSPDFStylusTouch>)touchInfoForTouch:(UITouch *)touch;

/// Whether a `PSPDFStatusHUDItem` should be shown when the connection status changes.
/// Defaults to `NO`.
@property (nonatomic) BOOL showsStatusHUDForConnectionStatusChanges;

/// @name Delegate Management

/// Register delegate for changes.
/// @note Delegates are weakly retained, but be a good citizen and manually deregister.
- (void)addDelegate:(id<PSPDFStylusDriverDelegate>)delegate;

/// Deregisters delegate.
/// @note Delegates are weakly retained, but be a good citizen and manually deregister.
- (BOOL)removeDelegate:(id<PSPDFStylusDriverDelegate>)delegate;

@end

/// Convert the `PSPDFStylusConnectionStatus` enum value to a string.
PSPDF_EXPORT NSString *PSPDFStylusConnectionStatusToString(PSPDFStylusConnectionStatus connectionStatus);

/// Notification posted when the `connectionStatus` changes.
PSPDF_EXPORT NSNotificationName const PSPDFStylusManagerConnectionStatusChangedNotification;

/// Predefined undo stylus button action.
PSPDF_EXPORT PSPDFStylusButtonAction const PSPDFStylusButtonActionUndo;
/// Predefined redo stylus button action.
PSPDF_EXPORT PSPDFStylusButtonAction const PSPDFStylusButtonActionRedo;
/// Predefined ink stylus button action.
PSPDF_EXPORT PSPDFStylusButtonAction const PSPDFStylusButtonActionInk;
/// Predefined eraser stylus button action.
PSPDF_EXPORT PSPDFStylusButtonAction const PSPDFStylusButtonActionEraser;

NS_ASSUME_NONNULL_END
