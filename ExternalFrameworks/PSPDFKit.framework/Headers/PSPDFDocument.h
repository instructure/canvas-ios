//
//  PSPDFDocument.h
//  PSPDFKit
//
//  Copyright © 2011-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnnotation.h"
#import "PSPDFBookmark.h"
#import "PSPDFCache.h"
#import "PSPDFDataProvider.h"
#import "PSPDFDocumentProvider.h"
#import "PSPDFOverridable.h"
#import "PSPDFPageBinding.h"
#import "PSPDFRenderManager.h"
#import "PSPDFRenderRequest.h"
#import "PSPDFileCoordinationDelegate.h"

#if TARGET_OS_IOS
#import <CoreSpotlight/CoreSpotlight.h>
#endif

@class PSPDFAnnotationManager, PSPDFBookmarkManager, PSPDFDocumentProvider, PSPDFEmbeddedFile, PSPDFFormParser, PSPDFOutlineParser, PSPDFPageInfo, PSPDFRenderReceipt, PSPDFTextParser, PSPDFTextSearch, PSPDFViewController, PSPDFFile;

NS_ASSUME_NONNULL_BEGIN

@protocol PSPDFDocumentDelegate;

/**
 A document posts an underlying file changed notification each time one of the
 backing files of the document is changed and the change did not originate from
 the document itself. When a file deletion can be detected, the same notification
 will be sent with a `PSPDFDocumentUnderlyingFileWillBeDeletedKey` in the user info.
 The notification will be sent on the main thread.
 */
PSPDF_EXPORT NSNotificationName const PSPDFDocumentUnderlyingFileChangedNotification;

/**
 The underlying file url key identifies the file url of the changed file inside
 a `PSPDFDocumentUnderlyingFileChangedNotification`'s user info dictionary. It
 is of type `NSURL`.
 */
PSPDF_EXPORT NSString *const PSPDFDocumentUnderlyingFileURLKey;

/// A boolean `NSNumber` indicating that the undelaying file is about to be deleted.
PSPDF_EXPORT NSString *const PSPDFDocumentUnderlyingFileWillBeDeletedKey;

/**
 The `PSPDFDocument` class represents a set of PDF sources that are displayed as one document.

 The PDF sources are internally represented as `PSPDFDataProvider` objects.
 The typical use case is to initialize the document with a single `fileURL`, which creates an implicit
 `PSPDFCoordinatedFileDataProvider` by default. You can also opt to use `NSData` or custom
 `PSPDFDataProvider`s as sources during initialization.

 This object can be created on any thread. Accessing properties is thread safe but might take some time,
 as the underlying PDF documents need to be processed to fetch data like `pageCount` or `title`.
 The document builds an internal cache, so subsequent access is faster.
 For this reason, ensure that document objects are not created/destroyed randomly for maximum efficiency.

 Ensure that a `PSPDFDocument` is only opened by one `PSPDFViewController` at any time.
 Also ensure that subclasses do not implement their own equality semantics, and instead use the `UID` property to check if two documents are equal.

 `PSPDFDocument` supports `NSFastEnumeration` by enumerating over its `documentProviders`. The document
 providers are internal wrappers around the `PSPDFDataProvider`s created during initialization.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFDocument : NSObject<PSPDFDocumentProviderDelegate, PSPDFOverridable, NSCopying, NSSecureCoding, NSFastEnumeration, PSPDFileCoordinationDelegate>

/// @name Initialization

/// Initialize empty `PSPDFDocument`.
+ (instancetype)document;

/// Initialize `PSPDFDocument` with a single file.
+ (instancetype)documentWithURL:(NSURL *)URL;

/**
 Initialize `PSPDFDocument` with data.

 @warning You might want to set a custom UID when initialized with `NSData`, else the `UID` will be calculated from a part of the PDF contents, which might be the same if the files are similar.

 @note In most cases, you really want to use a `fileURL` instead. When using `NSData`, PSPDFKit is unable to automatically save annotation changes back into the PDF.
 Keep in mind that iOS is an environment without virtual memory. Loading a large PDF will simply get your app killed by the iOS watchdog while you try to allocate more memory than is available.

 If you use `NSData` because of encryption, look into `PSPDFDataProvider` instead for a way to dynamically decrypt the needed portions of the PDF.
 */
+ (instancetype)documentWithData:(NSData *)data;

/// Initialize `PSPDFDocument` with multiple (NSData) data objects.
+ (instancetype)documentWithDataArray:(NSArray<NSData *> *)dataArray;

/// Initialize `PSPDFDocument` with a `dataProvider`.
+ (instancetype)documentWithDataProvider:(id<PSPDFDataProvider>)dataProvider;

/**
 Initialize `PSPDFDocument` with one or multiple `dataProviders` (id<PSPDFDataProvider>).
 `PSPDFCoordinatedFileDataProvider` instances will get their delegates automatically assigned to the document.
 */
+ (instancetype)documentWithDataProviderArray:(NSArray<id<PSPDFDataProvider>> *)dataProviders;

/// Initialize `PSPDFDocument` with distinct path and an array of files.
+ (instancetype)documentWithBaseURL:(nullable NSURL *)baseURL files:(NSArray<NSString *> *)files;

/**
 If you have files that have the pattern XXX_Page_0001 - XXX_Page_0200 use this initializer.
 fileTemplate needs to have exactly one '%d' marker where the page should be.
 For leading zeros, use the default printf syntax. (%04d = 0001)
 */
+ (instancetype)documentWithBaseURL:(nullable NSURL *)baseURL fileTemplate:(NSString *)fileTemplate startPage:(NSInteger)startPage endPage:(NSInteger)endPage;

/**
 Creates a new document with adding `objects`.
 @param objects  An array containing instances of `NSString` (file), `NSURL`, `NSData` or a `id<PSPDFDataProvider>`.
 @note This uses `NSCopying` to preserve custom settings.
 */
- (instancetype)documentByAppendingObjects:(NSArray *)objects;

/**
 Initialize `PSPDFDocument` with content.
 Content can be an individual object or a collection conforming to `NSFastEnumeration` containing such objects.
 Supported objects include: NSURL (files), NSString, NSData, id<PSPDFDataProvider>.
 @note It's currently not possible to add the same file multiple times, this will fail to display correctly.
 */
+ (instancetype)documentWithContent:(id)content;

/// Similar to `documentWithContent:` but accepts content signatures. Used for special type of licenses only.
+ (instancetype)documentWithContent:(id)content signatures:(nullable NSArray<NSData *> *)signatures;

/// @see documentWithURL:.
- (instancetype)initWithURL:(NSURL *)URL;

/// @see documentWithData:.
- (instancetype)initWithData:(NSData *)data;

/// @see documentWithDataArray::.
- (instancetype)initWithDataArray:(NSArray<NSData *> *)data;

/// @see documentWithDataProvider:.
- (instancetype)initWithDataProvider:(id<PSPDFDataProvider>)dataProvider;

/// @see documentWithDataProviderArray:.
- (instancetype)initWithDataProviderArray:(NSArray<id<PSPDFDataProvider>> *)dataProviders;

/// @see documentWithBaseURL:files:.
- (instancetype)initWithBaseURL:(nullable NSURL *)baseURL files:(NSArray<NSString *> *)files;

/// @see documentWithBaseURL:fileTemplate:startPage:endPage:.
- (instancetype)initWithBaseURL:(nullable NSURL *)baseURL fileTemplate:(NSString *)fileTemplate startPage:(NSInteger)startPage endPage:(NSInteger)endPage;

/// @see documentWithContent:signatures:.
- (instancetype)initWithContent:(id)content;

/// @see documentWithContent:.
- (instancetype)initWithContent:(nullable id)content signatures:(nullable NSArray<NSData *> *)signatures NS_DESIGNATED_INITIALIZER;

/// @name General

/**
 The document delegate to control saving and annotation path resolving.
 @note This can be freely set and is not directly used inside PSPDFKit.
 */
@property (nonatomic, weak) id<PSPDFDocumentDelegate> delegate;

/**
 Returns YES if the document data source can be accessed and the PDF has at least one page and is unlocked.
 Might need file operations to parse the document.
 @note Password protected documents will return NO here until the correct password is set.
 Check for `isLocked` to see if it's a protected document.
 */
@property (nonatomic, readonly, getter=isValid) BOOL valid;

/// If the document can not be opened and thus is in an error state, the error is propagated through this property.
@property (nonatomic, readonly, nullable) NSError *error;

/**
 Compare two documents for equality. Will check if the source definitions are the same.
 This will not detect two different files that are the same - for that better do a custom file comparison.
 */
- (BOOL)isEqualToDocument:(PSPDFDocument *)otherDocument;

/// @name Files

/// Common base URL for PDF files, if provided.
@property (nonatomic, readonly, nullable) NSURL *baseURL;

/// Convenience accessor for the first fileURL of the document.
@property (nonatomic, readonly, nullable) NSURL *fileURL;

/// Return all file URLs. Returns an empty array if the documents contains no file data providers.
@property (nonatomic, readonly) NSArray<NSURL *> *fileURLs;

/**
 Array of `NSString` paths representing pdf files. If `baseURL` is set, and the file resides inside
 the `baseURL` directory, the strings represent relative paths to `baseURL`. Otherwise they are absolute paths.
 Returns an empty array if the documents contains no file data providers.
 */
@property (nonatomic, readonly) NSArray<NSString *> *files;

/**
 The document itself can be comprised out of multiple files, therefore it can't be a file
 presenter on its own. Instead, you can use this property to get a list of data providers that
 confirm to `NSFilePresenter`.
 Returns an empty array if the documents contains no file data providers that support the
 `NSFilePresenter` protocol.
 */
@property (nonatomic, readonly) NSArray<id<NSFilePresenter>> *filePresenters;

/**
 In some cases, the PDF document is a converted document from an Word, Excel or other file.
 If `originalFile` is set, then some actions such as Open In or Send via Email has the option to use the original file.
 @note The "Open In" feature of iOS needs an NSURL - NSData does not work here.
 */
@property (nonatomic, nullable) PSPDFFile *originalFile;

/**
 Returns path for a single page (in case pages are split up). Page starts at 0.
 @note Uses `fileIndexForPageAtIndex:` and `URLForFileIndex:` internally. Override those instead of pathForPage.
 */
- (nullable NSURL *)pathForPageAtIndex:(NSUInteger)pageIndex;

/// Returns the position inside the internal documentProviders array.
- (NSInteger)fileIndexForPageAtIndex:(NSUInteger)pageIndex;

/// Returns the URL corresponding to the `fileIndex`.
- (nullable NSURL *)URLForFileIndex:(NSUInteger)fileIndex;

/// Gets the file name for page 0. @see fileNameForPageAtIndex:
@property (nonatomic, readonly, nullable) NSString *fileName;

/// Helper that gets a suggested fileName for a specific page.
- (NSString *)fileNameForPageAtIndex:(NSUInteger)pageIndex;

/**
 Deletes the underlying files from the disk, including the document itself and
 all cache and metadata files.

 @warning You should make sure that the receiver is no longer accessed after calling
 this method!

 @param error The error, if one occurred.

 @return YES if the deletion was successful, NO otherwise.
 */
- (BOOL)deleteFiles:(NSError **)error;

/// @name Data

/**
 PDF data when initialized with `initWithData:` otherwise nil.
 This is a shortcut to the first entry of dataArray.
 */
@property (nonatomic, readonly, nullable) NSData *data;

/**
 A document can also have multiple `NSData` objects.
 @note If writing annotations is enabled, the `dataArray`'s content will change after a save.
 Returns an empty array there are no `PSPDFDataContainerProvider` based data providers.
 */
@property (nonatomic, readonly) NSArray<NSData *> *dataArray;

/**
 Returns an ordered dictionary with filename : NSData objects.
 Will memory-map data files.
 @note If there is no file name available, this will use the PDF title or "Untitled PDF" if all fails.
 Uses `PSPDFDocumentProviders dataRepresentationWithError:`. Errors are only logged.
 */
@property (nonatomic, readonly) NSDictionary<NSString *, NSData *> *fileNamesWithDataDictionary;

/// @name Providers

/**
 PDF `dataProviders` are used to read and write PDF data from various sources.
 When initializing a document with a file URL, a suitable data provider will be automatically created to read
 data format he file. When initializing using `NSData`, a `PSPDFDataContainerProvider` managing that data
 will be included in this array.
 @note Data providers can also be used to dynamically decrypt a document.
 */
@property (nonatomic, readonly) NSArray<id<PSPDFDataProvider>> *dataProviderArray;

/// Contains the public keys to identify the data sources.
@property (nonatomic, readonly, nullable) NSArray<NSData *> *contentSignatures;

/// Get an array of document providers to easily manage documents with multiple files.
@property (nonatomic, readonly) NSArray<PSPDFDocumentProvider *> *documentProviders;

/// Get the document provider for a specific page.
- (nullable PSPDFDocumentProvider *)documentProviderForPageAtIndex:(NSUInteger)pageIndex;

/**
 Get the page offset from a specific `documentProvider`.
 Can be used to calculate from the document provider page to the `PSPDFDocument` page.
 */
- (NSUInteger)pageOffsetForDocumentProvider:(PSPDFDocumentProvider *)documentProvider;

/// @name Identifiers

/**
 Returns a document identifier (inferred from a document provider if possible).
 A permanent identifier based on the contents of the file at the time it was originally created.
 This value will stay persistent, if the document if modified or moved to a different location.
 If a document identifier is not available, generated UID value is returned.
 */
@property (nonatomic, copy, readonly, nullable) NSData *documentId;

/// Returns a string representation of a document identifier.
@property (nonatomic, copy, readonly, nullable) NSString *documentIdString;

/**
 The unique UID for the document.

 The UID will be created automatically based on the content sources that are configured.
 You can manually set an UID here as well. Just make sure to set this before the document is used/cached/displayed.
 Since the UID is used internally for the page renderer cache, you will either have to set a new UID or clear the cache if you change the PDF *contents* outside of PSPDFKit.
 The UID is built based on the first file name and an MD5 hash of the path (or a part of data if the document is used).
 @note This value might change, if the document if modified or moved to a different location.
 */
@property (nonatomic, copy, null_resettable) NSString *UID;

/// @name Page Info Data

/**
 Return pdf page count. Can be called from any thread.
 @warning Might need file operations to parse the document (slow)
 */
@property (nonatomic, readonly) NSUInteger pageCount;

/**
 Cached rotation and aspect ratio data for specific page. Page starts at 0.
 Override the methods in `PSPDFDocumentProvider` instead.

 If multiple `PSPDFDocumentProvider`s are used in one `PSPDFDocument` the returned
 `PSPDFPageInfo`'s `page` property can no longer be relied on to always equal to
 the supplied `page` argument, since `PSPDFPageInfo`'s `page` property is
 `PSPDFDocumentProvider`-relative, while the `page` argument is relative to
 all `PSPDFDocumentProvider`s in the `PSPDFDocument`.
 */
- (nullable PSPDFPageInfo *)pageInfoForPageAtIndex:(NSUInteger)pageIndex;

/**
 Makes a search beginning from page 0 for the nearest pageInfo.
 Does not calculate/block the thread.
 */
- (nullable PSPDFPageInfo *)nearestPageInfoForPageAtIndex:(NSUInteger)pageIndex;

/// @name Saving a Document

/**
 If set to YES, the document will always be rewritten from the ground up on save.
 If set to NO, the changes will be appended to the PDF, if possible. Encrypted documents do not support appending and will always re-write.

 Defaults to NO.

 @note One reason to rewrite a document is to decrease its file size. If the file is not rewritten, each change will be appended to
 the PDF file. Even removed annotations will still be included in the file, even if they are not shown.
 The disadvantage of rewriting is that it takes longer. Instead of just appending what changed, everything has to be written to disk.
 */
@property (atomic) BOOL alwaysRewriteOnSave;

/**
 Saves the document and all of its linked data with the current settings.

 Besides the document itself, this will also save its annotations and bookmarks.
 */
- (BOOL)save:(NSError **)error;

/**
 Saves the document and all of its linked data with current settings.

 @param completionHandler The completion handler that will be called after the save. This handler will always be called on the main thread.
 */
- (void)saveWithCompletionHandler:(nullable void (^)(NSError *_Nullable error, NSArray<__kindof PSPDFAnnotation *> *_Nullable savedAnnotations))completionHandler;

@end

@interface PSPDFDocument (Caching)

/**
 Will clear all cached objects (`annotations`, `pageCount`, `outline`, `textParser`, ...)

 This is called implicitly if you change the files array or append a file.

 Important! Unless you disable it, PSPDFKit also has an image cache who is not affected by this. If you replace the PDF document with new content, you also need to clear the image cache:
 `[PSPDFKit.sharedInstance.cache removeCacheForDocument:document deleteDocument:NO error:NULL];`

 @warning Calling this will also destroy any unsaved annotations.
 However, this will not automatically reload the `PSPDFViewController`.
 As with all document modifying options, call `reloadData` after calling this.
 */
- (void)clearCache;

/**
 Creates internal cache for faster display. override to provide custom caching.
 @note This is thread safe and usually called on a background thread.
 */
- (void)fillCache;

/**
 Path where data like bookmarks or annotations (if they can't be embedded into the PDF) are saved.
 Defaults to `&lt;AppDirectory&gt;/Library/PrivateDocuments/PSPDFKit`. Cannot be nil.
 Will *always* be appended by UID. Don't manually append UID.
 */
@property (nonatomic, copy) NSString *dataDirectory;

/// Make sure 'dataDirectory' exists. Returns error if creation is not possible.
- (BOOL)ensureDataDirectoryExistsWithError:(NSError **)error;

/**
 Overrides the global disk caching strategy in `PSPDFCache`.
 Defaults to -1; which equals to the setting in `PSPDFCache`.
 Set this to `PSPDFDiskCacheStrategyNothing` for sensible/encrypted documents!
 @note If the PDF is protected by a password, `PSPDFDiskCacheStrategyNothing` will be used automatically.
 */
@property (atomic) PSPDFDiskCacheStrategy diskCacheStrategy PSPDF_DEPRECATED("6.1", "Disk cache strategy is controlled automatically now. To disable the disk cache completely set its allowedDiskSpace to 0.");

@end

@interface PSPDFDocument (Security)

/**
 Unlock documents with a password.

 If the password is correct, this method returns YES. Once unlocked, you cannot use this function to re-lock the document.

 If you attempt to unlock an already unlocked document, one of the following occurs:
 If the document is unlocked with full owner permissions, `unlockWithPassword:` does nothing and returns YES. The password string is ignored.
 If the document is unlocked with only user permissions, `unlockWithPassword:` attempts to obtain full owner permissions with the password string.
 If the string fails, the document maintains its user permissions. In either case, this method returns YES.

 After unlocking a document, you need to call `reloadData` on the `PSPDFViewController`.

 If you're using multiple files or `appendFile:`, all new files will be unlocked with the password.
 This doesn't harm if the document is already unlocked.

 If you have a mixture of files with multiple different passwords, you need to subclass `didCreateDocumentProvider:` and unlock the `documentProvider` directly there.

 */

/**
 @note `password` is not exposed as a property on purpose. Ideally store the password securely in the keychain and set only when needed.
 @warning This will re-create the `PSPDFAnnotationManager` class, so you need to re-apply settings after unlocking the document.
 */
- (BOOL)unlockWithPassword:(NSString *)password;

/**
 Will re-lock a document if it has a password set.
 @warning Make sure it is not currently displayed anywhere or call `reloadData` on the pdfController afterwards.
 */
- (void)lock;

/**
 Was the PDF file encrypted at file creation time?
 @note Only evaluates the first file if multiple files are set.
 */
@property (readonly) BOOL isEncrypted;

/**
 Name of the encryption filter used, e.g. Adobe.APS. If this is set, the document can't be unlocked.
 See "Adobe LifeCycle DRM, http://www.adobe.com/products/livecycle/rightsmanagement
 @note Only evaluates the first file if multiple files are set.
 */
@property (readonly, nullable) NSString *encryptionFilter;

/**
 Has the PDF file been unlocked? (is it still locked?).
 @note Only evaluates the first file if multiple files are set.
 */
@property (readonly) BOOL isLocked;

/**
 A PDF flag that indicates whether printing is allowed.
 @note This replaces `allowsCopying` and `allowsPrinting` from earlier versions of the SDK.
 @note Only evaluates the first file if multiple files are set.
 */
@property (readonly) PSPDFDocumentPermissions permissions;

/**
 A flag that indicates whether changing existing annotations or creating new annotations are allowed
 @note Searches and checks the digital signatures on the first call (caches the result for subsequent calls)
 */
@property (readonly) BOOL allowAnnotationChanges;

@end

@interface PSPDFDocument (Bookmarks)

/// Globally enable/disable bookmarks. Defaults to YES.
@property (getter=isBookmarksEnabled) BOOL bookmarksEnabled;

/**
 Accesses the bookmark manager.
 Bookmarks are handled on document level, not on `documentProvider`.

 @note Bookmarks are loaded from the document by default.
 The document must be valid for the manager to be loaded - otherwise it's nil.
 */
@property (readonly, nullable) PSPDFBookmarkManager *bookmarkManager;

/**
 Returns the bookmarks.
 @note The `PSPDFBookmark` objects themselves are not changed, only those who are not visible are filtered out.
 */
@property (readonly) NSArray<PSPDFBookmark *> *bookmarks;

@end

@interface PSPDFDocument (PageLabels)

/// Set to NO to disable the custom PDF page labels and simply use page numbers. Defaults to YES.
@property (getter=isPageLabelsEnabled) BOOL pageLabelsEnabled;

/**
 Page labels for the current document.
 Page labels are a feature that allows to set a different page number/index than what is inferred from the document by default.
 Might be nil if the PageLabels dictionary isn't set in the PDF.
 If `substituteWithPlainLabel` is set to YES then this always returns a valid string.
 @note If `pageLabelsEnabled` is set to NO, then this method will either return nil or the plain label if `substitute` is YES.
 */
- (nullable NSString *)pageLabelForPageAtIndex:(NSUInteger)pageIndex substituteWithPlainLabel:(BOOL)substitute;

/// Find page of a page label.
- (NSUInteger)pageForPageLabel:(NSString *)pageLabel partialMatching:(BOOL)partialMatching;

@end

@interface PSPDFDocument (Forms)

/**
 Set to NO to disable displaying/editing AcroForms. Defaults to YES.
 @note Not all PSPDFKit variants do support AcroForms.
 @warning For `formsEnabled` to work, you need to also set `annotationsEnabled` to YES, since forms are simply a special sub-type of Widget annotations.
 */
@property (getter=isFormsEnabled) BOOL formsEnabled;

/// Control JavaScript processing. Defaults to YES.
@property (getter=isJavaScriptEnabled) BOOL javaScriptEnabled;

/// AcroForm parser for the document.
@property (readonly, nullable) PSPDFFormParser *formParser;

@end

@interface PSPDFDocument (EmbeddedFiles)

/// Returns all embedded file objects. (`PSPDFEmbeddedFile`)
@property (readonly) NSArray<PSPDFEmbeddedFile *> *allEmbeddedFiles;

@end

/// Annotations can be saved in the PDF or alongside in an external file.
typedef NS_ENUM(NSInteger, PSPDFAnnotationSaveMode) {
    /// Saving is disabled.
    PSPDFAnnotationSaveModeDisabled,
    /// Will save to an external file. Uses `save/loadAnnotationsWithError:` in `PSPDFAnnotationManager`.
    PSPDFAnnotationSaveModeExternalFile,
    /// Will only save directly into the PDF.
    PSPDFAnnotationSaveModeEmbedded,
    /// Tries to save into the PDF if the file is writable, else falls back to external file.
    PSPDFAnnotationSaveModeEmbeddedWithExternalFileAsFallback
} PSPDF_ENUM_AVAILABLE;

@interface PSPDFDocument (Annotations)

/**
 Master switch to completely disable annotation display/parsing on a document. Defaults to YES.
 @note This will disable the creation of the `PSPDFAnnotationManager`.
 @warning This will also disable links and forms. In most cases, this is not what you want.
 To disable editing features, instead customize `editableAnnotationTypes` in `PSPDFConfiguration`.
 */
@property (nonatomic, getter=isAnnotationsEnabled) BOOL annotationsEnabled;

/**
 Add `annotations` to the current document (and the backing store `PSPDFAnnotationProvider`)
 @param annotations An array of PSPDFAnnotation objects to be inserted.
 @param options Insertion options (see the `PSPDFAnnotationOption...` constants in `PSPDFAnnotationManager.h`).
 @note For each, the `absolutePage` property of the annotation is used.
 @warning Might change the `page` property if multiple documentProviders are set.
 */
- (BOOL)addAnnotations:(NSArray<PSPDFAnnotation *> *)annotations options:(nullable NSDictionary<PSPDFRenderOption, id> *)options;

/**
 Remove `annotations` from the backing `PSPDFAnnotationProvider` object(s).
 @param annotations An array of PSPDFAnnotation objects to be removed.
 @param options Deletion options (see the `PSPDFAnnotationOption...` constants in `PSPDFAnnotationManager.h`).
 @note Might return NO if one or multiple annotations couldn't be deleted.
 This might be the case for form annotations or other objects that return NO for `isDeletable`.
 */
- (BOOL)removeAnnotations:(NSArray<PSPDFAnnotation *> *)annotations options:(nullable NSDictionary<PSPDFRenderOption, id> *)options;

/// Returns annotations for a specific `page`.
- (nullable NSArray<__kindof PSPDFAnnotation *> *)annotationsForPageAtIndex:(NSUInteger)pageIndex type:(PSPDFAnnotationType)type;

/**
 Returns all annotations in this document.
 Will not add key entries for pages without annotations.
 @note To check for all annotations, but not links or forms, you will want to use `PSPDFAnnotationTypeAll&~(PSPDFAnnotationTypeLink|PSPDFAnnotationTypeWidget)` (Objective-C) or `PSPDFAnnotationType.All.subtract([.Link, .Widget])` (Swift).
 @warning Parsing annotations can take some time. Can be called from a background thread.
 */
- (NSDictionary<NSNumber *, NSArray<__kindof PSPDFAnnotation *> *> *)allAnnotationsOfType:(PSPDFAnnotationType)annotationType;

/**
 Returns true if the document contains annotations.
 This scans the document in an efficient way and exits early as soon as an annotation was found.
 @note This call checks for all annotation types except Link and Widget (Forms).
 Annotations that are soft-deleted will be ignored.
 */
@property (nonatomic, readonly) BOOL containsAnnotations;

@end

@interface PSPDFDocument (AnnotationSaving)

/// Called before the document starts to save annotations. Use to save any unsaved changes.
PSPDF_EXPORT NSNotificationName const PSPDFDocumentWillSaveAnnotationsNotification;

/**
 Tests if we can embed annotations into this PDF. Certain PDFs (e.g. with encryption, or broken xref index) are readonly.
 @note Only evaluates the first file if multiple files are set.
 @warning This might block for a while, the PDF needs to be parsed to determine this.
 */
@property (readonly) BOOL canEmbedAnnotations;

/**
 Returns YES if annotations can be saved, either in the PDF or in an external file.
 Also returns YES when one of the `documentProviders` is not using the default annotation provider.
 @note This largely depends on `canEmbedAnnotations` and `annotationSaveMode`.
 */
@property (readonly) BOOL canSaveAnnotations;

/**
 Control if and where PSPDFObjectsAnnotationsKey are saved.
 Possible options are `PSPDFAnnotationSaveModeDisabled`, `PSPDFAnnotationSaveModeExternalFile`, `PSPDFAnnotationSaveModeEmbedded` and `PSPDFAnnotationSaveModeEmbeddedWithExternalFileAsFallback`. (Default)
 @note PSPDFKit automatically saves the document for various events. See `autosaveEnabled` in `PSPDFViewController`.
 */
@property (nonatomic) PSPDFAnnotationSaveMode annotationSaveMode;

/// `NSUserDefaults` key for the default global annotation author name.
PSPDF_EXPORT NSString *const PSPDFDocumentDefaultAnnotationUsernameKey;

/**
 Default annotation username for new annotations. Defaults to the device name.
 Written as the "T" (title/user) property of newly created annotations.
 */
@property (atomic, copy, nullable) NSString *defaultAnnotationUsername;

/// Contains the boxed `PSPDFAnnotationType` to control appearance stream generation for each type.
PSPDF_EXPORT NSString *const PSPDFAnnotationWriteOptionsGenerateAppearanceStreamForTypeKey;

/**
 Allows control over what annotation should get an AP stream.
 AP (Appearance Stream) generation takes more time but will maximize compatibility with PDF Viewers that don't implement the complete spec for annotations.
 The default value for this dict is `@{PSPDFAnnotationWriteOptionsGenerateAppearanceStreamForTypeKey: @(PSPDFAnnotationTypeFreeText|PSPDFAnnotationTypeInk|PSPDFAnnotationTypePolygon|PSPDFAnnotationTypePolyLine|PSPDFAnnotationTypeLine|PSPDFAnnotationTypeSquare|PSPDFAnnotationTypeCircle|PSPDFAnnotationTypeStamp|PSPDFAnnotationTypeWidget)}`
 */
@property (atomic, copy, nullable) NSDictionary<NSString *, NSNumber *> *annotationWritingOptions;

/**
 Returns YES if there are unsaved annotations.
 @note This might not include unsaved open annotation creation operations, like a partial drawing. First set `pdfController.annotationStateManager.state = nil` to make sure you're not in an editing mode before evaluating this.
 */
@property (nonatomic, readonly) BOOL hasDirtyAnnotations;

@end

@interface PSPDFDocument (Rendering)

/**
 Special PDF rendering options for the methods in `PSPDFDocument`. For more options, see `PSPDFRenderManager.h`
 If added to options, this will change size to fit the aspect ratio.
 */
PSPDF_EXPORT NSString *const PSPDFPreserveAspectRatioKey PSPDF_DEPRECATED("6.0", "Use PSPDFRenderOptionPreserveAspectRatioKey instead.");

/// Always draw pixels with a 1.0 scale.
PSPDF_EXPORT NSString *const PSPDFIgnoreDisplaySettingsKey PSPDF_DEPRECATED("6.0", "Use PSPDFRenderOptionIgnoreDisplaySettingsKey instead.");

/**
 Renders the page or a part of it with default display settings into a new image.
 @param size          The size of the page, in pixels, if it was rendered without clipping
 @param clipRect      A rectangle, relative to size, that specifies the area of the page that should be rendered. CGRectZero = automatic.
 @param annotations   Annotations that should be rendered with the view
 @param options       Dictionary with options that modify the render process (see PSPDFPageRenderer). Will be merged with renderOptions of the document, with options taking precedence over renderOptions.
 @param error         Returns an error object. (then image will be nil)
 @return              A new UIImage with the rendered page content
 */
- (nullable UIImage *)imageForPageAtIndex:(NSUInteger)pageIndex size:(CGSize)size clippedToRect:(CGRect)clipRect annotations:(nullable NSArray<PSPDFAnnotation *> *)annotations options:(nullable NSDictionary<PSPDFRenderOption, id> *)options error:(NSError **)error;

/**
 Draw a page into a specified context. If for some reason renderPage: doesn't return a Render Receipt, an error occurred.
 @param options       Dictionary with options that modify the render process (see PSPDFPageRenderer). Will be merged with renderOptions of the document, with options taking precedence over renderOptions.
 @note if `annotations` is nil, they will be auto-fetched. Add an empty array if you don't want to render annotations.
 */
- (BOOL)renderPageAtIndex:(NSUInteger)pageIndex context:(CGContextRef)context size:(CGSize)size clippedToRect:(CGRect)clipRect annotations:(nullable NSArray<PSPDFAnnotation *> *)annotations options:(nullable NSDictionary<PSPDFRenderOption, id> *)options error:(NSError **)error;

/**
 *  Set custom render options. See  PSPDFRenderManager.h for a list of available keys.
 *
 *  @param options The render options to set. Will reset to defaults if set to nil.
 *  @param type    The type you want to change. There are different render operation types.
 *
 *  @note There are certain default render options set, such as `PSPDFRenderInteractiveFormFillColorKey` which you most likely want to preserve.
 *
 *  The typical access pattern is:
 *    1) get existing render options
 *    2) customize the dictionary,
 *    3) and set the new merged render options.
 *
 *  If you are working with primarily dark documents, consider setting
 *  `PSPDFRenderBackgroundFillColorKey` to `UIColor.blackColor` to work around
 *  white/gray hairlines at document borders.
 */
- (void)setRenderOptions:(nullable NSDictionary<PSPDFRenderOption, id> *)options type:(PSPDFRenderType)type;

/**
 *  Updates render options. Overrides new settings but does not destroy existing settings.
 *
 *  @param options Settings to add/replace in the renderOptions dictionary.
 *  @param type    The type you want to change.
 */
- (void)updateRenderOptions:(NSDictionary<PSPDFRenderOption, id> *)options type:(PSPDFRenderType)type;

/**
 *  Returns the render options for a specific type of operation.
 *
 *  @param type    The specific operation type.
 *  @param context An optional context matching the operation type.
 *                 For `PSPDFRenderTypePage` this is an `NSNumber` of the page.
 *
 *  @return The render dictionary. Guaranteed to always return a dictionary.
 */
- (NSDictionary<PSPDFRenderOption, id> *)renderOptionsForType:(PSPDFRenderType)type context:(nullable id)context;

/// Set what annotations should be rendered. Defaults to `PSPDFAnnotationTypeAll`.
@property (atomic) PSPDFAnnotationType renderAnnotationTypes;

@end

/// Creates annotations based on the text content. See `detectLinkTypes:forPagesInRange:`.
typedef NS_OPTIONS(NSUInteger, PSPDFTextCheckingType) {
    PSPDFTextCheckingTypeNone = 0,
    PSPDFTextCheckingTypeLink = 1 << 0,
    PSPDFTextCheckingTypePhoneNumber = 1 << 1,
    PSPDFTextCheckingTypeAll = NSUIntegerMax,
};

@interface PSPDFDocument (Metadata)

/**
 Document title as shown in the controller.
 If this is not set, the framework tries to extract the title from the PDF metadata.
 If there's no metadata, the fileName is used. ".pdf" endings will be removed either way.
 @note Can be set to a custom value, in that case this overrides the PDF metadata.
 Custom titles don't get saved into the PDF.
 Setting the custom title to nil will again use the predefined PDF contents.
 */
@property (nonatomic, copy, nullable) NSString *title;

/**
 Title might need to parse the file and is potentially slow.
 Use this to check if title is loaded and access title in a thread if not.
 */
@property (readonly, getter=isTitleLoaded) BOOL titleLoaded;

typedef NSString *PSPDFMetadataName NS_EXTENSIBLE_STRING_ENUM;

/// Common PDF metadata keys.
PSPDF_EXPORT PSPDFMetadataName const PSPDFMetadataTitleKey;
PSPDF_EXPORT PSPDFMetadataName const PSPDFMetadataAuthorKey;
PSPDF_EXPORT PSPDFMetadataName const PSPDFMetadataSubjectKey;
PSPDF_EXPORT PSPDFMetadataName const PSPDFMetadataKeywordsKey;
PSPDF_EXPORT PSPDFMetadataName const PSPDFMetadataCreatorKey;
PSPDF_EXPORT PSPDFMetadataName const PSPDFMetadataProducerKey;
PSPDF_EXPORT PSPDFMetadataName const PSPDFMetadataCreationDateKey;
PSPDF_EXPORT PSPDFMetadataName const PSPDFMetadataModDateKey;
PSPDF_EXPORT PSPDFMetadataName const PSPDFMetadataTrappedKey;

/**
 Access the PDF metadata of the first PDF document.
 A PDF might not have any metadata at all.
 See `PSPDFMetadataTitleKey` and the following defines for keys that might be set.
 */
@property (readonly) NSDictionary<PSPDFMetadataName, id> *metadata PSPDF_DEPRECATED(6.6, "This property will go away in future versions of PSPDFKit. It has been replaced by the `PSPDFDocumentPDFMetadata` class");

#if TARGET_OS_IOS
/**
 Returns a pre-set attribute set for easier Spotlight integration. Thumbnail rendering is optional and might take some time.

 @param renderThumbnail Specifies whether the thumbnail should be rendered and included in the attribute set.
 @return An attribute set with properties set to match the PDFs metadata, as available. This does not contain the document's text content. If the document is not a valid PDF, the method returns nil.
 @note Because this method might take a nontrivial amount of time to render the thumbnail image, you should call it from a secondary thread.
 */
- (nullable CSSearchableItemAttributeSet *)searchableItemAttributeSetWithThumbnail:(BOOL)renderThumbnail;
#endif

@end

@interface PSPDFDocument (SubclassingHooks)

/**
 Use this to use specific subclasses instead of the default PSPDF* classes.
 e.g. add an entry of `PSPDFAnnotationManager.class` / `MyCustomAnnotationManager.class` to use the custom subclass.
 (`MyCustomAnnotationManager` must be a subclass of `PSPDFAnnotationManager`)

 @throws an exception if the overriding class is not a subclass of the overridden class.
 @note Does not get serialized when saved to disk. Only set from the main thread, before you first use the object.
 Set up your class overrides before calling any other method on the document.
 */
- (void)overrideClass:(Class)builtinClass withClass:(Class)subclass;

/**
 Hook to modify/return a different document provider. Called each time a documentProvider is created (which is usually on first access, and cached afterwards)
 During `PSPDFDocument` lifetime, document providers might be created at any time, lazily, and destroyed when memory is low.
 This might be used to change the delegate of the `PSPDFDocumentProvider`.
 */
- (PSPDFDocumentProvider *)didCreateDocumentProvider:(PSPDFDocumentProvider *)documentProvider;

/**
 Register a block that is called in `didCreateDocumentProvider:`

 @warning This needs to be set very early, before the document providers have been created (thus, before accessing any properties like pageCount or setting it to the view controller)
 */
@property (nonatomic, copy, nullable) void (^didCreateDocumentProviderBlock)(PSPDFDocumentProvider *documentProvider);

/// Override to customize file name for the send via email feature.
- (NSString *)fileNameForIndex:(NSUInteger)fileIndex;

@end

@class PSPDFUndoController;

@interface PSPDFDocument (Advanced)

/**
 Enable/Disable undo. Set this before `undoController` is first accessed!
 Defaults to YES.
 */
@property (nonatomic, getter=isUndoEnabled) BOOL undoEnabled;

/**
 The undo manager attached to the document. Set to nil to disable undo/redo management.
 @note Undo/Redo has a small performance impact since all annotation operations are tracked.
 */
@property (nonatomic, readonly) PSPDFUndoController *undoController;

/// To calculate pages between multiple document providers.
- (NSUInteger)relativePageIndexForPageAtIndex:(NSUInteger)pageIndex;

/**
 Page binding describes the side on which a book would have its binding. It is used
 to describe the scroll direction and page layout in various views through out the
 framework.

 A page binding of `PSPDFPageBindingRightEdge` usually is found on PDFs with right
 to left writing systems as their main content, such as Arabic, but also in vertical
 systems such as Chinese, Japanese, and Korean.

 If you are not familiar with the differences between right-to-left (RTL/R2L) and
 left-to-right (LTR/L2R) writing systems, imagine a stack of paper. If you want
 to create a book out of this stack, you can add a binding either on the left or
 on the right side of the stack. If the writing on the pages has a RTL reading direction
 you would usually add the binding on the right side, if it has a LTR reading direction,
 you would usually add the binding on the left. This property controls exactly this,
 as a PDF is just a stack of pages.

 The default value is read from the PDF and is set to `PSPDFPageBindingUnknown`
 if the PDF does not provide this value, which will make the UI fall back to a default
 page layout.

 You can set this property to force a specific page binding on a document.

 @note If you set this property, make sure to call `reloadData` on any `PSPDFViewController`
       currently displaying this document.
 */
@property (nonatomic) PSPDFPageBinding pageBinding;

/// Attached PSPDFKit instance.
@property (nonatomic, readonly) PSPDFKit *pspdfkit;

@end

@interface PSPDFDocument (Deprecated)

/// Returns a `NSURL` files array with the base path already added (if there is one).
@property (nonatomic, readonly) NSArray<NSURL *> *filesWithBasePath PSPDF_DEPRECATED(6.6, "Use `fileURLs` instead.");

@end

NS_ASSUME_NONNULL_END
