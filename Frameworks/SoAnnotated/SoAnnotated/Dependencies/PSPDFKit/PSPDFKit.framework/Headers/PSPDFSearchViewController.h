//
//  PSPDFSearchViewController.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFBaseTableViewController.h"

#import "PSPDFAnnotation.h"
#import "PSPDFCache.h"
#import "PSPDFOverridable.h"
#import "PSPDFStyleable.h"
#import "PSPDFTextSearch.h"

@class PSPDFDocument, PSPDFViewController, PSPDFSearchResult, PSPDFSearchResultCell;

typedef NS_ENUM(NSInteger, PSPDFSearchStatus) {
    /// Search hasn't started yet.
    PSPDFSearchStatusIdle,
    /// Search operation is running.
    PSPDFSearchStatusActive,
    /// Search has been finished.
    PSPDFSearchStatusFinished,
    /// Search finished but there wasn't any content to search.
    PSPDFSearchStatusFinishedNoText,
    /// Search has been cancelled.
    PSPDFSearchStatusCancelled
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSUInteger, PSPDFSearchBarPinning) {
    /// Pin unless in a popover presentation.
    PSPDFSearchBarPinningAuto,
    /// Pin search bar to top.
    PSPDFSearchBarPinningTop,
    /// Embed the search bar inside the table view.
    PSPDFSearchBarPinningNone,
} PSPDF_ENUM_AVAILABLE;

@class PSPDFSearchViewController;

NS_ASSUME_NONNULL_BEGIN

/// Delegate for the search view controller.
/// @note This is a specialization of `PSPDFTextSearchDelegate`.
PSPDF_AVAILABLE_DECL @protocol PSPDFSearchViewControllerDelegate <PSPDFTextSearchDelegate, PSPDFOverridable>

@optional

/// Called when the user taps on a controller result cell.
- (void)searchViewController:(PSPDFSearchViewController *)searchController didTapSearchResult:(PSPDFSearchResult *)searchResult;

/// Will be called when the controller clears all search results.
- (void)searchViewControllerDidClearAllSearchResults:(PSPDFSearchViewController *)searchController;

/// Asks for the visible pages to optimize search ordering.
- (NSArray<NSNumber *> *)searchViewControllerGetVisiblePages:(PSPDFSearchViewController *)searchController;

/// Allows to narrow down the search range if a scope is set.
- (nullable NSIndexSet *)searchViewController:(PSPDFSearchViewController *)searchController searchRangeForScope:(NSString *)scope;

/// Requests the text search class. Creates a custom class if not implemented.
- (PSPDFTextSearch *)searchViewControllerTextSearchObject:(PSPDFSearchViewController *)searchController;

@end

/// Allows to search within the current `document`.
PSPDF_CLASS_AVAILABLE @interface PSPDFSearchViewController : PSPDFBaseTableViewController <UISearchDisplayDelegate, UISearchBarDelegate, PSPDFTextSearchDelegate, PSPDFStyleable>

/// Designated initializer.
- (instancetype)initWithDocument:(nullable PSPDFDocument *)document NS_DESIGNATED_INITIALIZER;

/// The current document.
@property (nonatomic, nullable) PSPDFDocument *document;

/// The search view controller delegate.
@property (nonatomic, weak) IBOutlet id<PSPDFSearchViewControllerDelegate> delegate;

/// Current searchText. If set before showing the controller, keyboard will not be added.
@property (nonatomic, copy, nullable) NSString *searchText;

/// Different behavior depending on size classes.
@property (nonatomic) BOOL showsCancelButton;

/// Search bar for controller.
/// @warning You can change attributes (e.g. `barStyle`) but don't change the delegate!
@property (nonatomic, readonly) UISearchBar *searchBar;

/// Current search status. KVO observable.
@property (nonatomic, readonly) PSPDFSearchStatus searchStatus;

/// Clears highlights when controller disappears. Defaults to NO.
@property (nonatomic) BOOL clearHighlightsWhenClosed;

/// Defaults to 600. A too high number will be slow.
@property (nonatomic) NSUInteger maximumNumberOfSearchResultsDisplayed;

/// Set to enable searching on the visible pages, then all. Defaults to NO.
/// If not set, the natural page order is searched.
@property (nonatomic) BOOL searchVisiblePagesFirst;

/// Number of lines to show preview text. Defaults to 2.
@property (nonatomic) NSUInteger numberOfPreviewTextLines;

/// Searches the outline for the most matching entry, displays e.g. "Section 100, Page 2" instead of just "Page 2".
/// Defaults to YES.
@property (nonatomic) BOOL useOutlineForPageNames;

/// The last search result is restored in `viewWillAppear:` if the document UID matches the last used one.
/// This search result is only persisted in memory. Defaults to YES.
/// @note Needs to be set before the view controller is presented to have an effect.
@property (nonatomic) BOOL restoreLastSearchResult;

/// Will include annotations that have a matching type into the search results. (contents will be searched).
/// Defaults to PSPDFAnnotationTypeAll&~PSPDFAnnotationTypeLink.
/// @note Requires the `PSPDFFeatureMaskAnnotationEditing` feature flag.
@property (nonatomic) PSPDFAnnotationType searchableAnnotationTypes;

/// Determines the searchbar positioning. Defaults to PSPDFSearchBarPinningAuto.
@property (nonatomic) PSPDFSearchBarPinning searchBarPinning;

/// Internally used `PSPDFTextSearch` object.
/// (is a copy of the PSPDFTextSearch class in document)
@property (nonatomic, readonly, nullable) PSPDFTextSearch *textSearch;

/// Call to force a search restart. Useful if the underlying content has changed.
- (void)restartSearch;

@end

@interface PSPDFSearchViewController (SubclassingHooks)

/// Called every time the text in the search bar changes.
- (void)filterContentForSearchText:(NSString *)searchText scope:(nullable NSString *)scope;

/// Will update the status and insert/reload/remove search rows
- (void)setSearchStatus:(PSPDFSearchStatus)searchStatus updateTable:(BOOL)updateTable;

/// Returns the searchResult for a cell.
- (PSPDFSearchResult *)searchResultForIndexPath:(NSIndexPath *)indexPath;

/// Will return a searchbar. Called during `viewDidLoad`. Use to customize the toolbar.
/// This method does basic properties like `tintColor`, `showsCancelButton` and `placeholder`.
/// After calling this, the delegate will be set to this class.
@property (nonatomic, readonly) UISearchBar *createSearchBar;

/// Currently loaded search results.
@property (nonatomic, copy, readonly, nullable) NSArray<PSPDFSearchResult *> *searchResults;

@end

NS_ASSUME_NONNULL_END
