//
//  PSPDFTextParser.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocumentProvider, PSPDFGlyph, PSPDFImageInfo, PSPDFTextBlock, PSPDFWord;

/// Parses the text and glyph data of a single PDF page.
/// @note Don't instantiate this class directly, but get an instance from `PSPDFDocumentProvider`
/// Properties are evaluated lazily and then cached.
PSPDF_CLASS_AVAILABLE @interface PSPDFTextParser : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// The complete page text, including extrapolated spaces and newline characters.
@property (nonatomic, copy, readonly) NSString *text;

/// Complete list of `PSPDFGlyph` objects. Corresponds to the text.
@property (nonatomic, copy, readonly) NSArray<PSPDFGlyph *> *glyphs;

/// List of detected words.
@property (nonatomic, copy, readonly) NSArray<PSPDFWord *> *words;

/// List of detected text blocks.
@property (nonatomic, copy, readonly) NSArray<PSPDFTextBlock *> *textBlocks;

/// List of detected images.
@property (nonatomic, copy, readonly) NSArray<PSPDFImageInfo *> *images;

/// Associated document provider.
@property (nonatomic, weak, readonly) PSPDFDocumentProvider *documentProvider;

/// Page relative to the `documentProvider`.
@property (nonatomic, readonly) NSUInteger page;

/// Uses glyphs to return the corresponding page text, including newlines and spaces.
- (NSString *)textWithGlyphs:(NSArray<PSPDFGlyph *> *)glyphs;

- (NSArray<PSPDFGlyph *> *)glyphsInRange:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
