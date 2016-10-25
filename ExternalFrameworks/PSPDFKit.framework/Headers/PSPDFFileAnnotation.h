//
//  PSPDFFileAnnotation.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnnotation.h"
#import "PSPDFEmbeddedFile.h"

NS_ASSUME_NONNULL_BEGIN

PSPDF_CLASS_AVAILABLE @interface PSPDFFileAnnotation : PSPDFAnnotation

/// File appearance name. Defines how the attachment looks. Supported are PushPin, Paperclip, Graph and Tag.
@property (nonatomic, copy, nullable) NSString *appearanceName;

/// The embedded file. Use the `PSPDFEmbeddedFileParser` to get the URL.
@property (nonatomic, nullable) PSPDFEmbeddedFile *embeddedFile;

@end

NS_ASSUME_NONNULL_END
