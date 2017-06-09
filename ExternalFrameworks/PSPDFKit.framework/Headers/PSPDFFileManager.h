//
//  PSPDFFileManager.h
//  PSPDFKit
//
//  Copyright © 2014-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Wraps file system calls. Internal class cluster.
 Can be replaced with Enterprise SDK wrappers like Good Technology or MobileIron AppConnect.
 */
PSPDF_AVAILABLE_DECL @protocol PSPDFFileManager<NSObject>

/// If YES, then we can't use certain more optimized methods like `UIGraphicsBeginPDFContextToFile` since they would use write methods that we can't override.
@property (nonatomic, readonly) BOOL usesEncryption;

/**
 We query the file manager for exceptions where we require unencrypted files on disk.
 This method expects to return YES for any type if `usesEncryption` returns NO.
 Various features in PSPDFKit require unencrypted files while usage (Open In, QuickLook, Audio Recording)
 */
- (BOOL)allowsPolicyEvent:(NSString *)policyEvent;

/// Copies a file to an unencrypted location if the security check passes.
- (nullable NSURL *)copyFileToUnencryptedLocationIfRequired:(nullable NSURL *)fileURL policyEvent:(NSString *)policyEvent error:(NSError **)error;

/// Cleans up a temporary file. Searches both in encrypted store (if encrypted) and default disk store.
- (BOOL)cleanupIfTemporaryFile:(NSURL *)URL;

/**
 This method creates a data provider pointing to temporary data storage that is writable.
 Especially when processing documents, it might be necessary to create temporary files and using this, you can secure the
 temporary files however you like. By default, this creates a `PSPDFFileDataProvider` pointing to a temporary file.
 */
- (nullable id<PSPDFDataProvider>)createTemporaryWritableDataProviderWithPrefix:(nullable NSString *)prefix;

/// @name Directories
@property (nonatomic, readonly) NSString *libraryDirectory;
@property (nonatomic, readonly) NSString *applicationSupportDirectory;
@property (nonatomic, readonly) NSString *cachesDirectory;
@property (nonatomic, readonly) NSString *documentDirectory;
- (NSString *)temporaryDirectoryWithUID:(nullable NSString *)UID;
- (nullable NSString *)unencryptedTemporaryDirectoryWithUID:(nullable NSString *)UID; // by default same as `temporaryDirectoryWithUID:`.
- (BOOL)isNativePath:(nullable NSString *)path; // Returns true if path is native to the iOS file system.

/// @name Existence checks
- (BOOL)fileExistsAtPath:(nullable NSString *)path;
- (BOOL)fileExistsAtPath:(nullable NSString *)path isDirectory:(nullable BOOL *)isDirectory;
- (BOOL)fileExistsAtURL:(nullable NSURL *)url;
- (BOOL)fileExistsAtURL:(nullable NSURL *)url isDirectory:(nullable BOOL *)isDirectory;

/// @name Creation
- (BOOL)createFileAtPath:(NSString *)path contents:(nullable NSData *)data attributes:(nullable NSDictionary<NSString *, id> *)attributes;
- (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(nullable NSDictionary<NSString *, id> *)attributes error:(NSError **)error;

/* createDirectoryAtURL:withIntermediateDirectories:attributes:error: creates a directory at the specified URL. If you pass 'NO' for withIntermediateDirectories, the directory must not exist at the time this call is made. Passing 'YES' for withIntermediateDirectories will create any necessary intermediate directories. This method returns YES if all directories specified in 'url' were created and attributes were set. Directories are created with attributes specified by the dictionary passed to
 * 'attributes'. If no dictionary is supplied, directories are created according to the umask of the process. This method returns NO if a failure occurs at any stage of the operation. If an error parameter was provided, a presentable NSError will be returned by reference.
 */
- (BOOL)createDirectoryAtURL:(NSURL *)url withIntermediateDirectories:(BOOL)createIntermediates attributes:(nullable NSDictionary<NSString *, id> *)attributes error:(NSError **)error;

/// @name Writing
- (BOOL)writeData:(NSData *)data toFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)error;
- (BOOL)writeData:(NSData *)data toURL:(NSURL *)fileURL options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)error;

/// @name  Reading
- (nullable NSData *)dataWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)error;
- (nullable NSData *)dataWithContentsOfURL:(NSURL *)fileURL options:(NSDataReadingOptions)readOptionsMask error:(NSError **)error;

/// @name  Copy / Move
- (BOOL)copyItemAtURL:(NSURL *)sourceURL toURL:(NSURL *)destinationURL error:(NSError **)error;
- (BOOL)moveItemAtURL:(NSURL *)sourceURL toURL:(NSURL *)destinationURL error:(NSError **)error;

/// @name  Replace
- (BOOL)replaceItemAtURL:(NSURL *)originalItemURL withItemAtURL:(NSURL *)newItemURL backupItemName:(nullable NSString *)backupItemName options:(NSFileManagerItemReplacementOptions)options resultingItemURL:(NSURL *__nullable *__nullable)resultingURL error:(NSError **)error;

/// @name  Deletion
- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;
- (BOOL)removeItemAtURL:(NSURL *)URL error:(NSError **)error;

/// @name  File Statistics
- (nullable NSDictionary<NSString *, id> *)attributesOfFileSystemForPath:(NSString *)path error:(NSError **)error;
- (nullable NSDictionary<NSString *, id> *)attributesOfItemAtPath:(nullable NSString *)path error:(NSError **)error;
- (BOOL)isDeletableFileAtPath:(NSString *)path;
- (BOOL)isWritableFileAtPath:(NSString *)path;

/// @name  Directory Query
- (NSArray<NSString *> *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error;
- (NSArray<NSString *> *)subpathsOfDirectoryAtPath:(NSString *)path error:(NSError **)error;

/// @name  Misc
- (NSDirectoryEnumerator<NSString *> *)enumeratorAtPath:(NSString *)path;
- (NSDirectoryEnumerator<NSURL *> *)enumeratorAtURL:(NSURL *)url includingPropertiesForKeys:(NSArray<NSString *> *)keys options:(NSDirectoryEnumerationOptions)mask errorHandler:(nullable BOOL (^)(NSURL *url, NSError *error))handler;
- (NSString *)destinationOfSymbolicLinkAtPath:(NSString *)path error:(NSError **)error;

/// Returns the absolute path as C string.
- (const char *)fileSystemRepresentationForPath:(NSString *)path NS_RETURNS_INNER_POINTER;

/// @name  NSFileHandle
- (BOOL)fileHandleForReadingFromURL:(NSURL *)url error:(NSError **)error withBlock:(BOOL (^)(NSFileHandle *))reader;
- (BOOL)fileHandleForWritingToURL:(NSURL *)url error:(NSError **)error withBlock:(BOOL (^)(NSFileHandle *))writer;
- (BOOL)fileHandleForUpdatingURL:(NSURL *)url error:(NSError **)error withBlock:(BOOL (^)(NSFileHandle *))updater;

// @name iCloud

/* Changes whether the item for the specified URL is ubiquitous and moves the item to the destination URL. When making an item ubiquitous, the destination URL must be prefixed with a URL from -URLForUbiquityContainerIdentifier:. Returns YES if the change is successful, NO otherwise.
 */
- (BOOL)setUbiquitous:(BOOL)flag itemAtURL:(NSURL *)url destinationURL:(NSURL *)destinationURL error:(NSError **)error;

/* Returns YES if the item for the specified URL is ubiquitous, NO otherwise.
 */
- (BOOL)isUbiquitousItemAtURL:(NSURL *)url;

/* Start downloading a local instance of the specified ubiquitous item, if necessary. Returns YES if the download started successfully or wasn't necessary, NO otherwise.
 */
- (BOOL)startDownloadingUbiquitousItemAtURL:(NSURL *)url error:(NSError **)error;

/* Removes the local instance of the ubiquitous item at the given URL. Returns YES if removal was successful, NO otherwise.
 */
- (BOOL)evictUbiquitousItemAtURL:(NSURL *)url error:(NSError **)error;

/* Returns a file URL for the root of the ubiquity container directory corresponding to the supplied container ID. Returns nil if the mobile container does not exist or could not be determined.
 */
- (nullable NSURL *)URLForUbiquityContainerIdentifier:(nullable NSString *)containerIdentifier;

/* Returns a URL that can be shared with other users to allow them download a copy of the specified ubiquitous item. Also returns the date after which the item will no longer be accessible at the returned URL. The URL must be prefixed with a URL from -URLForUbiquityContainerIdentifier:.
 */
- (nullable NSURL *)URLForPublishingUbiquitousItemAtURL:(NSURL *)url expirationDate:(NSDate *_Nullable *_Nullable)outDate error:(NSError **)error;

/* Returns an opaque token that represents the current ubiquity identity. This object can be copied, encoded, or compared with isEqual:. When ubiquity containers are unavailable because the user has disabled them, or when the user is simply not logged in, this method will return nil. The NSUbiquityIdentityDidChangeNotification notification is posted after this value changes.

 If you don't need the container URL and just want to check if ubiquity containers are available you should use this method instead of checking -URLForUbiquityContainerIdentifier:.
 */
@property (nullable, readonly, copy) id<NSObject, NSCopying, NSCoding> ubiquityIdentityToken;

/// If the file manager is coordinated, this will temporarily disable coordination for more control.
- (void)performBlockWithoutCoordination:(void (^)())block;

@end

PSPDF_EXPORT NSString *const PSPDFFileManagerOptionCoordinatedAccess;
PSPDF_EXPORT NSString *const PSPDFFileManagerOptionFilePresenter;

/// The default file manager implementation is a thin wrapper around NSFileManager.
PSPDF_CLASS_AVAILABLE @interface PSPDFDefaultFileManager : NSObject<PSPDFFileManager>

- (instancetype)initWithOptions:(nullable NSDictionary<NSString *, id> *)options NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
