//
//  PSPDFXFDFParser.h
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
#import "PSPDFAnnotationProvider.h"

NS_ASSUME_NONNULL_BEGIN

/// Parses an XML in the XFDF standard.
/// http://partners.adobe.com/public/developer/en/xml/XFDF_Spec_3.0.pdf
PSPDF_CLASS_AVAILABLE @interface PSPDFXFDFParser : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Designated initializer.
- (instancetype)initWithInputStream:(NSInputStream *)inputStream documentProvider:(PSPDFDocumentProvider *)documentProvider NS_DESIGNATED_INITIALIZER;

/// Parse XML and block until it's done. Returns the resulting annotations after parsing is finished
/// (which can also be accessed later on).
- (nullable NSArray<PSPDFAnnotation *> *)parseWithError:(NSError **)error;

/// Return all annotations as array. Annotations are sorted by page.
@property (nonatomic, copy, readonly) NSArray<PSPDFAnnotation *> *annotations;

/// Returns YES while we're parsing.
@property (atomic, readonly, getter = isParsing) BOOL parsing;

/// Returns YES if parsing has ended for `inputStream`.
@property (atomic, readonly) BOOL parsingEnded;

/// The attached document provider.
@property (nonatomic, weak, readonly) PSPDFDocumentProvider *documentProvider;

/// The used inputStream. Nilled once we're done.
@property (nonatomic, readonly, nullable) NSInputStream *inputStream;

@end

/// Converts sound encoding format name from XFDF spec values to PDF spec values
PSPDF_EXPORT NSString *PSPDFConvertXFDFSoundEncodingToPDF(NSString * _Nullable encoding);

NS_ASSUME_NONNULL_END
