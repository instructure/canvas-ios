//
//  PSPDFScreenController.h
//  PSPDFKit
//
//  Copyright © 2015-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFViewController, PSPDFScreenController;

PSPDF_AVAILABLE_DECL @protocol PSPDFScreenControllerDelegate<NSObject>

@optional

/// Starts mirroring on `screen`.
- (void)screenController:(PSPDFScreenController *)screenController didStartMirroringForScreen:(UIScreen *)screen;

/// Stopped mirroring on `screen`.
- (void)screenController:(PSPDFScreenController *)screenController didStopMirroringForScreen:(UIScreen *)screen;

@end

/**
 The screen controller will automatically watch for connected screens
 if the property `pdfControllerToMirror` is set, and will release such mirrors once
 this property has been set to nil.

 @note Use this class from the main thread only.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFScreenController : NSObject

/**
 Attach a pdf controller to automatically start mirroring.
 This should be the controller you show on the device.
 This class will automatically create a managed copy and mirrors the position.
 */
@property (nonatomic, nullable) PSPDFViewController *pdfControllerToMirror;

/// Returns the view controller for `screen` if mirrored.
- (nullable PSPDFViewController *)mirrorControllerForScreen:(UIScreen *)screen;

/// Controls if the screen should dim after a certain time or if it should stay lighten up, when an external monitor is connected. Defaults to NO.
@property (nonatomic) BOOL externalScreensDisableScreenDimming;

/// Delegate that calls back when mirroring is stared/stopped.
@property (nonatomic, weak) id<PSPDFScreenControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
