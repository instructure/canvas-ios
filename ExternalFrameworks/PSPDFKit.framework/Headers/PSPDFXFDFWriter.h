//
//  PSPDFXFDFWriter.h
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

/// Writes an XML in XFDF standard from PSPDFKit annotations.
/// http://partners.adobe.com/public/developer/en/xml/XFDF_Spec_3.0.pdf
PSPDF_CLASS_AVAILABLE @interface PSPDFXFDFWriter : NSObject

/// Writes the given annotations to the given `outputStream` and blocks until done.
- (BOOL)writeAnnotations:(NSArray<__kindof PSPDFAnnotation *> *)annotations toOutputStream:(NSOutputStream *)outputStream documentProvider:(nullable PSPDFDocumentProvider *)documentProvider error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
