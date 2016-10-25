//
//  PSPDFGalleryImageContentView.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFGalleryContentView.h"
#import "PSPDFGalleryImageItem.h"
#import "PSPDFMacros.h"

NS_ASSUME_NONNULL_BEGIN

PSPDF_CLASS_AVAILABLE @interface PSPDFGalleryImageContentView : PSPDFGalleryContentView

/// Set this to YES if zooming should be enabled. This value only has an effect if an image
/// is currently displayed. Defaults to NO.
@property (nonatomic, getter=isZoomEnabled) BOOL zoomEnabled;

/// The maximum zoom scale that you want to allow. Only meaningful if zoomEnabled is YES.
/// Defaults to 5.0.
@property (nonatomic) CGFloat maximumZoomScale;

/// The minimum zoom scale that you want to allow. Only meaningful if zoomEnabled is YES.
/// Defaults to 1.0.
@property (nonatomic) CGFloat minimumZoomScale;

/// The current zoom scale. This is only meaningful if zoomEnabled is YES. Defaults to 1.0.
@property (nonatomic) CGFloat zoomScale;

/// Sets the current zoom scale, but only if `zoomEnabled` is YES and
/// `minimumZoomScale <= zoomScale <= maximumZoomScale` is true.
- (void)setZoomScale:(CGFloat)zoomScale animated:(BOOL)animated;

/// `PSPDFGalleryImageContentView` expects an `PSPDFGalleryImageItem` as its content.
@property (nonatomic, nullable) PSPDFGalleryImageItem *content;

/// `PSPDFGalleryImageContentView` expects an `UIImageView` as its `contentView`.
@property (nonatomic, readonly) UIImageView *contentView;

@end

NS_ASSUME_NONNULL_END
