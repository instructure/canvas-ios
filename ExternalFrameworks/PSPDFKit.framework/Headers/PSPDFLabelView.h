//
//  PSPDFLabelView.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

typedef NS_ENUM(NSUInteger, PSPDFLabelStyle) {
    /// Single color.
    PSPDFLabelStyleFlat,
    /// Uses blur.
    PSPDFLabelStyleModern
} PSPDF_ENUM_AVAILABLE;

NS_ASSUME_NONNULL_BEGIN

/// Base class to show a semi-transparent, rounded label.
///
/// You can use UIAppearance to customize the main properties.
/// ```
/// [PSPDFLabelView appearance].labelStyle = PSPDFLabelStyleFlat;
/// [PSPDFLabelView appearance].backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.8f];
/// [PSPDFLabelView appearance].textColor = UIColor.whiteColor;
/// ```
///
/// @note The background color can be customized by setting the standard `backgroundColor`
/// `UIView` property. If you want to customize the background color, it is recommended
/// that you use `PSPDFLabelStyleFlat`, as using the blur effect with a non-translucent
/// background color might produce unexpected results.
///
/// If you are customizing this view, you might also want to apply similar changes to
/// `PSPDFBackForwardButton`.
PSPDF_CLASS_AVAILABLE @interface PSPDFLabelView : UIView

/// `UILabel` used internally to show the text.
@property (nonatomic, readonly) UILabel *label;

/// Margin that is between the text and this view. Defaults to 2 on iPhone and 3 on iPad.
@property (nonatomic) CGFloat labelMargin UI_APPEARANCE_SELECTOR;

/// Customize label style. Defaults to `PSPDFLabelStyleModern`.
/// The styles match the `buttonStyle` values on `PSPDFBackForwardButton`.
@property (nonatomic) PSPDFLabelStyle labelStyle UI_APPEARANCE_SELECTOR;

/// Customize the blur effect style used. Only applicable in `PSPDFLabelStyleModern`.
/// Defaults to `UIBlurEffectStyleExtraLight`.
@property (nonatomic) UIBlurEffectStyle blurEffectStyle UI_APPEARANCE_SELECTOR;

/// Eual to `label.textColor`, but can also be used with `UIAppearance`.
/// Defaults to black. 
@property (nonatomic) UIColor *textColor UI_APPEARANCE_SELECTOR;

@end

NS_ASSUME_NONNULL_END
