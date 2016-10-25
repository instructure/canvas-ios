//
//  PSPDFWord.h
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

@class PSPDFGlyph;

/// Represents a word. Formed out of (usually) multiple glyphs.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFWord : NSObject <NSCopying, NSSecureCoding>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Initialize with glyphs (`PSPDFGlyph`).
/// As an optimizations, only the first and last glyph will be used for frame calculations.
- (instancetype)initWithGlyphs:(NSArray<PSPDFGlyph *> *)wordGlyphs pageRotation:(NSUInteger)pageRotation NS_DESIGNATED_INITIALIZER;

/// Initialize with word frame.
- (instancetype)initWithFrame:(CGRect)wordFrame pageRotation:(NSUInteger)pageRotation NS_DESIGNATED_INITIALIZER;

/// Returns the content of the word (all glyphs merged together)
@property (nonatomic, readonly) NSString *stringValue;

/// All glyphs merged together in the smallest possible bounding box.
@property (nonatomic) CGRect frame;

/// All `PSPDFGlyph` objects.
/// Frame will be recalculated when glyphs are set.
@property (nonatomic, copy) NSArray<PSPDFGlyph *> *glyphs;

/// Set to YES if this is the last word on a textBlock.
@property (nonatomic) BOOL lineBreaker;

/// The page rotation of the page this word is from.
@property (nonatomic, readonly) NSUInteger pageRotation;

@end

NS_ASSUME_NONNULL_END
