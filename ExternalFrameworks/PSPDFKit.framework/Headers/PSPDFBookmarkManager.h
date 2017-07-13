//
//  PSPDFBookmarkManager.h
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

@class PSPDFBookmark, PSPDFDocument;
@protocol PSPDFBookmarkProvider;

/// The sort order is currently used for bookmarks.
typedef NS_ENUM(NSUInteger, PSPDFBookmarkManagerSortOrder) {
    /**
     Custom sort order, based on creation, but reorderable. This is the only
     sort order that can be changed by calling `moveBookmarkAtIndex:toIndex:`.
     */
    PSPDFBookmarkManagerSortOrderCustom,

    /// Sort based on pages.
    PSPDFBookmarkManagerSortOrderPageBased
} PSPDF_ENUM_AVAILABLE;

/**
 Register to get notified when the bookmarks managed by the bookmark manager posting
 this notification change.

 A change is defined as adding, removing, or replacing a bookmark or changing its sort order.

 This notification is guaranteed to be posted on the main thread.
 */
PSPDF_EXPORT NSNotificationName const PSPDFBookmarksChangedNotification;

/**
 The `PSPDFBookmarkManager` manages bookmarks for a given `PSPDFDocument`.

 You should not initialize a bookmark manager yourself but instead access it through
 the document's `bookmarkManager` property.

 # Bookmarks and PDF files

 The concept of bookmarks does not exist in a PDF document. Therefore all the bookmarks
 you add will be stored inside the PDF but are only read by PSPDFKit and Apple Preview.
 If you want to support other formats, you need to create your own bookmark provider
 and store them yourself.

 # Subclassing

 You should not subclass `PSPDFBookmarkManager`. Instead attach a custom bookmark
 provider to achieve your desired behavior.

 # Thread Safety

 `PSPDFBookmarkManager` is thread safe and can be accessed from any thread. To ensure
 multiple operations are executed as one serial block without other threads interfering,
 wrap you operations in `performBlock:` or `performBlockAndWait:` whenever you need
 to do complex operations.

 However, if you need to do something that can be achieved by calling a single method on
 this class (e.g. adding a bookmark or removing a known bookmark), call the appropriate
 method directly as it is more performant than wrapping calls in the above mentioned
 block calls.
 */
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFBookmarkManager : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/**
 Creates a new instance of the bookmark manager.

 This is the designated initializer.

 @note You should not create an instance of this class yourself. Instead access
       a document's bookmark manager through `-[PSPDFDocument bookmarkManager]`.

 @param document The document this bookmark manager should be attached to.

 @return A newly initialized instance of the receiver.
 */
- (nullable instancetype)initWithDocument:(PSPDFDocument *)document NS_DESIGNATED_INITIALIZER;

/// @name Accessing Bookmarks

/**
 Contains the list of bookmarks that are currently owned by the receiver.

 @note The sort order of these bookmarks is undefined. If you want to retrieve bookmarks
       in a sorted order, use `bookmarksWithSortOrder:`.
 */
@property (nonatomic, copy, readonly) NSArray<PSPDFBookmark *> *bookmarks;

/**
 Returns the list of bookmarks sorted in the specified sort order.

 @see bookmarks

 @param sortOrder The sort order to use for the returned array.

 @return An array containing the bookmarks in the order of `sortOrder`.
 */
- (NSArray<PSPDFBookmark *> *)bookmarksWithSortOrder:(PSPDFBookmarkManagerSortOrder)sortOrder;

/// @name Modifying Bookmarks

/**
 Adds a bookmark to the bookmark manager or updates an existing.

 @note To persist an update to the bookmarks you need to save the associated document.

 @param bookmark The bookmark you want to add.
 */
- (void)addBookmark:(PSPDFBookmark *)bookmark;

/**
 Removes a bookmark from the bookmark manager.

 @note To persist an update to the bookmarks you need to save the associated document.

 @param bookmark The bookmark you want to remove.
 */
- (void)removeBookmark:(PSPDFBookmark *)bookmark;

/**
 Moves the bookmark at a given source index to the given destination index and
 adjusts the index of the bookmarks inbetween.

 @note This method only has an effect on the order of bookmarks that you retrieve
       by calling `bookmarksWithSortOrder:` using the `PSPDFBookmarkManagerSortOrderCustom`
       sort order. This method does not change the `bookmarks` array or the sorting
       of any other sort order.

 @param sourceIndex      The current index of the bookmark.
 @param destinationIndex The index the bookmark should have after this operation.
 */
- (void)moveBookmarkAtIndex:(NSUInteger)sourceIndex toIndex:(NSUInteger)destinationIndex;

/// @name Combining Multiple Operations

/**
 Schedules a block for asynchronous execution as a single serial operation on the
 bookmark manager and immediately returns.

 You can use this method if you need to make multiple operations on the same data
 set as a single operation. If, for example, you want to iterate over the bookmarks
 array, look for a specific bookmark and then remove it from the list, wrap your
 code in this method to ensure the underlying data does not change while you perform
 your operations.

 @note Chaining calls to this method is not allowed and will throw an exception.

 @warning This still does not guarantee an atomic operation! If one operation does
 fail for some reason, this method does not perform a roll back to the
 state at the beginning of this block!

 @see performBlockAndWait:

 @param block The block you want to perform.
 */
- (void)performBlock:(void (^)(void))block;

/**
 Schedules a block for synchronous execution as a single serial operation on the
 bookmark manager and waits until the block returns.

 You can use this method if you need to make multiple operations on the same data
 set as a single operation. If, for example, you want to iterate over the bookmarks
 array, look for a specific bookmark and then remove it from the list, wrap your
 code in this method to ensure the underlying data does not change while you perform
 your operations.

 @note Chaining calls to this method is not allowed and will throw an exception.

 @warning This still does not guarantee an atomic operation! If one operation does
 fail for some reason, this method does not perform a roll back to the
 state at the beginning of this block!

 @see performBlockAndWait:

 @param block The block you want to perform.
 */
- (void)performBlockAndWait:(void (^)(void))block;

/// @name Customizing Bookmark Providers

/**
 Contains the list of bookmark providers that is used to set and get bookmark data.

 Calls to the bookmark providers are made in the order of this array, first to last.
 */
@property (nonatomic, copy) NSArray<id<PSPDFBookmarkProvider>> *provider;

@end

NS_ASSUME_NONNULL_END
