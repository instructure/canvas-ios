//
//  PSPDFTextBlock.h
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
#import "PSPDFWord.h"

@class PSPDFGlyph;

NS_ASSUME_NONNULL_BEGIN

/// Represents multiple words forming a text block. (e.g. a Column)
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFTextBlock : NSObject <NSCopying, NSSecureCoding>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Designated initializer.
/// Use `CGRectNull` to indicate that the frame should be calculated automatically.
- (instancetype)initWithGlyphs:(NSArray<PSPDFGlyph *> *)glyphs frame:(CGRect)frame pageRotation:(NSUInteger)pageRotation NS_DESIGNATED_INITIALIZER;

/// Convenience initializer.
/// Calculates frame automatically by building the union of all glyph frames.
- (instancetype)initWithGlyphs:(NSArray<PSPDFGlyph *> *)glyphs pageRotation:(NSUInteger)pageRotation;

/// Frame of the text block. Not rotated.
/// @note Use `convertGlyphRectToViewRect:` when converting to view coordinates. 
@property (nonatomic, readonly) CGRect frame;

/// All glyphs of the current text block.
@property (nonatomic, copy, readonly) NSArray<PSPDFGlyph *> *glyphs;

/// All words of the current text block. Evaluated lazily.
@property (nonatomic, copy, readonly) NSArray<PSPDFWord *> *words;

/// Returns the content of the text block (all words merged together)
@property (nonatomic, copy, readonly) NSString *content;

/// The page rotation of the page this word is from.
@property (nonatomic, readonly) NSUInteger pageRotation;

/// Compare to another text block.
- (BOOL)isEqualToTextBlock:(PSPDFTextBlock *)otherBlock;

@end

NS_ASSUME_NONNULL_END
