//
//  PSPDFThumbnailFlowLayout.h
//  PSPDFKit
//
//  Copyright © 2013-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFPresentationContext.h"

NS_ASSUME_NONNULL_BEGIN

/// Layout attributes for thumbnail cells depending on the display type.
typedef NS_ENUM(NSInteger, PSPDFThumbnailFlowLayoutAttributesType) {
    /// Marks attributes that relate to a single/standalone page.
    PSPDFThumbnailFlowLayoutAttributesTypeSingle,
    /// Marks attributes that relate to the leading page in a two-page spread.
    PSPDFThumbnailFlowLayoutAttributesTypeLeading,
    /// Marks attributes that relate to the trailing page in a two-page spread.
    PSPDFThumbnailFlowLayoutAttributesTypeTrailing,

    /// Marks attributes that relate to the left page in a two–page spread.
    PSPDFThumbnailFlowLayoutAttributesTypeLeft PSPDF_DEPRECATED_IOS(6.5.1, "This is no longer accurate with the introduction of RTL support.") = PSPDFThumbnailFlowLayoutAttributesTypeLeading,
    /// Marks attributes that relate to the right page in a two–page spread.
    PSPDFThumbnailFlowLayoutAttributesTypeRight PSPDF_DEPRECATED_IOS(6.5.1, "This is no longer accurate with the introduction of RTL support.") = PSPDFThumbnailFlowLayoutAttributesTypeTrailing,
} PSPDF_ENUM_AVAILABLE;

/// Define the alignment of the thumbnail collection view.
typedef NS_ENUM(NSInteger, PSPDFThumbnailFlowLayoutLineAlignment) {
    /// Layouts a line so that its items are left aligned inside the collection view.
    PSPDFThumbnailFlowLayoutLineAlignmentLeft,
    /// Layouts a line so that its items are centered inside the collection view.
    PSPDFThumbnailFlowLayoutLineAlignmentCenter,
    /// Layouts a line so that its items are right aligned inside the collection view.
    PSPDFThumbnailFlowLayoutLineAlignmentRight,
    /// Layouts a line so that its items are aligned alongside the contents page binding. (Default value)
    PSPDFThumbnailFlowLayoutLineAlignmentPageBinding,
} PSPDF_ENUM_AVAILABLE;

/// Layout attributes for the thubmnail collection view.
PSPDF_CLASS_AVAILABLE @interface PSPDFThumbnailFlowLayoutAttributes : UICollectionViewLayoutAttributes
@property (nonatomic) PSPDFThumbnailFlowLayoutAttributesType type;
@end

/**
 A layout similar to UICollectionViewFlowLayout with support for sticky headers
 and double-page spreads, as you’d use it for the thumbnails of a magazine.
 
 @note This layout only supports a single section. Using multiple sections is
 unsupported and may result in undefined behavior.
 
 @note This layout only supports a very limited horizontal scrolling mode which
 you can enable by setting the `singleLineMode` property to `YES`.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFThumbnailFlowLayout : UICollectionViewLayout

/**
 The insets used to lay out content in a section
 
 The section insets effects the positioning of the items inisde a section. It
 does not effect the positioning of the section header in any direction. Instead
 the top section inset controls the spacing between the section header and the
 first line of items in that section.
 */
@property (nonatomic) UIEdgeInsets sectionInset;

/**
 The inter item spacing controls the spacing between items in horizontal direction.
 
 Defaults to 10.0
 */
@property (nonatomic) CGFloat interitemSpacing;

/**
 The line spacing controllers the spacing between items in vertical direction.
 
 Defaults to 10.0
 */
@property (nonatomic) CGFloat lineSpacing;

/**
 If the layout should horizontally position its items in one line, set this
 value to `YES`.
 
 Defaults to `NO`.
 
 @note In single line mode headers are not supported and will result in an exception.
 */
@property (nonatomic) BOOL singleLineMode;

/**
 Specifies how an incomplete lines (i.e. the last line when it has less items
 than the previous lines) in the layout are aligned.
 
 Defaults to PSPDFThumbnailFlowLayoutLineAlignmentLeft
 */
@property (nonatomic) PSPDFThumbnailFlowLayoutLineAlignment incompleteLineAlignment;

/// Controls whether a section header should always stick to the top of the screen or not.
@property (nonatomic) BOOL stickyHeaderEnabled;

/// Disables double page mode, when `NO`, it will just follow the `presentationContext`. Defaults to `NO`.
@property (nonatomic) BOOL doublePageModeDisabled;

/// Returns `YES` if the current layout uses double page mode.
@property (nonatomic, readonly) BOOL doublePageMode;

/// We use this object to figure out if we want to use the double page mode and how to use it
@property (nonatomic, weak) id<PSPDFPresentationContext> presentationContext;

/// Returns the attributes type for the specified index path.
- (PSPDFThumbnailFlowLayoutAttributesType)typeForIndexPath:(NSIndexPath *)indexPath usingDoublePageMode:(BOOL)usingDoublePageMode;

/// Returns the index path for the other page in a double page, or `nil` if the type is single.
- (nullable NSIndexPath *)indexPathForDoublePage:(NSIndexPath *)indexPath;

@end

/// Delegate for the collection view thumbnail flow layout.
PSPDF_AVAILABLE_DECL @protocol PSPDFCollectionViewDelegateThumbnailFlowLayout<NSObject>

@optional

/**
 Asks the delegate for an item size for a given index path.

 @warning In multi line mode layouts (i.e. singleLineMode returns `NO`),
          `collectionView:layout:itemSizeAtIndexPath:completionHandler:` takes
          precedence over this method.

 @param collectionView The collection view object displaying the item.
 @param layout         The collection view layout used for positioning the item.
 @param indexPath      The index path of the item.

 @return The size that the item should be layed out with.
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout itemSizeAtIndexPath:(NSIndexPath *)indexPath;

/**
 Asks the delegate for an item size for a given index path and gives the option
 to update this size later on once expensive size calculations are finished.

 If you are doing expensive size calculation you can implement this method to
 immediately return an estimate size and then do your size calculation on a background
 thread. Once done with the calculation, you can pass the correct height to the
 layout by calling the completion handler. Continuous calls to the completion handler
 will be ignored and only the first call will be used to update the size of the
 item.

 @note In case the layout is in single line mode, this method will not be called.
       Instead, only the method without a completion handler will be called as
       estimated sizing is not available for this mode.

 @warning In multi line mode layouts (i.e. singleLineMode returns `NO`), this method
          takes precedence over `collectionView:layout:itemSizeAtIndexPath:`.

 @param collectionView    The collection view object displaying the item.
 @param layout            The collection view layout used for positioning the item.
 @param indexPath         The index path of the item.
 @param completionHandler A completion handler than can optionally be called if you
                          need to do expensive height calculation asynchronously.
                          Can be called from an arbitraty queue.

 @return The size that the item currently should be layed out with. This can be
         an estimate in case you use the completion handler.
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout itemSizeAtIndexPath:(NSIndexPath *)indexPath completionHandler:(void (^)(CGSize itemSize))completionHandler;

/**
 Asks the delegate for the size of the header view in the specified section.

 @param collectionView The collection view object displaying the header view.
 @param layout         The collection view layout used for positioning the header view.
 @param section        The section of the header.

 @return The size the header should have in the layout.
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout referenceSizeForHeaderInSection:(NSInteger)section;

@end

NS_ASSUME_NONNULL_END
