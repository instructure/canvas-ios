//
//  PSPDFEmbeddedFilesParser.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocumentProvider, PSPDFEmbeddedFile;

/// Parses files embedded in the PDF.
PSPDF_CLASS_AVAILABLE @interface PSPDFEmbeddedFilesParser : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Attached document provider.
@property (nonatomic, weak, readonly) PSPDFDocumentProvider *documentProvider;

/// Array of `PSPDFEmbeddedFile` objects.
@property (nonatomic, copy, readonly) NSArray<PSPDFEmbeddedFile *> *embeddedFiles;

@end

NS_ASSUME_NONNULL_END
