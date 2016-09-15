//
//  PSPDFProcessorItem.h
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
#import "PSPDFProcessorItemBuilder.h"

NS_ASSUME_NONNULL_BEGIN

/// Represents an item that can be added to either a new page or an existing page.
/// The item can either be a `UIImage` which will then be compressed as a JPEG using `imageJpegCompressionQuality` or
/// a `NSURL` that points to a JPEG or PDF file.
PSPDF_CLASS_AVAILABLE @interface PSPDFProcessorItem : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Configures a `PSPDFProcessorItem` with a `image` and allows you to configure it using the `builder`.
+ (instancetype)processorItemWithImage:(UIImage *)image jpegCompressionQuality:(CGFloat)jpegCompressionQuality builderBlock:(nullable void (^)(PSPDFProcessorItemBuilder *builder))builderBlock;

/// Configures a `PSPDFProcessorItem` with a `itemURL` and allows you to configure it using the `builder`.
/// @note `itemURL` must point to a local JPEG or PDF file.
+ (instancetype)processorItemWithItemURL:(NSURL *)itemURL builderBlock:(nullable void (^)(PSPDFProcessorItemBuilder *builder))builderBlock;

/// The image that will be added to the page.
@property (nonatomic, readonly, nullable) UIImage *image;

/// The itemURL that will be added to the page. Can either be a JPEG or PDF file.
@property (nonatomic, readonly, nullable) NSURL *itemURL;

/// The `image` or `itemURL` can be positioned, scaled and rotated with `itemRect`
/// @note: If you specify a `itemAlignment`, only scale and rotation will be effective.
@property (nonatomic, readonly) CGAffineTransform transform;

/// The compression that should be used for the JPEG image when embedding into the PDF. Can be 0.0f to 1.0f.
/// @note If you specify a JPEG image using `itemURL`, this will have no effect as image won't be recompressed.
@property (nonatomic, readonly) CGFloat jpegCompressionQuality;

/// The `PSPDFRectAlignment` of the item.
@property (nonatomic, readonly) PSPDFRectAlignment alignment;

/// Specifies if the `itemAlignment` should be used.
@property (nonatomic, readonly) BOOL shouldUseAlignment;

/// Specifies if the item is in the foreground or background.
@property (nonatomic, readonly) PSPDFItemZPosition zPosition;

@end

NS_ASSUME_NONNULL_END
