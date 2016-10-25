//
//  PSPDFAbstractTextOverlayAnnotation.h
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
#import "PSPDFGlyph.h"

NS_ASSUME_NONNULL_BEGIN

/// Base class for Highlight, Underline, StrikeOut and Squiggly annotations.
PSPDF_CLASS_AVAILABLE @interface PSPDFAbstractTextOverlayAnnotation : PSPDFAnnotation

/// Convenience initializer that creates a text annotation from glyphs.
/// `glyphs` requires to have at least one object, otherwise nil is returned.
/// `pageRotation` is the `rotation` property of the `PSPDFPageInfo`
+ (nullable instancetype)textOverlayAnnotationWithGlyphs:(nullable NSArray<PSPDFGlyph *> *)glyphs pageRotation:(NSInteger)pageRotation;

/// Helper that will query the associated `PSPDFDocument` to get the highlighted content.
/// (Because we actually just write rects, it's not easy to get the underlying text)
@property (nonatomic, readonly) NSString *highlightedString;

@end

/// Mask for all text markups. `PSPDFAnnotationTypeHighlight|PSPDFAnnotationTypeStrikeOut|PSPDFAnnotationTypeUnderline|PSPDFAnnotationTypeSquiggly`
PSPDF_EXPORT const PSPDFAnnotationType PSPDFAnnotationTypeTextMarkup;

NS_ASSUME_NONNULL_END
