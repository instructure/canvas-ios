//
//  PSPDFBackForwardButton.h
//  PSPDFKit
//
//  Copyright (c) 2015-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFButton.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PSPDFBackButtonStyle) {
    /// Single color.
    PSPDFBackButtonStyleFlat,
    /// Uses blur.
    PSPDFBackButtonStyleModern
} PSPDF_ENUM_AVAILABLE;

/// Back and forward buttons, used for the action stack navigation.
///
/// You can use UIAppearance to customize the main properties.
/// ```
/// [PSPDFBackForwardButton appearance].buttonStyle = PSPDFBackButtonStyleFlat;
/// [PSPDFBackForwardButton appearance].backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.8f];
/// [PSPDFBackForwardButton appearance].tintColor = UIColor.whiteColor;
/// ```
///
/// @note The background color can be customized by setting the standard `backgroundColor`
/// `UIView` property. If you want to customize the background color, it is recommended
/// that you use `PSPDFLabelStyleFlat`, as using the blur effect with a non-translucent
/// background color might produce unexpected results.
///
/// If you are customizing this view, you might also want to apply similar changes to
/// `PSPDFLabelView`.
PSPDF_CLASS_AVAILABLE @interface PSPDFBackForwardButton : PSPDFButton

/// Returns a button pre-configured for the back button style.
+ (instancetype)backButton;

/// Returns a button pre-configured for the forward button style.
+ (instancetype)forwardButton;

/// Customize the button style. Defaults to `PSPDFBackButtonStyleModern`.
/// The styles match the `labelStyle` values on `PSPDFLabelView`.
@property (nonatomic) PSPDFBackButtonStyle buttonStyle UI_APPEARANCE_SELECTOR;

/// Customize the blur effect style used.
/// Defaults to `UIBlurEffectStyleDark`.
@property (nonatomic) UIBlurEffectStyle blurEffectStyle UI_APPEARANCE_SELECTOR;

/// Convenience long press gesture recognizer.
/// Use `addTarget:action:` to perform custom actions when triggered.
@property (nonatomic, readonly) UILongPressGestureRecognizer *longPressRecognizer;

@end

NS_ASSUME_NONNULL_END
