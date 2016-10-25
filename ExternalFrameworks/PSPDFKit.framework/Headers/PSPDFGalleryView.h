//
//  PSPDFGalleryView.h
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

@class PSPDFGalleryContentView;
@protocol PSPDFGalleryViewDataSource, PSPDFGalleryViewDelegate;

/// A gallery view works a lot like a `UITableView`. It has content views, which need to be provided by
/// a data source and can be reused. It is built on top of a `UIScrollView`.
PSPDF_CLASS_AVAILABLE @interface PSPDFGalleryView : UIScrollView

/// The data source of the gallery view.
@property (nonatomic, weak) id<PSPDFGalleryViewDataSource> dataSource;

/// The padding between successive content views. Defaults to 5.0.
@property (nonatomic) CGFloat contentPadding;

/// The delegate of the gallery view (same as `UIScrollView`)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"
- (void)setDelegate:(nullable id<PSPDFGalleryViewDelegate>)delegate;
- (nullable id<PSPDFGalleryViewDelegate>)delegate;
#pragma clang diagnostic pop

/// Reloads the gallery view.
- (void)reload;

/// Returns the `PSPDFGalleryContentView` for the given item index or `nil` if does not exist or is not part of `activeContentViews`.
- (nullable PSPDFGalleryContentView *)contentViewForItemAtIndex:(NSUInteger)index;

/// Returns the index for a given content view or `NSNotFound` if the content view cannot be matched to an index.
- (NSUInteger)itemIndexForContentView:(PSPDFGalleryContentView *)contentView;

/// Returns a reusable content view for a given identifier or `nil` if no content view is available
/// for reuse.
- (nullable PSPDFGalleryContentView *)dequeueReusableContentViewWithIdentifier:(NSString *)identifier;

/// The currently visible item index.
@property (nonatomic) NSUInteger currentItemIndex;

/// Sets the currently visible item index with or without animation.
- (void)setCurrentItemIndex:(NSUInteger)currentItemIndex animated:(BOOL)animated;

/// The currently active content views, that is the content views that are visible or are next to a visible content view.
@property (nonatomic, readonly) NSSet *activeContentViews;

/// Enables the loop mode, where the gallery wraps around at both ends. Defaults to `NO`.
/// @note Loop mode is only usable if more than two items are presented. Otherwise this setting will be ignored.
@property (nonatomic, getter=isLoopEnabled) BOOL loopEnabled;

@end

PSPDF_AVAILABLE_DECL @protocol PSPDFGalleryViewDataSource <NSObject>

/// The number if items in a gallery.
- (NSUInteger)numberOfItemsInGalleryView:(PSPDFGalleryView *)galleryView;

/// The content view for the given index.
- (PSPDFGalleryContentView *)galleryView:(PSPDFGalleryView *)galleryView contentViewForItemAtIndex:(NSUInteger)index;

@end

PSPDF_AVAILABLE_DECL @protocol PSPDFGalleryViewDelegate <UIScrollViewDelegate>

@optional

/// Called when `currentItemIndex` changes.
- (void)galleryView:(PSPDFGalleryView *)galleryView willScrollToItemAtIndex:(NSUInteger)index;
- (void)galleryView:(PSPDFGalleryView *)galleryView didScrollToItemAtIndex:(NSUInteger)index;

/// Called before reusing a content view.
- (void)galleryView:(PSPDFGalleryView *)galleryView willReuseContentView:(PSPDFGalleryContentView *)contentView;

@end

NS_ASSUME_NONNULL_END
