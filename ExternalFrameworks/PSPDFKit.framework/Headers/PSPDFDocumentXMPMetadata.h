//
//  PSPDFDocumentXMPMetadata.h
//  PSPDFModel
//
//  Copyright © 2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

@class PSPDFDocument, PSPDFDocumentProvider;

NS_ASSUME_NONNULL_BEGIN

/// The XMP PDF namespace.
PSPDF_EXPORT NSString *const PSPDFXMPPDFNamespace;

/// The XMP PDF namespace prefix.
PSPDF_EXPORT NSString *const PSPDFXMPPDFNamespacePrefix;

/// The XMP Dublin Core namespace.
PSPDF_EXPORT NSString *const PSPDFXMPDCNamespace;

/// The XMP Dublin Core namespace prefix.
PSPDF_EXPORT NSString *const PSPDFXMPDCNamespacePrefix;

/**
 This class allows you to modify a PDF documents metadata.
 Metadata is defined in two ways in the PDF spec (§ 14.3):

 - A metadata stream containing XMP data. This class is handling this. (https://en.wikipedia.org/wiki/Extensible_Metadata_Platform)
 - The Info PDF dictionary. See `PSPDFDocumentPDFMetadata`.

 ### XMP support

 This class implements limited XMP support. You can only set and retrieve simple strings.

 #### Namespaces

 Each key in the XMP metadata stream has to have a namespace set. You can define your own namespace or use one of the
 already existing ones. PSPDFKit exposes two constants for common namespaces:

 - `PSPDFXMPPDFNamespace`/`PSPDFXMPPDFNamespacePrefix`: The XMP PDF namespace created by Adobe: https://www.adobe.com/content/dam/Adobe/en/devnet/xmp/pdfs/XMPSpecificationPart2.pdf §3.1
 - `PSPDFXMPDCNamespace`/`PSPDFXMPDCNamespacePrefix`: The Dublin Core namespace: https://en.wikipedia.org/wiki/Dublin_Core

 When setting a value, you also have to pass along a suggested namespace prefix, as this can't be automatically generated.

 */
PSPDF_CLASS_AVAILABLE @interface PSPDFDocumentXMPMetadata : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/**
 Initializes the `PSPDFDocumentXMPMetadata` with a document.
 The document needs to be valid. If its not, reading or setting values will fail gracefully.
 @note If `document` is a compound document, this will provide access to ONLY the first `PSPDFDocumentProvider`.
 */
- (instancetype)initWithDocument:(PSPDFDocument *)document;

/// Initializes the `PSPDFDocumentXMPMetadata` with a document provider.
- (instancetype)initWithDocumentProvider:(PSPDFDocumentProvider *)documentProvider NS_DESIGNATED_INITIALIZER;

/// Provides access to the document this instance is handling.
@property (nonatomic, readonly) PSPDFDocument *document;

/// Provides access to the document provider this instance is handling.
@property (nonatomic, readonly) PSPDFDocumentProvider *documentProvider;

/// Returns the string that is set in the XMP metadata stream for the given namespace and key.
- (nullable NSString *)stringForXMPKey:(NSString *)key namespace:(NSString *)ns;

/**
 Sets the given `string` for the given XMP key.

 @param string The string you want to set.
 @param key The key in the XMP top level dictionary.
 @param ns The namespace you want to use.
 @param nsPrefix The suggested namespace prefix for the namespace.

 */
- (void)setString:(nullable NSString *)string forXMPKey:(NSString *)key namespace:(NSString *)ns suggestedNamespacePrefix:(NSString *)nsPrefix;

@end

NS_ASSUME_NONNULL_END
