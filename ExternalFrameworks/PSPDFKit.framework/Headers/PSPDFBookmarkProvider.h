//
//  PSPDFBookmarkProvider.h
//  PSPDFKit
//
//  Copyright © 2016-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFBookmark;

/**
 A Bookmark Provider is used to store and read bookmarks from a data source.

 If you need to store bookmarks in a file format other than what PSPDFKit supports
 by default, you can create your own bookmark provider and attach it to a document's
 bookmark manager.

 @see PSPDFBookmarkManager
 @see PSPDFBookmarksChangedNotification for change notifications.
 */
PSPDF_AVAILABLE_DECL @protocol PSPDFBookmarkProvider<NSObject>

/**
 Contains all bookmarks that are currently owned by the bookmark provider.
 */
@property (nonatomic, readonly) NSArray<PSPDFBookmark *> *bookmarks;

/**
 Adds a bookmark to the bookmark provider if the given bookmark should be owned
 by the receiver.

 The receiver should decide if it wants to manage this bookmark. If it does, it
 shoud add the bookmark to its list and return `YES`. If it returns `NO` the next
 bookmark provider in the list is asked.
 
 @note You will receive calls to `addBookmark:` with updated bookmarks that already
       exist in a provider in an outdated version. You can determine if you are
       already the owner of a bookmark by comparing its `identifier` property with
       the ones from your list of bookmarks.

 @param bookmark The bookmark that should be added to the receiver.

 @return `YES` if the receiver consums the bookmark, `NO` otherwise.
 */
- (BOOL)addBookmark:(PSPDFBookmark *)bookmark;

/**
 Removes a bookmark from the bookmark provider if the given bookmark is owned
 by the receiver.

 The receiver should check if the given bookmark is owned by itself. If this is
 the case, it should remove the bookmark from the list and return `YES`. If this
 method returns `NO` the next bookmark provider in the list is asked.

 @param bookmark The bookmark that should be removed from the receiver.

 @return `YES` if the receiver removed the bookmark, `NO` otherwise.
 */
- (BOOL)removeBookmark:(PSPDFBookmark *)bookmark;

/**
 Tells the bookmark provider to persist the bookmarks it is managing.

 Most likely this method is called because the associated document is about to be
 saved.
 */
- (void)save;

@end

NS_ASSUME_NONNULL_END
