//
//  PSPDFProcessorItemBuilder.h
//  PSPDFModel
//
//  Copyright (c) 2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>

#import "PSPDFEnvironment.h"
#import "PSPDFRectAlignment.h"
#import "PSPDFModel.h"

/// Specifies if the item (image) should be located in the foreground or background
typedef NS_ENUM(NSInteger, PSPDFItemZPosition) {
    /// Puts the item in the foreground
    PSPDFItemZPositionForeground,

    /// Puts the item in the background
    PSPDFItemZPositionBackground
} PSPDF_ENUM_AVAILABLE;

NS_ASSUME_NONNULL_BEGIN

PSPDF_CLASS_AVAILABLE @interface PSPDFProcessorItemBuilder : PSPDFModel

/// The `item` can be positioned, scaled and rotated with `itemTransform`
/// @note: If you specify a `itemAlignment`, only scale and rotation will be effective.
@property (nonatomic) CGAffineTransform transform;

/// The added image or PDF can be positioned relatively to the page.
@property (nonatomic) PSPDFRectAlignment alignment;

/// Specifies if the item alignment should be used. By default NO. If you set a `itemAlignment`, this will be set to YES automatically.
@property (nonatomic) BOOL shouldUseAlignment;

/// Specifies if the item is in the foreground or background. Defaults to `PSPDFItemPositionForeground`
@property (nonatomic) PSPDFItemZPosition zPosition;

@end

NS_ASSUME_NONNULL_END
