//
//  PSPDFInlineSearchManager.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFTextSearch.h"
#import "PSPDFSearchViewController.h" //HACK: imported because of 'PSPDFSearchStatus'
#import "PSPDFPresentationContext.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFInlineSearchManager;

/// The delegate for the `PSPDFInlineSearchManager` class.
PSPDF_AVAILABLE_DECL @protocol PSPDFInlineSearchManagerDelegate <PSPDFTextSearchDelegate, PSPDFOverridable>

@optional

/// `searchResult` has been focussed.
- (void)inlineSearchManager:(PSPDFInlineSearchManager *)manager didFocusSearchResult:(PSPDFSearchResult *)searchResult;

/// All search results have been cleared.
- (void)inlineSearchManagerDidClearAllSearchResults:(PSPDFInlineSearchManager *)manager;

/// The inline search view will appear.
- (void)inlineSearchManagerSearchWillAppear:(PSPDFInlineSearchManager *)manager;

/// The inline search view did appear.
- (void)inlineSearchManagerSearchDidAppear:(PSPDFInlineSearchManager *)manager;

/// The inline search view will disappear.
- (void)inlineSearchManagerSearchWillDisappear:(PSPDFInlineSearchManager *)manager;

/// The inline search view did disappear.
- (void)inlineSearchManagerSearchDidDisappear:(PSPDFInlineSearchManager *)manager;

@required

/// Inline search UI will be added to returned view and brought to front every time `presentInlineSearch` is called.
/// An assertion is raised if this method returns `nil`.
- (UIView *)inlineSearchManagerContainerView:(PSPDFInlineSearchManager *)manager;

@end

/// `PSPDFInlineSearchManager` manages the presentation of a search bar that may be used to find text in a `PSPDFDocument`.
/// The search bar sides down from the top, typically covering the navigation bar.
PSPDF_CLASS_AVAILABLE @interface PSPDFInlineSearchManager : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Designated initializer.
- (instancetype)initWithPresentationContext:(id<PSPDFPresentationContext>)presentationContext NS_DESIGNATED_INITIALIZER;

/// Presents a search bar, optionally with pre-filled text.
/// @param text Text to show in the search bar initially, or `nil` if the bar should start empty.
/// @param animated A Boolean value specifying whether to animate the search bar sliding down from above the container view.
- (void)presentInlineSearchWithSearchText:(nullable NSString *)text animated:(BOOL)animated;

/// Hides the previously presented search bar.
/// @param animated A Boolean value specifying whether to animate the search bar sliding up to above the container view.
- (BOOL)hideInlineSearchAnimated:(BOOL)animated;

/// Hides the keyboard, but the search UI stays visible.
- (void)hideKeyboard;

/// Returns YES is search UI is visible. Returns yes even if search UI is currently being presented/dismissed.
@property (nonatomic, getter=isSearchVisible, readonly) BOOL searchVisible;

/// The configuration data source for this class.
@property (nonatomic, weak, readonly) id<PSPDFPresentationContext> presentationContext;

/// Internally used `PSPDFTextSearch` object. (is a copy of the `PSPDFTextSearch` class in document)
@property (nonatomic, readonly, nullable) PSPDFTextSearch *textSearch;

/// Current searchText.
@property (nonatomic, copy, readonly) NSString *searchText;

/// Currently loaded search results.
@property (nonatomic, copy, readonly) NSArray<PSPDFSearchResult *> *searchResults;

/// Current search status.
@property (nonatomic, readonly) PSPDFSearchStatus searchStatus;

/// The inline search manager delegate that notifies show/hide and when a search result is focussed.
@property (nonatomic, weak) id <PSPDFInlineSearchManagerDelegate> delegate;

/// The document to be searched.
/// Assigning a new document resets and hides the search bar.
@property (nonatomic, nullable) PSPDFDocument *document;

/// The maximum number of results that may be displayed.
/// Setting this too high may cause slowdown.
/// Defaults to 600.
@property (nonatomic) NSUInteger maximumNumberOfSearchResultsDisplayed;

/// Will include annotations that have a matching type into the search results. (contents will be searched).
/// Defaults to `PSPDFAnnotationTypeAll&~PSPDFAnnotationTypeLink`.
/// @note Requires the `PSPDFFeatureMaskAnnotationEditing` feature flag.
@property (nonatomic) PSPDFAnnotationType searchableAnnotationTypes;

/// Returns whether search UI is currently being presented.
@property (nonatomic, readonly, getter=isBeingPresented) BOOL beingPresented;

/// Returns whether search UI is currently being dismissed.
@property (nonatomic, readonly, getter=isBeingDismissed) BOOL beingDismissed;

/// Specifies the top padding of the search results label. Defaults to 10.f.
@property (nonatomic) CGFloat searchResultsLabelDistance;

@end

NS_ASSUME_NONNULL_END
