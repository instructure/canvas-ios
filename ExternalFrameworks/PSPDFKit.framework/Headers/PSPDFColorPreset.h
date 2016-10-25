//
//  PSPDFColorPreset.h
//  PSPDFKit
//
//  Copyright (c) 2015-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFModel.h"

NS_ASSUME_NONNULL_BEGIN

/// Model class used to define custom color presets.
/// @see `PSPDFStyleManager`
PSPDF_CLASS_AVAILABLE @interface PSPDFColorPreset : PSPDFModel

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Creates a new preset with a `nil` `fillColor` and `alpha` set to 1.f.
+ (instancetype)presetWithColor:(nullable UIColor *)color;

/// Creates a new custom preset.
+ (instancetype)presetWithColor:(nullable UIColor *)color fillColor:(nullable UIColor *)fillColor alpha:(CGFloat)alpha;

/// The primary preset color (the content color).
/// @note The color will be standardized to the RGB color space with an alpha value of 1.f
@property (nonatomic, readonly, nullable) UIColor *color;

/// The `color` with added `alpha`.
@property (nonatomic, readonly, nullable) UIColor *colorWithAlpha;

/// The secondary preset color (fill color).
/// @note The color will be standardized to the RGB color space with an alpha value of 1.f
@property (nonatomic, readonly, nullable) UIColor *fillColor;

/// The `fillColor` with added `alpha`.
@property (nonatomic, readonly, nullable) UIColor *fillColorWithAlpha;

/// The preset alpha.
@property (nonatomic, readonly) CGFloat alpha;

@end

NS_ASSUME_NONNULL_END
