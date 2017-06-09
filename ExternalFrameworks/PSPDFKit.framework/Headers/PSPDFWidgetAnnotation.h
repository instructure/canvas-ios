//
//  PSPDFWidgetAnnotation.h
//  PSPDFKit
//
//  Copyright © 2013-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAction.h"
#import "PSPDFAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFAppearanceCharacteristics;

/// The PDF 'Widget' annotation.
/// A Widget usually is a button, much like a link annotation.
PSPDF_CLASS_AVAILABLE @interface PSPDFWidgetAnnotation : PSPDFAnnotation

/// The PDF action executed on touch.
@property (nonatomic, nullable) PSPDFAction *action;

/// Overrides the parent `borderColor` to have a real backing store.
/// Defined in the appearance characteristics dictionary.
@property (nonatomic, nullable) UIColor *borderColor;

/// (Optional) The number of degrees by which the widget annotation shall be rotated counterclockwise relative to the page. The value shall be a multiple of 90. Default value: 0. Defined in the appearance characteristics dictionary.
@property (nonatomic) NSInteger widgetRotation;

/// (Optional) Advanced appearance characteristics for this widget annotation (/MK dictionary)
@property (nonatomic, nullable) PSPDFAppearanceCharacteristics *appearanceCharacteristics;

@end

NS_ASSUME_NONNULL_END
