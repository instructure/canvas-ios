//
//  PSPDFXFDFAnnotationProvider.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFContainerAnnotationProvider.h"

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `PSPDFAnnotationProvider` protocol that uses a XFDF file as a source.
/// The XFDF file needs to be local and in a writable location, not on a web server.
/// This annotation provider handles data form fields according to the XFDF spec: "An XFDF file with form data contains form field names and values. When importing XFDF into Acrobat, the target PDF file must already contain the form fields. Importing XFDF updates the form field values in the PDF file. Exporting to XFDF puts the current value of the field in the value element. Using XFDF, it is not possible to create a new form field in a PDF document, or change anything other than the value of an existing form field."
/// It compliments an existing data form fields from PDF with values from the XFDF file. If data form field value is not found in the XFDF file it will be served by this provider with the default value.
/// @note Requires the `PSPDFFeatureMaskAnnotationEditing` feature flag.
PSPDF_CLASS_AVAILABLE @interface PSPDFXFDFAnnotationProvider : PSPDFContainerAnnotationProvider

/// Designated initializers.
- (instancetype)initWithDocumentProvider:(PSPDFDocumentProvider *)documentProvider NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithDocumentProvider:(PSPDFDocumentProvider *)documentProvider fileURL:(NSURL *)XFDFFileURL NS_DESIGNATED_INITIALIZER;

/// The XFDF file URL.
@property (nonatomic, copy, readonly, nullable) NSURL *fileURL;

/// The input stream. If you set `fileURL`, this is automatically set for you.
@property (atomic, readonly, nullable) NSInputStream *inputStream;

/// The output stream. If you set `fileURL`, this is automatically set for you.
@property (atomic, readonly, nullable) NSOutputStream *outputStream;

/// Will force-load annotations. Usually invoked lazily.
/// Use `hasLoadedAnnotationsForPage:` with any page (usually page 0) to detect if the annotations have been loaded yet.
- (void)loadAllAnnotations;

/// @name Stream Creators

/// This block will be called when we first access `inputStream`.
/// The default implementation will create a default input stream from `fileURL`.
@property (atomic, copy, nullable) NSInputStream * (^createInputStreamBlock)(PSPDFXFDFAnnotationProvider *provider);

/// This block will be called when we first access `outputStream`.
/// The default implementation will create a default output stream from `fileURL`.
@property (atomic, copy, nullable) NSOutputStream * (^createOutputStreamBlock)(PSPDFXFDFAnnotationProvider *provider);

@end

NS_ASSUME_NONNULL_END
