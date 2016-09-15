//
//  PSPDFThumbnailFlowLayout.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFPresentationContext.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PSPDFThumbnailFlowLayoutAttributesType) {
    /// Marks attributes that relate to a single/standalone page.
    PSPDFThumbnailFlowLayoutAttributesTypeSingle,
    /// Marks attributes that relate to the left page in a two–page spread.
    PSPDFThumbnailFlowLayoutAttributesTypeLeft,
    /// Marks attributes that relate to the right page in a two–page spread.
    PSPDFThumbnailFlowLayoutAttributesTypeRight
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSInteger, PSPDFThumbnailFlowLayoutLineAlignment) {
    /// Layouts a line so that its items are left aligned inside the collection view.
    PSPDFThumbnailFlowLayoutLineAlignmentLeft,
    /// Layouts a line so that its items are centered inside the collection view.
    PSPDFThumbnailFlowLayoutLineAlignmentCenter,
    /// Layouts a line so that its items are right aligned inside the collection view.
    PSPDFThumbnailFlowLayoutLineAlignmentRight
} PSPDF_ENUM_AVAILABLE;

PSPDF_CLASS_AVAILABLE @interface PSPDFThumbnailFlowLayoutAttributes : UICollectionViewLayoutAttributes
@property (nonatomic) PSPDFThumbnailFlowLayoutAttributesType type;
@end

/// A layout similar to UICollectionViewFlowLayout with support for sticky headers
/// and double-page spreads, as you’d use it for the thumbnails of a magazine.
///
/// @note This layout only supports a single section. Using multiple sections is
///       unsupported and may result in undefined behavior.
///
/// @note This layout only supports a very limited horizontal scrolling mode which
///       you can enable by setting the `singleLineMode` property to `YES`.
PSPDF_CLASS_AVAILABLE @interface PSPDFThumbnailFlowLayout : UICollectionViewLayout

/// The insets used to lay out content in a section
///
/// The section insets effects the positioning of the items inisde a section. It
/// does not effect the positioning of the section header in any direction. Instead
/// the top section inset controls the spacing between the section header and the
/// first line of items in that section.
@property (nonatomic) UIEdgeInsets sectionInset;

/// The inter item spacing controls the spacing between items in horizontal direction.
///
/// Defaults to 10.0
@property (nonatomic) CGFloat interitemSpacing;

/// The line spacing controllers the spacing between items in vertical direction.
///
/// Defaults to 10.0
@property (nonatomic) CGFloat lineSpacing;

/// If the layout should horizontally position its items in one line, set this
/// value to `YES`.
///
/// Defaults to `NO`.
///
/// @note In single line mode headers are not supported and will result in an exception.
@property (nonatomic) BOOL singleLineMode;

/// Specifies how an incomplete lines (i.e. the last line when it has less items
/// than the previous lines) in the layout are aligned.
///
/// Defaults to PSPDFThumbnailFlowLayoutLineAlignmentLeft
@property (nonatomic) PSPDFThumbnailFlowLayoutLineAlignment incompleteLineAlignment;

/// Controls whether a section header should always stick to the top of the screen or not.
@property (nonatomic) BOOL stickyHeaderEnabled;

/// Disables double page mode, when `NO`, it will just follow the `presentationContext`. Defaults to `NO`.
@property (nonatomic) BOOL doublePageModeDisabled;

/// Returns `YES` if the current layout uses double page mode.
@property (nonatomic, readonly) BOOL doublePageMode;

/// We use this object to figure out if we want to use the double page mode and how to use it
@property (nonatomic, weak) id <PSPDFPresentationContext> presentationContext;

/// Returns the attributes type for the specified index path.
- (PSPDFThumbnailFlowLayoutAttributesType)typeForIndexPath:(NSIndexPath *)indexPath usingDoublePageMode:(BOOL)usingDoublePageMode;

/// Returns the index path for the other page in a double page, or `nil` if the type is single.
- (nullable NSIndexPath *)indexPathForDoublePage:(NSIndexPath *)indexPath;

@end

PSPDF_AVAILABLE_DECL @protocol PSPDFCollectionViewDelegateThumbnailFlowLayout <NSObject>

@optional
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout itemSizeAtIndexPath:(NSIndexPath *)indexPath;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout referenceSizeForHeaderInSection:(NSInteger)section;

@end

NS_ASSUME_NONNULL_END
