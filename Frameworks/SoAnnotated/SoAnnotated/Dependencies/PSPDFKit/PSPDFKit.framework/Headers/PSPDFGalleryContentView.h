//
//  PSPDFGalleryContentView.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFGalleryContentViewProtocols.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFGalleryItem;

/// The (reusable) content view of a `PSPDFGalleryView`.
PSPDF_CLASS_AVAILABLE @interface PSPDFGalleryContentView : UIView

/// @name Initialization

/// Convenience initializer.
/// Creates a new content view with a reuse identifier. It is highly recommended that you always
/// reuse content views to avoid performance issues. The API works exactly like `UITableView`.
- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier;

/// @name Views

/// The content view.
@property (nonatomic, readonly) UIView *contentView;

/// The loading view.
@property (nonatomic, readonly) UIView<PSPDFGalleryContentViewLoading> *loadingView;

/// The caption view.
@property (nonatomic, readonly) UIView<PSPDFGalleryContentViewCaption> *captionView;

/// The error view.
@property (nonatomic, readonly) UIView<PSPDFGalleryContentViewError> *errorView;

/// @name State

/// The reuse identifier if the view was created with `initWithReuseIdentifier:`. You should always
/// reuse views to avoid performance issues.
@property (nonatomic, copy, nullable) NSString *reuseIdentifier;

/// The content item.
@property (nonatomic, nullable) PSPDFGalleryItem *content;

/// Indicates if the caption should be visible. Defaults to `NO`.
/// @note This property is only a hint to the content view. The caption might still be hidden
/// even if this property is set to `NO`.
@property (nonatomic) BOOL shouldHideCaption;

@end

@interface PSPDFGalleryContentView (SubclassingHooks)

/// Returns the class for `contentView`. Defaults to `Nil`.
/// @note The class must be a subclass of `UIView`.
/// @warning This is an abstract class. Your subclass must override this method!
+ (Class)contentViewClass;

/// Returns the class for `loadingView`. Defaults to `PSPDFCircularProgressView`.
/// @note The class must be a subclass of `UIView` and conform to the `PSPDFGalleryContentViewLoading` protocol.
+ (Class)loadingViewClass;

/// Returns the class for `captionView`. Defaults to `PSPDFGalleryContentCaptionView.class`.
/// @note The class must be a subclass of `UIView` and conform to the `PSPDFGalleryContentViewCaption` protocol.
+ (Class)captionViewClass;

/// Returns the class for `errorView`. Defaults to `PSPDFErrorView.class`.
/// @note The class must be a subclass of `UIView` and conform to the `PSPDFGalleryContentViewError` protocol.
+ (Class)errorViewClass;

/// The frame of the content view.
@property (nonatomic, readonly) CGRect contentViewFrame;

/// The frame of the loading view.
@property (nonatomic, readonly) CGRect loadingViewFrame;

/// The frame of the caption view.
@property (nonatomic, readonly) CGRect captionViewFrame;

/// The frame of the error view.
@property (nonatomic, readonly) CGRect errorViewFrame;

/// Updates the content view's contents.
/// @warning This is an abstract class. Your subclass must override this method!
- (void)updateContentView;

/// Updates the caption view's contents.
- (void)updateCaptionView NS_REQUIRES_SUPER;

/// Updates the error view's contents.
- (void)updateErrorView NS_REQUIRES_SUPER;

/// Updates the loading view's contents.
- (void)updateLoadingView NS_REQUIRES_SUPER;

/// Called before reusing the content view to give it a chance to restore its initial state.
- (void)prepareForReuse NS_REQUIRES_SUPER;

/// Use this method to update your content view.
- (void)contentDidChange NS_REQUIRES_SUPER;

/// Called when the view state of the content view has changed and subview visibility is likely
/// going to change.
- (void)updateSubviewVisibility NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
