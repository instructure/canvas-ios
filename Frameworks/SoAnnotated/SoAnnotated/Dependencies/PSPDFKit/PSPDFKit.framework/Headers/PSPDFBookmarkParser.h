//
//  PSPDFBookmarkParser.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFBookmark, PSPDFDocument;

/// Register to get notified by bookmark changes. Object is the `PSPDFBookmarkParser` object.
/// @warning Post only from the main thread!
PSPDF_EXPORT NSString *const PSPDFBookmarksChangedNotification;

/// Manages bookmarks for a `PSPDFDocument`.
///
/// There is no notion of "bookmarks" in a PDF.
/// (PDF "bookmarks" are entries in the outline (Table Of Contents); which are parsed in PSPDFKit by the `PSPDFOutlineParser.class`)
///
/// Bookmarks are saved in <APP>/Library/PrivateDocuments/<DocumentUID>/bookmark.plist
///
/// Bookmarks are ordered in the order they are created.
///
/// All calls to this class are thread safe.
PSPDF_CLASS_AVAILABLE @interface PSPDFBookmarkParser : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Designated initializer.
/// @note This class should not be created manually as it is managed by `PSPDFDocumentProvider`.
/// We only expose this initializer to add your own logic, if needed in a subclass.
/// Use our overrideClass:withClass: system to register your subclass.
- (instancetype)initWithDocument:(PSPDFDocument *)document NS_DESIGNATED_INITIALIZER;

/// Contains bookmarks (`PSPDFBookmark`) for the document. Access is thread safe.
@property (nonatomic, copy) NSArray<PSPDFBookmark *> *bookmarks;

/// Associated document.
@property (nonatomic, weak, readonly) PSPDFDocument *document;

/// Adds a bookmark
/// @note Will return NO if the bookmark's page is invalid or the bookmark already exists.
/// If you manually add bookmarks, you might need to call createToolbarAnimated to update.
- (BOOL)addBookmark:(PSPDFBookmark *)bookmark;

/// Adds a bookmark for `page`.
/// @note Convenience method. Will return NO if page is invalid or bookmark doesn't exist.
/// Will set the bookmark's name according to the page label.
/// If you manually add bookmarks, you might need to call createToolbarAnimated to update.
- (BOOL)addBookmarkForPage:(NSUInteger)page;

/// Removes a bookmark for `page`.
- (BOOL)removeBookmarkForPage:(NSUInteger)page;

/// Clears all bookmarks. Also deletes file.
- (BOOL)clearAllBookmarksWithError:(NSError **)error;

/// Returns the bookmark if page has a bookmark.
- (nullable PSPDFBookmark *)bookmarkForPage:(NSUInteger)page;

@end


@interface PSPDFBookmarkParser (SubclassingHooks)

/// Defaults to cachePath/bookmarks.plist
@property (nonatomic, readonly) NSString *bookmarkPath;

/// Read bookmarks out of the plist in bookmarkPath.
- (NSArray<PSPDFBookmark *> *)loadBookmarksWithError:(NSError **)error;

/// Saves the bookmark into a plist file at bookmarkPath.
/// @note Saving is done async.
- (BOOL)saveBookmarksWithError:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
