//
//  PSPDFNavigationController.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PSPDFPersistentCloseButtonMode) {
    /// No persistent close button.
    PSPDFPersistentCloseButtonModeNone,
    /// Persistent close button on the left.
    PSPDFPersistentCloseButtonModeLeft,
    /// Persistent close button on the right.
    PSPDFPersistentCloseButtonModeRight
} PSPDF_ENUM_AVAILABLE;

/// Simple subclass that forwards following iOS 6+ rotation methods to the top view controller:
/// `shouldAutorotate`, `supportedInterfaceOrientations`, `preferredInterfaceOrientationForPresentation:`.
PSPDF_CLASS_AVAILABLE @interface PSPDFNavigationController : UINavigationController <UINavigationControllerDelegate>

/// Forward the modern rotation method to the visible view controller. Defaults to YES.
@property (nonatomic, getter=isRotationForwardingEnabled) BOOL rotationForwardingEnabled;

/// Allows showing a persistent close button. Defaults to `PSPDFPersistentCloseButtonModeNone`.
@property (nonatomic) PSPDFPersistentCloseButtonMode persistentCloseButtonMode;

/// The close button if `persistentCloseButtonMode` is set.
/// If none is set, a default system close button will be created.
/// Set the button before a VC is pushed to ensure it will be used instead of the auto-generated one.
@property (nonatomic, nullable) UIBarButtonItem *persistentCloseButton;

@end

NS_ASSUME_NONNULL_END
