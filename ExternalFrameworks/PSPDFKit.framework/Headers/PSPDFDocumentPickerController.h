//
//  PSPDFDocumentPickerController.h
//  PSPDFCatalog
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFOverridable.h"
#import "PSPDFStatefulTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocumentPickerController, PSPDFDocument, PSPDFLibrary, PSPDFDocumentPickerIndexStatusCell;

/// Document selector delegate.
PSPDF_AVAILABLE_DECL @protocol PSPDFDocumentPickerControllerDelegate <PSPDFOverridable>

/// A cell has been selected.
/// `pageIndex` is usually `NSNotFound`, unless a search result from the FTS engine was tapped.
- (void)documentPickerController:(PSPDFDocumentPickerController *)controller didSelectDocument:(PSPDFDocument *)document page:(NSUInteger)pageIndex searchString:(NSString *)searchString;

@optional

/// When we start/end showing the search UI.
- (void)documentPickerControllerWillBeginSearch:(PSPDFDocumentPickerController *)controller;
- (void)documentPickerControllerDidBeginSearch:(PSPDFDocumentPickerController *)controller;
- (void)documentPickerControllerWillEndSearch:(PSPDFDocumentPickerController *)controller;
- (void)documentPickerControllerDidEndSearch:(PSPDFDocumentPickerController *)controller;

@end

/// Shows all documents available in the Sample directory.
/// By default this will enqueue all documents into the default `PSPDFLibrary` for FTS.
PSPDF_CLASS_AVAILABLE @interface PSPDFDocumentPickerController : PSPDFStatefulTableViewController <UISearchDisplayDelegate, UISearchBarDelegate>

/// Returns an array of `PSPDFDocument's` found in the "directoryName" directory.
+ (NSArray<PSPDFDocument *> *)documentsFromDirectory:(nullable NSString *)directoryName includeSubdirectories:(BOOL)includeSubdirectories;

/// Designated initializer.
/// `library` is optional but required if you want to use `fullTextSearchEnabled`.
/// @note Providing nil or an empty string for directory parameter searches the root documents directory.
- (instancetype)initWithDirectory:(nullable NSString *)directory includeSubdirectories:(BOOL)includeSubdirectories library:(nullable PSPDFLibrary *)library;

/// Initialize with a number of documents.
- (instancetype)initWithDocuments:(NSArray<PSPDFDocument *> *)documents library:(nullable PSPDFLibrary *)library NS_DESIGNATED_INITIALIZER;

/// Manually trigger library enqueueing. We else to that when the controller is made visible.
- (void)enqueueDocumentsIfRequired;

/// Delegate to get the `didSelectDocument:` event.
@property (nonatomic, weak) IBOutlet id<PSPDFDocumentPickerControllerDelegate> delegate;

/// All `PSPDFDocument` objects.
@property (atomic, copy, readonly) NSArray<PSPDFDocument *> *documents;

/// Displayed path. Might be nil, if initialized with a number of documents.
@property (nonatomic, copy, readonly, nullable) NSString *directory;

/// Getting the PDF document title can be slow. If set to NO, the file name is used instead. Defaults to NO.
@property (nonatomic) BOOL useDocumentTitles;

/// Enables section indexes. Defaults to YES.
@property (nonatomic) BOOL showSectionIndexes;

/// If disabled, documents will only be displayed once you start searching. Defaults to YES.
@property (nonatomic) BOOL alwaysShowDocuments;

/// Enable to perform full-text search on all documents. Defaults to YES
@property (nonatomic) BOOL fullTextSearchEnabled;

/// If set to YES, will require an exact word match instead of an begin/end partial match. Defaults to NO.
/// @note This will forward the option via `PSPDFLibraryMatchExactWordsOnlyKey` to the `PSPDFLibrary`.
@property (nonatomic) BOOL fullTextSearchExactWordMatch;

/// Property is enabled if a FTS-Search is currently queued/running. KVO observable.
@property (nonatomic, readonly) BOOL isSearchingIndex;

/// Will show the actual pages and text preview instead of just the documents.
/// Only valid if `fullTextSearchEnabled` is enabled. Defaults to YES.
@property (nonatomic) BOOL showSearchPageResults;

/// Will show a preview text that presents the search term within its context.
/// Only valid if `fullTextSearchEnabled` is enabled. Defaults to YES.
@property (nonatomic) BOOL showSearchPreviewText;

/// Defaults to 600. A too high number will be slow.
/// Only valid if `fullTextSearchEnabled` is enabled.
@property (nonatomic) NSUInteger maximumNumberOfSearchResultsDisplayed;

/// Number of results found per document. Defaults to 10.
/// Only valid if `fullTextSearchEnabled` is enabled.
@property (nonatomic) NSUInteger maximumNumberOfSearchResultsPerDocument;

/// Maximum number of lines for search preview text. Defaults to 2.
/// The actual number of lines will be smaller if there's not enough preview text available.
/// Only valid if `fullTextSearchEnabled` is enabled.
@property (nonatomic) NSUInteger maximumNumberOfSearchPreviewLines;

/// The attached library, if any.
@property (nonatomic, readonly, nullable) PSPDFLibrary *library;

@end

/// Uses a `UISearchController` internally.
@interface PSPDFDocumentPickerController (SubclassingHooks)

- (void)updateStatusCell:(PSPDFDocumentPickerIndexStatusCell *)cell;

@end

NS_ASSUME_NONNULL_END
