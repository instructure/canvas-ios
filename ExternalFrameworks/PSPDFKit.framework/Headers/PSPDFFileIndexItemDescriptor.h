//
//  PSPDFFileIndexItemDescriptor.h
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

NS_ASSUME_NONNULL_BEGIN

/// This class encapsulates the metadata associated with a document used in the PSPDFLibraryFileSystemDataSource
PSPDF_CLASS_AVAILABLE @interface PSPDFFileIndexItemDescriptor : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/**
 The document's path, relative to the file system data source's documents directory URL.
 @note Use `[NSURL fileURLWithPath:descriptor.documentPath relativeToURL:fileSystemDataSource.documentsDirectoryURL]` to construct an absolute path.
 */
@property (nonatomic, readonly) NSString *documentPath;

/// The document's UID
@property (nonatomic, readonly) NSString *documentUID;

/// The document's modification date
@property (nonatomic, readonly) NSDate *lastModificationDate;

/**
 Returns a Boolean value that indicates whether a given descriptor is equal to the receiver.

 @param other The descriptor with which to compare the receiver.
 @return YES is `other` is equivalent to the receiver, otherwise `NO`.
 */
- (BOOL)isEqualToFileIndexItemDescriptor:(PSPDFFileIndexItemDescriptor *)other;

@end

NS_ASSUME_NONNULL_END
