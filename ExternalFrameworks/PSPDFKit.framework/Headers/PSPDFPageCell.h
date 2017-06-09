//
//  PSPDFPageCell.h
//  PSPDFKit
//
//  Copyright © 2016-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFMacros.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// This protocol contains information about an image request.
PSPDF_AVAILABLE_DECL @protocol PSPDFPageCellImageRequestToken<NSObject>

/**
 The expected size of the image, once it will be returned. This size may or may
 not be equal to the size of the returned image. It is the best available information
 from the creation time of the image request.
 */
@property (nonatomic, readonly) CGSize expectedSize;

@optional

/**
 An image to be displayed while the main image is still loading.

 This could be an image in a lower resolution or one that is not as accurate as
 the final image.
 */
@property (nonatomic, readonly, nullable) UIImage *placeholderImage;

/**
 Cancels an image request. If the image request is not cancellable this method
 either does nothing or is not available.
 */
- (void)cancel;

@end

/// This protocol is responsible for loading images and providing it to the `PSPDFPageCell` whenever requested by it.
PSPDF_AVAILABLE_DECL @protocol PSPDFPageCellImageLoading<NSObject>

/**
 Called by the cell if it requires a new image from the image loader.

 @param pageIndex         The page that should be rendered.
 @param size              The available size in which the new image needs to fit.
 @param completionHandler The completion handler that you call once you have rendered the image. This can be called on any thread.

 @see PSPDFPageCellImageRequestToken

 @return A token that identifies this image request. It can be used to get more information or cancel the request.
 */
- (id<PSPDFPageCellImageRequestToken>)requestImageForPageAtIndex:(NSUInteger)pageIndex availableSize:(CGSize)size completionHandler:(void (^)(UIImage *_Nullable image))completionHandler;

@end

/// Common superclass for various collection view cells representing PDF pages.
PSPDF_CLASS_AVAILABLE @interface PSPDFPageCell : UICollectionViewCell

/// Referenced page.
@property (nonatomic) NSUInteger pageIndex;

/// Allow a margin. Defaults to `UIEdgeInsetsZero`.
@property (nonatomic) UIEdgeInsets edgeInsets;

/// Enables thumbnail shadow. defaults to NO.
@property (nonatomic, getter=isShadowEnabled) BOOL shadowEnabled;

/// Enable page label.
@property (nonatomic, getter=isPageLabelEnabled) BOOL pageLabelEnabled;

/// @name Updating the Image

/// If something has changed that requires the image to be reloaded you can call that method.
/// The image then will be reloaded on the next layout pass.
- (void)setNeedsUpdateImage;

/// The image loader the cell should use to render images.
///
/// @note This is a retained object. Be sure to not create retain cycles.
@property (nonatomic, nullable) id<PSPDFPageCellImageLoading> imageLoader;

@end

@interface PSPDFPageCell (Subviews)

/// Page label. Defaults to a label with a rounded semi-translucent background.
@property (nonatomic, readonly) UILabel *pageLabel;

/// Internal image view.
@property (nonatomic, readonly) UIImageView *imageView;

@end

@interface PSPDFPageCell (SubclassingHooks)

/// Set image after your `imageUpdate` block gets called.
@property (nonatomic, nullable) UIImage *image;

/// Creates the shadow. Subclass to change.
- (nullable UIBezierPath *)pathShadowForView:(UIView *)imageView;

/// The content rect that can be used for rendering content.
///
/// The default implementation takes the `edgeInsets` into account.
///
/// @param bounds The bounds that should be used to calculate the content rect from.
///
/// @return The calculated content rect.
- (CGRect)contentRectForBounds:(CGRect)bounds;

/// The image rect that should be used for displaying the image.
///
/// This will be used to calculate the frame of the internal image view.
///
/// @param contentRect The content rect in which the image rect should be positioned.
///
/// @return The image rect where the image should be drawn.
- (CGRect)imageRectForContentRect:(CGRect)contentRect;

@end

NS_ASSUME_NONNULL_END
