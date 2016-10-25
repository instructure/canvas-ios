//
//  PSPDFAnnotationSummarizer.h
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

@class PSPDFDocument;

/// Generates an annotation summary.
PSPDF_CLASS_AVAILABLE @interface PSPDFAnnotationSummarizer : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Initialize the annotation summarizer with a document.
/// @note Will return nil if document is nil.
- (instancetype)initWithDocument:(PSPDFDocument *)document NS_DESIGNATED_INITIALIZER;

/// The attached document.
@property (nonatomic, readonly) PSPDFDocument *document;

/// Generates an annotation summary for all `pages` in the current set document.
- (NSAttributedString *)annotationSummaryForPages:(NSIndexSet *)pages;

@end

NS_ASSUME_NONNULL_END
