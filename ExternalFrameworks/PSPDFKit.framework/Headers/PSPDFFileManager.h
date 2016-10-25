//
//  PSPDFFileManager.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFPlugin.h"
#import "PSPDFDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

/// Wraps file system calls. Internal class cluster.
/// Can be replaced with Enterprise SDK wrappers like Good Technology or MobileIron AppConnect.
PSPDF_AVAILABLE_DECL @protocol PSPDFFileManager <PSPDFPlugin>

/// If YES, then we can't use certain more optimized methods like `UIGraphicsBeginPDFContextToFile` since they would use write methods that we can't override.
@property (nonatomic, readonly) BOOL usesEncryption;

/// We query the file manager for exceptions where we require unencrypted files on disk.
/// This method expects to return YES for any type if `usesEncryption` returns NO.
/// Various features in PSPDFKit require unencrypted files while usage (Open In, QuickLook, Audio Recording)
- (BOOL)allowsPolicyEvent:(NSString *)policyEvent;

/// Copies a file to an unencrypted location if the security check passes.
- (nullable NSURL *)copyFileToUnencryptedLocationIfRequired:(nullable NSURL *)fileURL policyEvent:(NSString *)policyEvent error:(NSError **)error;

/// Cleans up a temporary file. Searches both in encrypted store (if encrypted) and default disk store.
- (BOOL)cleanupIfTemporaryFile:(NSURL *)URL;

/// This method creates a data provider pointing to temporary data storage that is writable.
/// Especially when processing documents, it might be necessary to create temporary files and using this, you can secure the
/// temporary files however you like. By default, this creates a `PSPDFFileDataProvider` pointing to a temporary file.
- (id<PSPDFDataProvider>)createTemporaryWritableDataProviderWithPrefix:(nullable NSString *)prefix;

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
- (BOOL)fileExistsAtPath:(nullable NSString *)path isDirectory:(BOOL *)isDirectory;
- (BOOL)fileExistsAtURL:(nullable NSURL *)url;
- (BOOL)fileExistsAtURL:(nullable NSURL *)url isDirectory:(BOOL *)isDirectory;

/// @name Creation
- (BOOL)createFileAtPath:(NSString *)path contents:(nullable NSData *)data attributes:(nullable NSDictionary<NSString *, id> *)attributes;
- (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(nullable NSDictionary<NSString *, id> *)attributes error:(NSError **)error;

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
- (BOOL)replaceItemAtURL:(NSURL *)originalItemURL withItemAtURL:(NSURL *)newItemURL backupItemName:(nullable NSString *)backupItemName options:(NSFileManagerItemReplacementOptions)options resultingItemURL:(NSURL * __nullable * __nullable)resultingURL error:(NSError **)error;

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
- (BOOL)fileHandleForReadingFromURL:(NSURL *)url error:(NSError **)error withBlock:(BOOL(^)(NSFileHandle *))reader;
- (BOOL)fileHandleForWritingToURL:(NSURL *)url error:(NSError **)error withBlock:(BOOL(^)(NSFileHandle *))writer;
- (BOOL)fileHandleForUpdatingURL:(NSURL *)url error:(NSError **)error withBlock:(BOOL(^)(NSFileHandle *))updater;

@end

PSPDF_EXPORT NSString *const PSPDFFileManagerOptionCoordinatedAccess;
PSPDF_EXPORT NSString *const PSPDFFileManagerOptionFilePresenter;

/// The default file manager implementation is a thin wrapper around NSFileManager.
PSPDF_CLASS_AVAILABLE @interface PSPDFDefaultFileManager : NSObject <PSPDFFileManager>
@end

NS_ASSUME_NONNULL_END
