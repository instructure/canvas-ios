//
//  PSPDFLibraryFileSystemDataSource.h
//  PSPDFModel
//
//  Copyright © 2016-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFLibrary.h"

@class PSPDFDocument, PSPDFFileIndexItemDescriptor;

NS_ASSUME_NONNULL_BEGIN

/**
 A block that is called for each candidate for indexing found when traversing the specified directory.

 @param document The candidate document.
 @param stop A pointer to a Boolean value. The block can set the value to YES to stop further enumeration of the directory. If a block stops further enumeration, that block continues to run until it’s finished. The stop argument is an out-only argument. You should only ever set this Boolean to YES within the block.
 @return A Boolean value that indicates whether document should be indexed or not.
 */
typedef BOOL (^PSPDFLibraryFileSystemDataSourceDocumentHandler)(PSPDFDocument *document, BOOL *stop);

@protocol PSPDFLibraryFileSystemDataSourceDocumentProvider;

/**
 A library data source that indexes all documents in a specified directory.
 This class automatically will automatically add and remove files from the library based on changes in the directory.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFLibraryFileSystemDataSource : NSObject<PSPDFLibraryDataSource>

PSPDF_EMPTY_INIT_UNAVAILABLE

/**
 Initializes a file system data source.

 @param library The library for which the data source is being created.
 @param URL The URL to the directory whose contents need to be indexed.
 @param documentHandler The block to be called for each document found when traversing the specified directory. Specifying `nil` for this means makes the data source accept all documents.
 @return An instance of `PSPDFLibraryFileSystemDataSource`.
 */
- (instancetype)initWithLibrary:(PSPDFLibrary *)library documentsDirectoryURL:(NSURL *)URL documentHandler:(nullable PSPDFLibraryFileSystemDataSourceDocumentHandler)documentHandler NS_DESIGNATED_INITIALIZER;

/**
 The library to which the receiver will be providing data.
 */
@property (nonatomic, weak, readonly) PSPDFLibrary *library;

/**
 The URL containing the documents to be indexed.
 */
@property (nonatomic, readonly) NSURL *documentsDirectoryURL;

/**
 The block to be called for each document found when traversing the specified directory. Setting this to nil means makes the receiver accept all documents.
 */
@property (atomic, copy, nullable) PSPDFLibraryFileSystemDataSourceDocumentHandler documentHandler;

/**
 Options for the directory enumeration. For a list of valid options, see `NSDirectoryEnumerationOptions`.
 Defaults to NSDirectoryEnumerationSkipsHiddenFiles.
 */
@property (atomic) NSDirectoryEnumerationOptions directoryEnumerationOptions;

/**
 Returns a descriptor with some metadata for the document UID, if it has been requested for indexing.

 @param UID The UID of the document for which the descriptor is required.
 @return A `PSPDFFileIndexItemDescriptor` object if one was found for the specfied UID, else `nil`.

 @warning It is possible for the first call to this method to take some time if any I/O is required.
 */
- (nullable PSPDFFileIndexItemDescriptor *)indexItemDescriptorForDocumentWithUID:(NSString *)UID;

/// @name Advanced Usage

/// The document provider to be set to customise the documents to be used by the file system data source.
/// One possible use is to unlock or decrypt documents
@property (atomic, weak, nullable) id<PSPDFLibraryFileSystemDataSourceDocumentProvider> documentProvider;

/**
 Specifies whether the receiver should only act on changes that are explicitly provided to it, rather than traversing the directory and picking up changes.
 Set this property to YES if you are able to specify which changes took place in the documents directory of the receiver, thus avoiding the overhead of directory traversal.

 @warning Setting this to YES before an initial index means that the PSPDFLibraryDataSource methods will only vend manually added or removed documents.
 */
@property (atomic, getter=isExplicitModeEnabled) BOOL explicitModeEnabled;

/**
 Notifies the receiver that a document was added or modified to the documents directory.
 If the URL does not contain the documents directory, then this method does nothing.

 @param URL The URL for the document that was added or modified.
 @warning If the `explicitModeEnabled` property is set to `NO`, this method will assert and crash.
 */
- (void)didAddOrModifyDocumentAtURL:(NSURL *)URL;

/**
 Notifies the receiver that a document was removed from the documents directory.
 If the URL does not contain the documents directory, then this method does nothing.

 @param URL The URL for the document that was added or modified.
 @warning If the `explicitModeEnabled` property is set to `NO`, this method will assert and crash.
 */
- (void)didRemoveDocumentAtURL:(NSURL *)URL;

@end

PSPDF_AVAILABLE_DECL @protocol PSPDFLibraryFileSystemDataSourceDocumentProvider<NSObject>

@required

/**
 Returns a document for the specified data source to use for the given UID and path.

 @param dataSource The data source requesting the document.
 @param UID The UID of the document requested. This can be nil. If not, the returned document's UID must match the this argument.
 @param fileURL The URL of the document.
 @return The document for the requested UID and path. Return nil to ignore this document
 */
- (nullable PSPDFDocument *)dataSource:(PSPDFLibraryFileSystemDataSource *)dataSource documentWithUID:(nullable NSString *)UID atURL:(NSURL *)fileURL;

@end

NS_ASSUME_NONNULL_END
