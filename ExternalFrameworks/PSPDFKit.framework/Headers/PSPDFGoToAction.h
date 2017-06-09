//
//  PSPDFGoToAction.h
//  PSPDFKit
//
//  Copyright © 2013-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAction.h"
#import "PSPDFBookmark.h"
#import "PSPDFBookmarkManager.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocumentProvider;

/// Defines the action of going to a specific location within the PDF document.
PSPDF_CLASS_AVAILABLE @interface PSPDFGoToAction : PSPDFAction

/// Initializer with the page index.
- (instancetype)initWithPageIndex:(NSUInteger)pageIndex;

/// Set to `NSNotFound` if not valid.
@property (nonatomic, readonly) NSUInteger pageIndex;

@end

@interface PSPDFBookmark (GoToAction)

/// Initialize with page. Convenience initialization that will create a `PSPDFGoToAction`.
- (instancetype)initWithPageIndex:(NSUInteger)pageIndex;

/// Convenience shortcut for self.action.pageIndex (if action is of type `PSPDFGoToAction`)
/// Page is set to `NSNotFound` if action is nil or a different type.
@property (nonatomic, readonly) NSUInteger pageIndex;

@end

@interface PSPDFBookmarkManager (GoToAction)

/// Adds a bookmark for `page`.
/// @note Convenience method. Will return NO if page is invalid or bookmark doesn't exist.
/// Will set the bookmark's name according to the page label.
- (void)addBookmarkForPageAtIndex:(NSUInteger)pageIndex;

/// Removes a bookmark for `page`.
- (void)removeBookmarkForPageAtIndex:(NSUInteger)pageIndex;

/// Returns the bookmark if page has a bookmark.
- (nullable PSPDFBookmark *)bookmarkForPageAtIndex:(NSUInteger)pageIndex;

@end

NS_ASSUME_NONNULL_END
