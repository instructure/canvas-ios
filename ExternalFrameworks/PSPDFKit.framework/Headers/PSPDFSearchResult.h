//
//  PSPDFSearchResult.h
//  PSPDFKit
//
//  Copyright © 2011-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnnotation.h"
#import "PSPDFModel.h"

@class PSPDFTextBlock, PSPDFDocument;

NS_ASSUME_NONNULL_BEGIN

/// Represents an immutable search result from `PSPDFTextSearch`.
PSPDF_CLASS_AVAILABLE @interface PSPDFSearchResult : PSPDFModel

/// Designated initializer.
- (instancetype)initWithDocumentUID:(NSString *)documentUID pageIndex:(NSUInteger)pageIndex range:(NSRange)range previewText:(NSString *)previewText rangeInPreviewText:(NSRange)rangeInPreviewText selection:(nullable PSPDFTextBlock *)selection annotation:(nullable PSPDFAnnotation *)annotation NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDocument:(PSPDFDocument *)document pageIndex:(NSUInteger)pageIndex range:(NSRange)range previewText:(NSString *)previewText rangeInPreviewText:(NSRange)rangeInPreviewText selection:(nullable PSPDFTextBlock *)selection annotation:(nullable PSPDFAnnotation *)annotation;

/// Referenced page.
@property (nonatomic, readonly) NSUInteger pageIndex;

/// Preview text snippet.
@property (nonatomic, readonly) NSString *previewText;

/// Range of the search result in relation to the previewText.
@property (nonatomic, readonly) NSRange rangeInPreviewText;

/// Range within full page text.
@property (nonatomic, readonly) NSRange range;

/// Text coordinates. Usually the text block contains only one word, unless the search is split across two lines.
/// @note This property is optional.
@property (nonatomic, nullable, readonly) PSPDFTextBlock *selection;

/// If the search result references an annotation, the object is set.
/// @note This property is only set if the search result points to an annotation.
@property (nonatomic, weak, readonly) PSPDFAnnotation *annotation;

/// The UID of the referenced document.
@property (nonatomic, readonly) NSString *documentUID;

/// Referenced document.
@property (nonatomic, weak, readonly) PSPDFDocument *document;

@end

NS_ASSUME_NONNULL_END
