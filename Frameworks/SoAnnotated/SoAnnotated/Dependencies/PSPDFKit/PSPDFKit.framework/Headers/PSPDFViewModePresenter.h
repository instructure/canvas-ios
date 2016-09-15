//
//  PSPDFViewModePresenter.h
//  PSPDFKit
//
//  Copyright (c) 2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFPresentationContext.h"

@class PSPDFDocument;

NS_ASSUME_NONNULL_BEGIN

PSPDF_AVAILABLE_DECL @protocol PSPDFViewModePresenter <NSObject>

/// Convenience initializer.
/// @param layout The layout to use when loading the collection view.
/// @note If `nil`, a controller specific default layout is selected.
- (instancetype)initWithCollectionViewLayout:(nullable UICollectionViewLayout *)layout;

/// Convenience initializer. Initializes the controller with the default layout and stores the document.
- (instancetype)initWithDocument:(nullable PSPDFDocument *)document;

/// @name Data

/// Current edited document.
@property (nonatomic, nullable) PSPDFDocument *document;

/// Used access the configuration, class overrides, etc.
@property (nonatomic, weak) id<PSPDFPresentationContext> presentationContext;

/// @name Cells

/// Class used for thumbnails.
/// @warning Will be ignored if the layout is not a flow layout or a subclass thereof.
@property (nonatomic) Class cellClass;

/// @name Layout

/// A Boolean value specifying whether the thumbnails should be displayed in consistently spaced columns, or with consistent areas.
/// For documents where all pages are the same size, this setting has no effect.
/// If `YES`, thumbnails are laid out in columns. Landscape pages will be smaller than portrait pages. This tends to look better.
/// If `NO`, all thumbnails have approximatly the same area.
/// Defaults to `YES`.
@property (nonatomic) BOOL fixedItemSizeEnabled;

/// Adjusts the contentInset and scrollIndicatorInsets of the collectionView based on a bar that overlaps it by the specified height.
- (void)updateInsetsForTopOverlapHeight:(CGFloat)overlapHeight;

@end

NS_ASSUME_NONNULL_END
