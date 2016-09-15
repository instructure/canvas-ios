//
//  PSPDFTextSelectionView.h
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
#import <AVFoundation/AVFoundation.h>
#import "PSPDFHighlightAnnotation.h"
#import "PSPDFConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFGlyph, PSPDFTextSelectionView, PSPDFImageInfo;

PSPDF_AVAILABLE_DECL @protocol PSPDFTextSelectionViewDelegate <NSObject>

// Called whenever there's a good moment to show/hide the menu based on the selection state of `selectedGlyphs` or `selectedImage`.
- (BOOL)textSelectionView:(PSPDFTextSelectionView *)textSelectionView updateMenuAnimated:(BOOL)animated;

@optional

// Called when text is about to be selected. Return NO to disable text selection.
- (BOOL)textSelectionView:(PSPDFTextSelectionView *)textSelectionView shouldSelectText:(NSString *)text withGlyphs:(NSArray<PSPDFGlyph *> *)glyphs atRect:(CGRect)rect;

// Called after text has been selected.
// Will also be called when text has been deselected. Deselection sometimes cannot be stopped, so the `shouldSelectText:` will be skipped.
- (void)textSelectionView:(PSPDFTextSelectionView *)textSelectionView didSelectText:(NSString *)text withGlyphs:(NSArray<PSPDFGlyph *> *)glyphs atRect:(CGRect)rect;

@end


@class PSPDFTextParser, PSPDFWord, PSPDFImageInfo, PSPDFPageView, PSPDFHighlightAnnotation;
@class PSPDFLinkAnnotation, PSPDFAnnotation, PSPDFNoteAnnotation, PSPDFLoupeView, PSPDFLongPressGestureRecognizer;

/// Handles text and image selection.
/// @note Requires the `PSPDFFeatureMaskTextSelection` feature flag.
/// Don't manually create this class. The initializer here is not exposed.
/// The selection color is determined by the `tintColor` property inherited from `UIView`.
PSPDF_CLASS_AVAILABLE @interface PSPDFTextSelectionView : UIView <AVSpeechSynthesizerDelegate>

/// The text selection delegate.
@property (nonatomic, weak) id <PSPDFTextSelectionViewDelegate> delegate;

/// Currently selected glyphs.
/// @note Use `sortedGlyphs:` to pre-sort your glyphs if you manually set this.
/// @warning This method expects glyphs to be sorted from top->bottom and left->right for performance reasons.
@property (nonatomic, copy, nullable) NSArray<PSPDFGlyph *> *selectedGlyphs;

/// Currently selected text. Set via setting `selectedGlyphs`.
/// Use `discardSelection` to clear.
@property (nonatomic, copy, readonly, nullable) NSString *selectedText;

/// Currently selected image.
@property (nonatomic, nullable) PSPDFImageInfo *selectedImage;

/// The selection alpha value. Defaults to `UIColor.pspdf_selectionAlpha`.
@property (nonatomic) CGFloat selectionAlpha UI_APPEARANCE_SELECTOR;

/// Currently selected text, optimized for searching
@property (nonatomic, copy, readonly, nullable) NSString *trimmedSelectedText;

/// To make it easier to select text, we slightly increase the frame margins. Defaults to 4 pixels.
@property (nonatomic) CGFloat selectionHitTestExtension UI_APPEARANCE_SELECTOR;

/// Rects for the current selection, in view coordinate space.
@property (nonatomic, readonly) CGRect firstLineRect;
@property (nonatomic, readonly) CGRect lastLineRect;
@property (nonatomic, readonly) CGRect selectionRect;

/// Updates the `UIMenuController` if there is a selection.
/// Returns YES if a menu is displayed.
- (BOOL)updateMenuAnimated:(BOOL)animated;

/// Update the selection (text menu).
/// @note `animated` is currently ignored.
- (void)updateSelectionAnimated:(BOOL)animated;

/// Clears the current selection.
- (void)discardSelectionAnimated:(BOOL)animated;

/// Required if glyph frames change.
- (void)clearCache;

/// Currently has a text/image selection?
@property (nonatomic, readonly) BOOL hasSelection;

@end

@interface PSPDFTextSelectionView (Advanced)

/// Will return a new array with sorted glyphs.
/// Use when you manually call `selectedGlyphs`.
- (NSArray<PSPDFGlyph *> *)sortedGlyphs:(NSArray<PSPDFGlyph *> *)glyphs;

@end

@interface PSPDFTextSelectionView (SubclassingHooks)

/// Called when we're adding a new highlight annotation via selected text.
- (void)addHighlightAnnotationWithType:(PSPDFAnnotationType)highlightType;

@end

@interface PSPDFTextSelectionView (Debugging)

/// Debugging feature, visualizes the text blocks.
- (void)showTextFlowData:(BOOL)show animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
