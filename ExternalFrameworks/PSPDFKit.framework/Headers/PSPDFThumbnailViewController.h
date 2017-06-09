//
//  PSPDFThumbnailViewController.h
//  PSPDFKit
//
//  Copyright © 2013-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFBaseViewController.h"
#import "PSPDFDocument.h"
#import "PSPDFPresentationContext.h"
#import "PSPDFSegmentedControl.h"
#import "PSPDFViewModePresenter.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFThumbnailViewController, PSPDFThumbnailGridViewCell, PSPDFCenteredLabelView;

/// Subclass to enable `UIAppearance` rules on the filter.
PSPDF_CLASS_AVAILABLE @interface PSPDFThumbnailFilterSegmentedControl : PSPDFSegmentedControl
@end

/// Show all thumbnails.
PSPDF_EXPORT NSString *const PSPDFThumbnailViewFilterShowAll;

/// Show bookmarked thumbnails.
PSPDF_EXPORT NSString *const PSPDFThumbnailViewFilterBookmarks;

/// All annotation types except links. Requires the `PSPDFFeatureMaskAnnotationEditing` feature flag.
PSPDF_EXPORT NSString *const PSPDFThumbnailViewFilterAnnotations;

/// Delegate for thumbnail actions.
PSPDF_AVAILABLE_DECL @protocol PSPDFThumbnailViewControllerDelegate<NSObject>

@optional

/// A thumbnail has been selected.
- (void)thumbnailViewController:(PSPDFThumbnailViewController *)thumbnailViewController didSelectPageAtIndex:(NSUInteger)pageIndex inDocument:(PSPDFDocument *)document;

@end

/// The thumbnail view controller.
PSPDF_CLASS_AVAILABLE @interface PSPDFThumbnailViewController : UICollectionViewController<UICollectionViewDataSource, UICollectionViewDelegate, PSPDFViewModePresenter>

/// Data source to get double page mode.
@property (nonatomic, weak) IBOutlet id<PSPDFPresentationContext> dataSource;

/// Delegate for the thumbnail controller.
/// @note If this instance has been created by `PSPDFViewController` the delegate is already linked and should not be changed.
@property (nonatomic, weak) IBOutlet id<PSPDFThumbnailViewControllerDelegate> delegate;

/// Get the cell for certain page. Compensates against open filters.
/// @note `document` is ignored in the default implementation.
- (nullable UICollectionViewCell *)cellForPageAtIndex:(NSUInteger)pageIndex document:(nullable PSPDFDocument *)document;

/// Scrolls to specified page in the grid.
/// @note `document` is ignored in the default implementation.
- (void)scrollToPageAtIndex:(NSUInteger)pageIndex document:(nullable PSPDFDocument *)document animated:(BOOL)animated;

/// Stops an ongoing scroll animation.
- (void)stopScrolling;

/// Call to update any filter (if set) all visible cells (e.g. to show bookmark changes)
- (void)updateFilterAndVisibleCellsAnimated:(BOOL)animated;

/// Makes the filter bar sticky. Defaults to NO.
///
/// When setting this property to `YES`, you should also take care of customizing the section header such that it has a visible background.
/// You can do so either by setting the `backgroundColor` or `backgroundStyle` of the appearance of `PSPDFCollectionReusableFilterView` or—if you need finer grained control—by overriding `-collectionView:viewForSupplementaryElementOfKind:atIndexPath:`.
/// @note This property is a forward to the layout’s `stickyHeaderEnabled` property.
/// Therefore, overriding the getter will earn you nothing.
/// If you have to override the setter, you should therefore call super.
/// When `stickyHeaderEnabled` is set to `YES`, `updateInsetsForTopOverlapHeight:` method adjusts the collection view’s `scrollIndicatorInsets` such that the vertical scroll indicator does not overlap the header.
/// This makes sense because the scrollable content area no longer includes the header, but it will look weird if you don’t give the header a background.
/// @see updateInsetsForTopOverlapHeight:
/// @see collectionView:viewForSupplementaryElementOfKind:atIndexPath:
/// @see backgroundStyle (PSPDFCollectionReusableFilterView)
@property (nonatomic) BOOL stickyHeaderEnabled PSPDF_DEPRECATED(5.3.4, "Use `stickyHeaderEnabled` on the layout instead, if your layout supports it. The default layout does so.");

/// Defines the filter options. Set to nil or empty to hide the filter bar.
/// Defaults to `PSPDFThumbnailViewFilterShowAll, PSPDFThumbnailViewFilterAnnotations, PSPDFThumbnailViewFilterBookmarks`.
@property (nonatomic, copy, null_resettable) NSArray<NSString *> *filterOptions;

/// Currently active filter. Make sure that one is also set in `filterOptions`.
@property (nonatomic, copy) NSString *activeFilter;
- (void)setActiveFilter:(NSString *)activeFilter animated:(BOOL)animated;

/// Class used for thumbnails. Defaults to `PSPDFThumbnailGridViewCell` and customizations should be a subclass of thereof.
/// @see `-[PSPDFViewModePresenter cellClass]`
@property (nonatomic) Class cellClass;

/// Returns a suitable size for a thumbnail of a page in a given container size.
+ (CGSize)automaticThumbnailSizeForPageWithSize:(CGSize)pageSize referencePageSize:(CGSize)referencePageSize containerSize:(CGSize)containerSize interitemSpacing:(CGFloat)interitemSpacing;

@end

@interface PSPDFThumbnailViewController (SubclassingHooks)

/// Subclass to customize thumbnail cell configuration.
- (void)configureCell:(PSPDFThumbnailGridViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;

/// Returns the page for the `indexPath`. Override if you structure the cells differently.
- (NSUInteger)pageForIndexPath:(NSIndexPath *)indexPath;

/// The filter segment to filter bookmarked/annotated documents.
@property (nonatomic, readonly, nullable) PSPDFThumbnailFilterSegmentedControl *filterSegment;

/// The filter segment is recreated on changes; to customize subclass this class and override `updateFilterSegment`.
- (void)updateFilterSegment;

/// Used to filter the document pages. Customize to tweak page display (e.g. add sorting when in bookmark mode)
- (nullable NSArray<NSNumber *> *)pagesForFilter:(NSString *)filter;

/// Return label when there's no content for the filter.
- (nullable NSString *)emptyContentLabelForFilter:(NSString *)filter;

/// Updates the empty view.
- (void)updateEmptyView;

/// Returns an instance of PSPDFCollectionReusableFilterView for the header of section 0, nil otherwise.
///
/// Override this method if you need to customize the header in ways that `UIAppearance` does not support or on an instance by instance basis.
/// If, for example, your app has instances of this class that use the sticky header and instances that don’t, you could do the following:
/// <code>
/// - (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
///     PSPDFCollectionReusableFilterView *header = (id)[super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
///     if ([header isKindOfClass:PSPDFCollectionReusableFilterView.class]) {
///         // Sticky header should have a background, regular header should not.
///         // If you use a solid, accented background color for the sticky header, but want a seamless look for the non–sticky header this makes even more sense.
///         header.backgroundStyle = self.stickyHeaderEnabled ? PSPDFCollectionReusableFilterViewStyleDarkBlur : PSPDFCollectionReusableFilterViewStyleNone;
///         // Assuming we want the filter element to sit very close to the items:
///         header.filterElementOffset = CGPointMake(0, 10);
///     }
///     return header;
/// }
/// </code>
/// @see stickyHeaderEnabled
/// @see updateInsetsForTopOverlapHeight:
/// @see backgroundStyle (PSPDFCollectionReusableFilterView)
- (UICollectionReusableView *_Nullable)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
