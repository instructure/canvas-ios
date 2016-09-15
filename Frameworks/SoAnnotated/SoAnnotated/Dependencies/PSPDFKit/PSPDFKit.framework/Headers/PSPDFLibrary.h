//
//  PSPDFLibrary.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument, PSPDFLibrary, PSPDFSearchResult, PSPDFTextParser;

/// The library version.
PSPDF_EXPORT const NSUInteger PSPDFLibraryVersion;

/// `PSPDFLibrary` uses `NSNotifications` to post status updates.
PSPDF_EXPORT NSString *const PSPDFLibraryWillStartIndexingDocumentNotification;
PSPDF_EXPORT NSString *const PSPDFLibraryDidFinishIndexingDocumentNotification;

/// The key in the `NSNotification` userInfo for the UID of the document.
PSPDF_EXPORT NSString * const PSPDFLibraryNotificationUIDKey;

/// The key in the `NSNotification` userInfo if the indexing operation was successful.
PSPDF_EXPORT NSString * const PSPDFLibraryNotificationSuccessKey;

typedef NS_ENUM(NSUInteger, PSPDFLibraryIndexStatus) {
    /// Not in library
    PSPDFLibraryIndexStatusUnknown,
    PSPDFLibraryIndexStatusQueued,
    PSPDFLibraryIndexStatusPartial,
    PSPDFLibraryIndexStatusPartialAndIndexing,
    PSPDFLibraryIndexStatusFinished
} PSPDF_ENUM_AVAILABLE;

/// `PSPDFLibrary` implements a sqlite-based full-text-search engine.
/// You can register documents to be indexed in the background and then search for keywords within that collection.
/// There can be multiple libraries, although usually one is enough for the common use case.
/// See https://pspdfkit.com/guides/ios/current/features/indexed-full-text-search/ for further documentation.
/// @note Requires the `PSPDFFeatureMaskIndexedFTS` feature flag.
PSPDF_CLASS_AVAILABLE @interface PSPDFLibrary : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// @name Initialization

/// Returns a library for this given path.
/// If no instance for this path exists yet, this method will create and return one. All subsequent calls
/// will return the same instance. Hence there will only be one instance per path.
/// This method will return `nil` for invalid paths.
+ (nullable instancetype)libraryWithPath:(NSString *)path error:(NSError **)error;

/// See `libraryWithPath:error:`. In addition it takes a `tokenizer` parameter, see `tokenizer`.
+ (nullable instancetype)libraryWithPath:(NSString *)path tokenizer:(nullable NSString *)tokenizer error:(NSError **)error;

/// @name Properties

/// Returns the default path of the library used in `PSPDFKit.sharedInstance.library`.
+ (NSString *)defaultLibraryPath;

/// Path to the current database.
@property (nonatomic, copy, readonly) NSString *path;

/// This property shows what tokenizer is used currently. You can set it in the initializers.
/// Defaults to nil, a PSPDFKit custom tokenizer that allows better CJK indexing.
/// This tokenizer also comes with a few drawbacks, like much more lax matching of words (Searching for "Dependency" will also return "Dependencies").
/// If that is a problem, we suggest using the 'UNICODE61' tokenizer. The UNICODE61 tokenizer allows searching inside text with diacritics. http://swwritings.com/post/2013-05-04-diacritics-and-fts
/// Sadly, Apple doesn't ship this tokenizer with their sqlite builds but there is a support article how to enable it: https://pspdfkit.com/guides/ios/current/memory-and-storage/how-to-enable-the-unicode61-tokenizer/
/// @warning Once the database is created, changing the `tokenizer` property will assert.
@property (nonatomic, nullable, copy, readonly) NSString *tokenizer;

/// Will save a reversed copy of the original page text. Defaults to YES.
/// @note If enabled, the sqlite cache will be about 2x bigger, but ends-with matches will be enabled.
@property (atomic) BOOL saveReversedPageText;

/// @name Library Operations

/// Option keys. Allows to limit the number of document results.
PSPDF_EXPORT NSString *const PSPDFLibraryMaximumSearchResultsTotalKey;
PSPDF_EXPORT NSString *const PSPDFLibraryMaximumSearchResultsPerDocumentKey;

/// Allows to limit the number of preview results.
PSPDF_EXPORT NSString *const PSPDFLibraryMaximumPreviewResultsTotalKey;
PSPDF_EXPORT NSString *const PSPDFLibraryMaximumPreviewResultsPerDocumentKey;

/// Set this to @YES to restrict search to exact word matches instead of beginsWith/endsWith checks.
/// @warning If the default tokenizer is used, this will impact performance. If you find it is too slow, consider using a different `tokenizer`. See https://pspdfkit.com/guides/ios/current/features/indexed-full-text-search/
PSPDF_EXPORT NSString *const PSPDFLibraryMatchExactWordsOnlyKey;

/// Set this to @YES to restrict search to exact phrase matches. This means that "Lorem ipsum dolor"
/// only matches that phrase and not something like "Lorem sit ipsum dolor".
/// @warning If the default tokenizer is used, this will impact performance. If you find it is too slow, consider using a different `tokenizer`. See https://pspdfkit.com/guides/ios/current/features/indexed-full-text-search/
PSPDF_EXPORT NSString *const PSPDFLibraryMatchExactPhrasesOnlyKey;

/// Customizes the range of the preview string. Defaults to 20/160.
PSPDF_EXPORT NSString *const PSPDFLibraryPreviewRangeKey;

/// See `documentUIDsMatchingString:options:completionHandler:previewTextHandler:`.
- (void)documentUIDsMatchingString:(NSString *)searchString options:(nullable NSDictionary<NSString *, id> *)options completionHandler:(void (^)(NSString *searchString, NSDictionary<NSString *, NSIndexSet *> *resultSet))completionHandler;

/// Query the database for a match of `searchString`. Only direct matches, begins-with and ends-with matches are supported.
/// Returns a dictionary of UID->`NSIndexSet` of page numbers in the `completionHandler`.
/// If you provide an optional `previewTextHandler`, a text preview for all search results will be
/// extracted from the matching documents and a dictionary of UID->`NSSet` of `PSPDFSearchResult`s will
/// be returned in the `previewTextHandler`.
/// @note `previewTextHandler` is optional.
/// @note Ends-with matches are only possible if `saveReversedPageText` has been YES while the document was indexed.
/// @note You can store additional metadata for an indexed document. To do so, simply enqueue documents
/// with a set `libraryMetadata` dictionary. You can then query the metadata information by using the
/// `-metadataForUID:` method.
/// @warning The completion handler might be called on a different thread.
- (void)documentUIDsMatchingString:(NSString *)searchString options:(nullable NSDictionary<NSString *, id> *)options completionHandler:(nullable void (^)(NSString *searchString, NSDictionary<NSString *, NSIndexSet *> *resultSet))completionHandler previewTextHandler:(nullable void (^)(NSString *searchString, NSDictionary<NSString *, NSSet<PSPDFSearchResult *> *> *resultSet))previewTextHandler;

/// @name Index Status

/// Returns indexing status. If status is `PSPDFLibraryIndexStatusPartialAndIndexing` progress will be set as well.
- (PSPDFLibraryIndexStatus)indexStatusForUID:(NSString *)UID withProgress:(nullable CGFloat *)outProgress;

/// Returns YES if library is currently indexing.
@property (nonatomic, getter=isIndexing, readonly) BOOL indexing;

/// Returns all queued and indexing UIDs.
@property (nonatomic, readonly) NSOrderedSet<NSString *> *queuedUIDs;

/// Returns the stored metadata for a previously enqueued document UID. If no metadata has been stored,
/// this method will return `nil`.
- (nullable NSDictionary *)metadataForUID:(NSString *)UID;

/// @name Queue Operations

/// Queue an array of `PSPDFDocument` objects for indexing.
/// @note Documents that are already queued or completely indexed will be ignored.
/// Potentially slow operation - can be called from any thread.
- (void)enqueueDocuments:(NSArray<PSPDFDocument *> *)documents;

/// Invalidates the search index for `UID`.
- (void)removeIndexForUID:(NSString *)UID;

/// Clear all database objects. Will clear ALL content in `path`.
- (void)clearAllIndexes;

/// Cancels all pending preview text operations.
/// @note The `previewTextHandler` of cancelled operations will not be called.
- (void)cancelAllPreviewTextOperations;

@end

/// This category allows you to encrypt the database file of your `PSPDFLibrary` instances.
/// To use this functionality, you need third-party software that implement the `sqlite3_key`
/// and `sqlite3_rekey` functions. An example for this is SQLCipher: https://www.zetetic.net/sqlcipher/
/// Information on the necessary configuration and setup can be found here:
/// https://www.zetetic.net/sqlcipher/sqlcipher-binaries-ios-and-osx/
/// You also need to enable encryption support. To do this, provide register an encryption provider by
/// calling `-[PSPDFKit databaseEncryptionProvider:]`.
@interface PSPDFLibrary (EncryptionSupport)

/// Returns an encrypted library for this given path. The `encryptionKeyProvider` is used to access
/// the encryption key when necessary. This allows us to not keep the encryption key around in memory.
/// Your implementation of encryption key provider should therefore always load the key from secure storage,
/// e.g. Apple's keychain. An encryption key provider must also be side-effect free in the sense
/// that it always returns the same encryption key on every call.
/// This method will return `nil` for invalid paths.
/// @note In contrast to `libraryWithPath:`, this method will not return the same instance when calling
/// it with an already used path.
/// @warning This method will return `nil` if the given encryption key provider was invalid.
+ (instancetype)encryptedLibraryWithPath:(NSString *)path encryptionKeyProvider:(nullable NSData *(^)(void))encryptionKeyProvider error:(NSError **)error;

/// See `encryptedLibraryWithpath:encryptionKeyProvider:error:`. Also takes a custom `tokenizer` - see `tokenizer` property.
+ (instancetype)encryptedLibraryWithPath:(NSString *)path encryptionKeyProvider:(nullable NSData *(^)(void))encryptionKeyProvider tokenizer:(nullable NSString *)tokenizer error:(NSError **)error;

/// Indicates if the library instance uses encryption.
@property (nonatomic, readonly, getter=isEncrypted) BOOL encrypted;

@end

NS_ASSUME_NONNULL_END
