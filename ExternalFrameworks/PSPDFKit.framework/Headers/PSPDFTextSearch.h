//
//  PSPDFTextSearch.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnnotation.h"
#import "PSPDFSearchResult.h"

@class PSPDFDocument, PSPDFTextSearch;

NS_ASSUME_NONNULL_BEGIN

/// Search status delegate. All delegates are guaranteed to be called within the main thread.
PSPDF_AVAILABLE_DECL @protocol PSPDFTextSearchDelegate <NSObject>

@optional

/// Called when search is started.
- (void)willStartSearch:(PSPDFTextSearch *)textSearch term:(NSString *)searchTerm isFullSearch:(BOOL)isFullSearch;

/// Search was updated, a new page has been scanned.
/// Consider `page` a hint. There might be situations where this is called with a larger set of search results. page in this case is set to `NSNotFound`.
- (void)didUpdateSearch:(PSPDFTextSearch *)textSearch term:(NSString *)searchTerm newSearchResults:(NSArray<PSPDFSearchResult *> *)searchResults page:(NSUInteger)page;

/// Search has finished.
- (void)didFinishSearch:(PSPDFTextSearch *)textSearch term:(NSString *)searchTerm searchResults:(NSArray<PSPDFSearchResult *> *)searchResults isFullSearch:(BOOL)isFullSearch pageTextFound:(BOOL)pageTextFound;

/// Search has been cancelled.
- (void)didCancelSearch:(PSPDFTextSearch *)textSearch term:(NSString *)searchTerm isFullSearch:(BOOL)isFullSearch;

@end

/// Manages search operations for a specific document.
/// You can copy this class to be able to use it on your custom class. (and set a different delegate)
/// Copying will preserve all settings except the delegate.
PSPDF_CLASS_AVAILABLE @interface PSPDFTextSearch : NSObject <NSCopying>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Initialize with the document.
- (instancetype)initWithDocument:(PSPDFDocument *)document NS_DESIGNATED_INITIALIZER;

/// Searches for text occurrence.
/// If document was not yet parsed, it will be now. Searches entire document.
/// Will search the whole document and cancel any previous search requests.
- (void)searchForString:(NSString *)searchTerm;

/// Searches for text on the specified page ranges. If ranges is nil, will search entire document.
/// If rangesOnly is set to NO, ranges will be searched first, then the rest of the document.
/// @note See `psc_indexSet` to convert `NSNumber-NSArrays` to an `NSIndexSet`.
- (void)searchForString:(NSString *)searchTerm inRanges:(nullable NSIndexSet *)ranges rangesOnly:(BOOL)rangesOnly cancelOperations:(BOOL)cancelOperations;

/// Cancels all operations. Returns immediately.
- (void)cancelAllOperations;

/// Cancels all operations. Blocks current thread until all operations are processed.
/// @note Use `cancelAllOperations` if you don't with to wait until all operations are processed.
- (void)cancelAllOperationsAndWait;

/// Defaults to `NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch|NSWidthInsensitiveSearch|NSRegularExpressionSearch`.
/// With `NSDiacriticInsensitiveSearch`, e.g. an ö character will be treated like an o.
/// See NSString comparison documentation for details.
/// @note PSPDF has extensions that will allow a combination of `NSRegularExpressionSearch` and `NSDiacriticInsensitiveSearch`.
/// If `NSRegularExpressionSearch` is enabled, hyphenations and newlines between the body text will be ignored (which is good, better results)
@property (nonatomic) NSStringCompareOptions compareOptions;

/// Customizes the range of the preview string. Defaults to 20/160.
@property (nonatomic) NSRange previewRange;

/// Will include annotations that have a matching type into the search results. (contents will be searched).
/// @note Requires the `PSPDFFeatureMaskAnnotationEditing` feature flag.
@property (nonatomic) PSPDFAnnotationType searchableAnnotationTypes;

/// We have to limit the number of search results to something reasonable. Defaults to 600.
@property (nonatomic) NSUInteger maximumNumberOfSearchResults;

/// The document that is searched.
@property (nonatomic, weak, readonly) PSPDFDocument *document;

/// The search delegate to be informed when search starts/updates/finishes.
@property (nonatomic, weak) id<PSPDFTextSearchDelegate> delegate;

@end

@interface PSPDFTextSearch (SubclassingHooks)

/// Exposed internal search queue.
@property (nonatomic, readonly) NSOperationQueue *searchQueue;

@end

NS_ASSUME_NONNULL_END
