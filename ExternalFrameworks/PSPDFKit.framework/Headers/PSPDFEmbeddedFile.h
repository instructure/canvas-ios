//
//  PSPDFEmbeddedFile.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFModel.h"
#import "PSPDFJSONAdapter.h"

@class PSPDFDocumentProvider;

NS_ASSUME_NONNULL_BEGIN

/// Represents an embedded file.
PSPDF_CLASS_AVAILABLE @interface PSPDFEmbeddedFile : PSPDFModel

/// The document provider, if available.
@property (nonatomic, weak, readonly) PSPDFDocumentProvider *documentProvider;

/// File name.
@property (nonatomic, readonly, copy) NSString *fileName;

/// File size.
@property (nonatomic, readonly) uint64_t fileSize;

/// File description. Optional.
@property (nonatomic, readonly, copy, nullable) NSString *fileDescription;

/// File modification date (if set)
@property (nonatomic, readonly, nullable) NSDate *modificationDate;

/// If the file URL has been extracted by XFDF or external saving, it is set here.
/// @note In most cases, you should call `fileURLWithError:` instead to fetch the URL.
@property (nonatomic, readonly, copy, nullable) NSURL *fileURL;

/// Retrieves the embedded stream and returns a file URL to the data.
/// This also sets `fileURL` if successful.
- (nullable NSURL *)fileURLWithError:(NSError *__autoreleasing*)error;

@end

NS_ASSUME_NONNULL_END
