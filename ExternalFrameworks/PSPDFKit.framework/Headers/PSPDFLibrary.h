//
//  PSPDFLibrary.h
//  PSPDFKit
//
//  Copyright © 2013-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument, PSPDFLibrary, PSPDFLibraryPreviewResult, PSPDFTextParser;

/// The library version.
PSPDF_EXPORT const NSUInteger PSPDFLibraryVersion;

/// `PSPDFLibrary` uses `NSNotifications` to post status updates.
PSPDF_EXPORT NSNotificationName const PSPDFLibraryWillStartIndexingDocumentNotification;
PSPDF_EXPORT NSNotificationName const PSPDFLibraryDidFinishIndexingDocumentNotification;

/// Sent when a document is removed from the library.
PSPDF_EXPORT NSNotificationName const PSPDFLibraryDidRemoveDocumentNotification;

/// Sent when all indexes are cleared as a result of `-[PSPDFLibrary clearAllIndexes]`.
PSPDF_EXPORT NSNotificationName const PSPDFLibraryDidClearIndexesNotification;

/// The key in the `NSNotification` userInfo for the UID of the document.
PSPDF_EXPORT NSString *const PSPDFLibraryNotificationUIDKey;

/// The key in the `NSNotification` userInfo if the indexing operation was successful.
PSPDF_EXPORT NSString *const PSPDFLibraryNotificationSuccessKey;

/// The name of the exception thrown when an invalid operation occurs.
PSPDF_EXPORT NSExceptionName const PSPDFLibraryInvalidOperationException;

/// Represents the status of a document in the library.
typedef NS_ENUM(NSUInteger, PSPDFLibraryIndexStatus) {
    /// Not in library.
    PSPDFLibraryIndexStatusUnknown,
    /// The document is queued for indexing.
    PSPDFLibraryIndexStatusQueued,
    /// The document has been partially indexed.
    PSPDFLibraryIndexStatusPartial,
    /// The document has been partially indexed, and is currently being indexed.
    PSPDFLibraryIndexStatusPartialAndIndexing,
    /// The document is indexed.
    PSPDFLibraryIndexStatusFinished,
} PSPDF_ENUM_AVAILABLE;

/// Specifies the version of FTS the PSPDFLibrary should use.
typedef NS_ENUM(NSUInteger, PSPDFLibraryFTSVersion) {
    /// The library will use the highest version of FTS available
    PSPDFLibraryFTSVersionHighestAvailable,
    /// The library will use FTS 4
    PSPDFLibraryFTSVersion4,
    /// The library will use FTS 5
    PSPDFLibraryFTSVersion5
} PSPDF_ENUM_AVAILABLE;

/// Specifies the priority indexing takes in task scheduling.
typedef NS_ENUM(NSUInteger, PSPDFLibraryIndexingPriority) {
    /// Specifies that the indexing must be done on a background priority queue.
    PSPDFLibraryIndexingPriorityBackground,
    /// Specifies that indexing must be done on a low priority queue.
    PSPDFLibraryIndexingPriorityLow,
    /// Specifies that indexing must be done on a high priority queue.
    PSPDFLibraryIndexingPriorityHigh
} PSPDF_ENUM_AVAILABLE;

/// Specifies what data is to be indexed to Spotlight.
typedef NS_ENUM(NSInteger, PSPDFLibrarySpotlightIndexingType) {
    /// Spotlight is completely disabled.
    PSPDFLibrarySpotlightIndexingDisabled = 0,
    /// Only document metadata will be indexed in spotlight.
    PSPDFLibrarySpotlightIndexingEnabled = 1,
    /// The entire document will be indexed, including its text.
    PSPDFLibrarySpotlightIndexingEnabledWithFullText = 2
} PSPDF_ENUM_AVAILABLE;

@protocol PSPDFLibraryDataSource;

/**
 `PSPDFLibrary` implements a sqlite-based full-text-search engine.
 You set a data source that provides the documents to be indexed by the library, and then call -updateIndex, which performs it works synchronously.
 Then, you can search for keywords within that collection. Typically, you use a `PSPDFLibraryFileSystemDataSource`.
 There can be multiple libraries, although usually one is enough for the common use case.
 Furthermore, when using multiple libraries with spotlight indexing enabled could lead to duplicates in users' spotlight results.
 See https://pspdfkit.com/guides/ios/current/features/indexed-full-text-search/ for further documentation.
 @note Requires the `PSPDFFeatureMaskIndexedFTS` feature flag.
*/
PSPDF_CLASS_AVAILABLE @interface PSPDFLibrary : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// @name Initialization

/**
 If no library for the given path exists yet, this method will create and return one. All subsequent calls
 will return the same instance. Hence there will only be one instance per path.
 This method will return nil for invalid paths.

 @param path The path for which the library is to be retrieved or created if it does not exist already.
 @param error A pointer to an error that will be set if the library could not be retrieved or created
 @return A library for the specified path

 @note If a library is created, it will be with the default tokenizer and the highest version of FTS available.
 */
+ (nullable instancetype)libraryWithPath:(NSString *)path error:(NSError **)error;

/**
 If no library for the given path exists yet, this method will create and return one. All subsequent calls
 will return the same instance. Hence there will only be one instance per path.
 This method will return nil for invalid paths.

 @param path The path for which the library is to be retrieved or created if it does not exist already.
 @param tokenizer See `PSPDFLibrary.tokenizer`
 @param error A pointer to an error that will be set if the library could not be retrieved or created.
 @return A library for the specified path.
 */
+ (nullable instancetype)libraryWithPath:(NSString *)path tokenizer:(nullable NSString *)tokenizer error:(NSError **)error;

/**
 If no library for the given path exists yet, this method will create and return one. All subsequent calls
 will return the same instance. Hence there will only be one instance per path.
 This method will return nil for invalid paths.

 @param path The path for which the library is to be retrieved or created if it does not exist already.
 @param tokenizer See `PSPDFLibrary.tokenizer`
 @param ftsVersion The version of FTS this library is to use. If the specified version is unavailable, the library will not be created.
 @param error A pointer to an error that will be set if the library could not be retrieved or created.
 @return A library for the specified path.
 */
+ (nullable instancetype)libraryWithPath:(NSString *)path ftsVersion:(PSPDFLibraryFTSVersion)ftsVersion tokenizer:(nullable NSString *)tokenizer error:(NSError **)error;

/**
 If no library for the given path exists yet, this method will create and return one. All subsequent calls
 will return the same instance. Hence there will only be one instance per path.
 This method will return nil for invalid paths.

 @param path The path for which the library is to be retrieved or created if it does not exist already.
 @param priority The priority of the internal queue to be used for indexing.
 @param ftsVersion The version of FTS this library is to use. If the specified version is unavailable, the library will not be created.
 @param tokenizer See `PSPDFLibrary.tokenizer`
 @param error A pointer to an error that will be set if the library could not be retrieved or created.
 @return A library for the specified path.
 */
+ (nullable instancetype)libraryWithPath:(NSString *)path indexingPriority:(PSPDFLibraryIndexingPriority)priority ftsVersion:(PSPDFLibraryFTSVersion)ftsVersion tokenizer:(nullable NSString *)tokenizer error:(NSError **)error;

/// @name Properties

/// Returns the default path of the library used in `PSPDFKit.sharedInstance.library`.
+ (NSString *)defaultLibraryPath;

/// Path to the current database.
@property (nonatomic, copy, readonly) NSString *path;

/**
 Specifies whether the documents should also be indexed to Spotlight.
 If Spotlight indexing is not supported on the device, that is, `+[CSSearchableIndex isIndexingAvailable]` returns NO, then this property is ignored.
 Defaults to `PSPDFLibrarySpotlightIndexingTypeDisabled`.
 */
@property (atomic) PSPDFLibrarySpotlightIndexingType spotlightIndexingType;

/**
 Specifies whether the contents of annotations in documents added to the library should be indexed by the library.
 Defaults to `YES`.

 @note Changing this property does not affect already indexed documents.
 */
@property (atomic) BOOL shouldIndexAnnotations;

/**
 This property shows what tokenizer is used currently. You can set it in the initializers.
 Defaults to nil, a PSPDFKit custom tokenizer that allows better CJK indexing.
 This tokenizer also comes with a few drawbacks, like much more lax matching of words (Searching for "Dependency" will also return "Dependencies").
 If that is a problem, we suggest using the 'UNICODE61' tokenizer. The UNICODE61 tokenizer allows searching inside text with diacritics. http://swwritings.com/post/2013-05-04-diacritics-and-fts
 Sadly, Apple doesn't ship this tokenizer with their sqlite builds but there is a support article how to enable it: https://pspdfkit.com/guides/ios/current/memory-and-storage/how-to-enable-the-unicode61-tokenizer/

 @warning Once the database is created, changing the `tokenizer` property will assert.
*/
@property (nonatomic, nullable, copy, readonly) NSString *tokenizer;

/**
 Will save a reversed copy of the original page text. Defaults to YES.
 @note If enabled, the sqlite cache will be about 2x bigger, but ends-with matches will be enabled.
 @note This doesn't change indexes that already exist.
 */
@property (atomic) BOOL saveReversedPageText;

/// Suspends the operations queues.
@property (nonatomic) BOOL suspended;

/// @name Library Operations

/// Option keys. Allows to limit the number of document results.
PSPDF_EXPORT NSString *const PSPDFLibraryMaximumSearchResultsTotalKey;
PSPDF_EXPORT NSString *const PSPDFLibraryMaximumSearchResultsPerDocumentKey;

/// Allows to limit the number of preview results.
PSPDF_EXPORT NSString *const PSPDFLibraryMaximumPreviewResultsTotalKey;
PSPDF_EXPORT NSString *const PSPDFLibraryMaximumPreviewResultsPerDocumentKey;

/**
 Set this to @YES to restrict search to exact word matches instead of beginsWith/endsWith checks.
 @warning If the default tokenizer is used, this will impact performance. If you find it is too slow, consider using a different `tokenizer`. See https://pspdfkit.com/guides/ios/current/features/indexed-full-text-search/
 */
PSPDF_EXPORT NSString *const PSPDFLibraryMatchExactWordsOnlyKey;

/**
 Set this to @YES to restrict search to exact phrase matches. This means that "Lorem ipsum dolor"
 only matches that phrase and not something like "Lorem sit ipsum dolor".
 @warning If the default tokenizer is used, this will impact performance. If you find it is too slow, consider using a different `tokenizer`. See https://pspdfkit.com/guides/ios/current/features/indexed-full-text-search/
 */
PSPDF_EXPORT NSString *const PSPDFLibraryMatchExactPhrasesOnlyKey;

/**
 Set this to @YES to exclude annotations from the search.
 By default, indexed annotations will be searched.
 */
PSPDF_EXPORT NSString *const PSPDFLibraryExcludeAnnotationsKey;

/**
 Set this to @YES to include document text from the search.
 By default, indexed document text will be searched.
 */
PSPDF_EXPORT NSString *const PSPDFLibraryExcludeDocumentTextKey;

/// Customizes the range of the preview string. Defaults to 20/160.
PSPDF_EXPORT NSString *const PSPDFLibraryPreviewRangeKey;

/// See `documentUIDsMatchingString:options:completionHandler:previewTextHandler:`.
- (void)documentUIDsMatchingString:(NSString *)searchString options:(nullable NSDictionary<NSString *, id> *)options completionHandler:(void (^)(NSString *searchString, NSDictionary<NSString *, NSIndexSet *> *resultSet))completionHandler;

/**
 Query the database for a match of `searchString`. Only direct matches, begins-with and ends-with matches are supported.
 Returns in the `completionHandler`.
 If you provide an optional `previewTextHandler`, a text preview for all search results will be
 extracted from the matching documents and a dictionary of UID->`NSSet` of `PSPDFSearchResult`s will
 be returned in the `previewTextHandler`.

 By default the number of search and preview results is limited to 500 to keep maximum search times reasonable. Use `options` to modify both limits.

 @param searchString The string to search for in the FTS database.
 @param options The options for the search.
 @param completionHandler The block to be executed on completion of the search. It's arguments are the input search string and a dictionary of UID->`NSIndexSet` of matching page numbers.
 @param previewTextHandler The block to execute with a text preview argument for all the search results. A dictionary of UID -> `NSSet<PSPDFSearchResult *>` objects will be passed in as the argument.

 @note `previewTextHandler` is optional.
 @note Ends-with matches are only possible if `saveReversedPageText` has been YES while the document was indexed.
 @note You can store additional metadata for an indexed document. To do so, simply enqueue documents
 with a set `libraryMetadata` dictionary. You can then query the metadata information by using the
 `-metadataForUID:` method.

 @warning The completion handler might be called on a different thread.
 */
- (void)documentUIDsMatchingString:(NSString *)searchString options:(nullable NSDictionary<NSString *, id> *)options completionHandler:(nullable void (^)(NSString *searchString, NSDictionary<NSString *, NSIndexSet *> *resultSet))completionHandler previewTextHandler:(nullable void (^)(NSString *searchString, NSDictionary<NSString *, NSSet<PSPDFLibraryPreviewResult *> *> *resultSet))previewTextHandler;

/// @name Index Status

/**
 Checks the indexing status of the document. If status is `PSPDFLibraryIndexStatusPartialAndIndexing` progress will be set as well.

 @param UID The UID of the document whose index status is to be retrieved.
 @param outProgress A pointer to a CGFloat that, on return, will point to the current indexing progress if the document is currently being indexed.
 @return The current indexing status of the document with the specified UID.
 */
- (PSPDFLibraryIndexStatus)indexStatusForUID:(NSString *)UID withProgress:(nullable CGFloat *)outProgress;

/// Returns YES if library is currently indexing.
@property (nonatomic, getter=isIndexing, readonly) BOOL indexing;

/// Returns all queued and indexing UIDs.
@property (nonatomic, readonly) NSOrderedSet<NSString *> *queuedUIDs;

/// Returns all the indexed UIDs, or nil if we were unable to fetch the data.
@property (nonatomic, readonly, nullable) NSOrderedSet<NSString *> *indexedUIDs;

/// Specifies the number of indexed UIDs, or -1 if it was unable to be retrieved.
@property (nonatomic, readonly) NSInteger indexedUIDCount;

/**
 Retrieves a document with the specified UID from the data source, if any.
 Using this method is preferred to directly interacting with the data source's PSPDFLibraryDataSource methods.

 @param UID The UID of the document to be fetched.
 @return The document for the specified UID, if it exists, else nil.

 @warning This method might be slow, as it depends on the data source's ability to provide the document.
 */
- (nullable PSPDFDocument *)indexedDocumentWithUID:(NSString *)UID;

/**
 Returns the stored metadata for a previously enqueued document UID. If no metadata has been stored,
 this method will return `nil`.
 */
- (nullable NSDictionary *)metadataForUID:(NSString *)UID;

/// @name Indexing Operations

/// The library's data source. Note that this object will be retained
@property (atomic, strong, nullable) id<PSPDFLibraryDataSource> dataSource;

/**
 Updates the index based on information provided by the data source. If there is no data source set, this method will raise a `PSPDFLibraryInvalidOperationException`.
 Any currently queued documents will be removed.
 @warning This method will retrieve information about documents to be indexed, which might be slow, synchronously. This is important when using the file system data source.
 @note We recommend calling this on a background queue:
     `DispatchQueue.global(qos: .background).async { library.updateIndex() }`
 @see dataSource
*/
- (void)updateIndex;

/// Invalidates the search index for document with a matcing `UID`.
- (void)removeIndexForUID:(NSString *)UID;

/// Clear all database objects. Will clear ALL content in `path`.
- (void)clearAllIndexes;

#if TARGET_OS_IOS

/// @name Spotlight Helpers

/**
 Fetches the document specified by the user activity

 @param userActivity The userActivity received in your application delegata's `application:continueUserActivity:restorationHandler:` as a result of the user selecting a spotlight search result.
 @param completionHandler The block to call if the document corresponding to the userActivity has been indexed in Spotlight.
 */
- (void)fetchSpotlightIndexedDocumentForUserActivity:(NSUserActivity *)userActivity completionHandler:(void (^)(PSPDFDocument *_Nullable document))completionHandler;

#endif // TARGET_OS_IOS

/// @name Queue Operations

/**
 Queue an array of `PSPDFDocument` objects for indexing for FTS, as well as in Spotlight, if `indexToSpotlight` is enabled.

 @param documents The array of documents to be indexed.
 @note Documents that are already queued or completely indexed will be forcefully reindexed
 @warning This is a potentially slow operation
 */
- (void)enqueueDocuments:(NSArray<PSPDFDocument *> *)documents PSPDF_DEPRECATED_IOS("6.1", "Use -updateIndex instead");

/**
 Cancels all pending preview text operations.
 @note The `previewTextHandler` of cancelled operations will not be called.
*/
- (void)cancelAllPreviewTextOperations;

@end

/**
 This category allows you to encrypt the database file of your `PSPDFLibrary` instances.
 To use this functionality, you need third-party software that implement the `sqlite3_key`
 and `sqlite3_rekey` functions. An example for this is SQLCipher: https://www.zetetic.net/sqlcipher/
 Information on the necessary configuration and setup can be found here:
 https://www.zetetic.net/sqlcipher/sqlcipher-binaries-ios-and-osx/
 You also need to enable encryption support. To do this, provide register an encryption provider by
 calling `-[PSPDFKit databaseEncryptionProvider:]`.
*/
@interface PSPDFLibrary (EncryptionSupport)

/**
 Returns an encrypted library for this given path. The `encryptionKeyProvider` is used to access
 the encryption key when necessary. This allows us to not keep the encryption key around in memory.
 Your implementation of encryption key provider should therefore always load the key from secure storage,
 e.g. Apple's keychain. An encryption key provider must also be side-effect free in the sense
 that it always returns the same encryption key on every call.
 This method will return `nil` for invalid paths.

 @note In contrast to `libraryWithPath:`, this method will not return the same instance when calling
 it with an already used path.

 @warning This method will return `nil` if the given encryption key provider was invalid.
*/
+ (instancetype)encryptedLibraryWithPath:(NSString *)path encryptionKeyProvider:(nullable NSData * (^)(void))encryptionKeyProvider error:(NSError **)error;

/**
 Returns an encrypted library for this given path. The `encryptionKeyProvider` is used to access
 the encryption key when necessary. This allows us to not keep the encryption key around in memory.
 Your implementation of encryption key provider should therefore always load the key from secure storage,
 e.g. Apple's keychain. An encryption key provider must also be side-effect free in the sense
 that it always returns the same encryption key on every call.
 This method will return `nil` for invalid paths.

 You can also specify a custom `tokenizer` -- see the `tokenizer` property.

 @note In contrast to `libraryWithPath:`, this method will not return the same instance when calling
 it with an already used path.

 @warning This method will return `nil` if the given encryption key provider was invalid.
 */
+ (instancetype)encryptedLibraryWithPath:(NSString *)path encryptionKeyProvider:(nullable NSData * (^)(void))encryptionKeyProvider tokenizer:(nullable NSString *)tokenizer error:(NSError **)error;

/**
 Returns an encrypted library for this given path. The `encryptionKeyProvider` is used to access
 the encryption key when necessary. This allows us to not keep the encryption key around in memory.
 Your implementation of encryption key provider should therefore always load the key from secure storage,
 e.g. Apple's keychain. An encryption key provider must also be side-effect free in the sense
 that it always returns the same encryption key on every call.
 This method will return `nil` for invalid paths.

 You can also specify the FTS Version to use and a custom `tokenizer` -- see the `tokenizer` property.

 @note In contrast to `libraryWithPath:`, this method will not return the same instance when calling
 it with an already used path.

 @warning This method will return `nil` if the given encryption key provider was invalid.
*/
+ (instancetype)encryptedLibraryWithPath:(NSString *)path encryptionKeyProvider:(nullable NSData * (^)(void))encryptionKeyProvider ftsVersion:(PSPDFLibraryFTSVersion)ftsVersion tokenizer:(nullable NSString *)tokenizer error:(NSError **)error;

/**
 Returns an encrypted library for this given path. The `encryptionKeyProvider` is used to access
 the encryption key when necessary. This allows us to not keep the encryption key around in memory.
 Your implementation of encryption key provider should therefore always load the key from secure storage,
 e.g. Apple's keychain. An encryption key provider must also be side-effect free in the sense
 that it always returns the same encryption key on every call.
 This method will return `nil` for invalid paths.

 You can also specify the FTS Version to use and a custom `tokenizer` -- see the `tokenizer` property.

 @note In contrast to `libraryWithPath:`, this method will not return the same instance when calling
 it with an already used path.

 @warning This method will return `nil` if the given encryption key provider was invalid.
 */
+ (instancetype)encryptedLibraryWithPath:(NSString *)path encryptionKeyProvider:(nullable NSData * (^)(void))encryptionKeyProvider indexingPriority:(PSPDFLibraryIndexingPriority)priority ftsVersion:(PSPDFLibraryFTSVersion)ftsVersion tokenizer:(nullable NSString *)tokenizer error:(NSError **)error;

/// Indicates if the library instance uses encryption.
@property (nonatomic, readonly, getter=isEncrypted) BOOL encrypted;

@end

/**
 The PSPDFLibraryDataSource protocol is adopted by an object that provides the documents to be indexed by a PSPDFLibrary.
 These methods will not be called on the main queue, and can take long to execute. If you are implementing this protocol yourself and not using `PSPDFLibraryFileSystemDataSource`,
 please read the documentation carefully.
 */
PSPDF_AVAILABLE_DECL @protocol PSPDFLibraryDataSource<NSObject>

@optional

/**
 Notifies the data source that the library is about to begin the indexing process. Perform any required setup here.

 @param library The library that is about to begin indexing.
 */
- (void)libraryWillBeginIndexing:(PSPDFLibrary *)library;

@required

/**
 Asks the data source for the UIDs of the documents to be indexed by the library. This method should not return any uids that are already indexed, or they will be reindexed.
 This is useful in cases when the document was modified, and its contents changed and therefore need the index to be updated as well.

 @param library The library object requesting this information.
 @return An array of NSStrings each corresponding to the a `PSPDFDocument` UID.
 */
- (NSArray<NSString *> *)uidsOfDocumentsToBeIndexedByLibrary:(PSPDFLibrary *)library;

/**
 Asks the data source for the UIDs for documents to be removed. This method will be called by the library at the start of its indexing process to allow for removal of any non-existing documents.
 This is especially necessary when the `indexToSpotlight` property is set to YES, as having deleted documents show up in indexed spotlight search is not good.

 @param library The library object requesting this information
 @return An array of NSStrings each corresponding to a previously indexed `PSPDFDocument` UID.
 */
- (NSArray<NSString *> *)uidsOfDocumentsToBeRemovedFromLibrary:(PSPDFLibrary *)library;

/**
 Asks the data source for a document with the specified UID

 @param library The library that requires the document.
 @param UID     The UID of the requested document.
 @return A document with a matching UID, or `nil` if no such document exists.

 @warning This method may be called even without `libraryWillBeginIndexing:` being called first, if a document is required for Spotlight.
 */
- (nullable PSPDFDocument *)library:(PSPDFLibrary *)library documentWithUID:(NSString *)UID;

@end

NS_ASSUME_NONNULL_END
