//
//  PSPDFDocument+DataDetection.h
//  PSPDFKit
//
//  Copyright © 2011-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFDocument.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSPDFDocument (DataDetection)

/// Set this property to allow automatic link detection.
/// Will only add links where no link annotations already exist.
/// Defaults to `PSPDFTextCheckingTypeNone` for performance reasons.
///
/// Set to `PSPDFTextCheckingTypeLink` if you are see URLs in your document that are not clickable.
/// `PSPDFTextCheckingTypeLink` is the default behavior for desktop apps like Adobe Acrobat or Apple Preview.
///
/// @note This requires that you keep the `PSPDFFileAnnotationProvider` in the `annotationManager`.
/// (Default). Needs to be set before the document is being displayed or annotations are accessed!
/// The exact details how detection works are an implementation detail.
/// Apple's Data Detectors are currently used internally.
///
/// @warning Auto-detecting links is useful but might slow down annotation display.
@property (nonatomic) PSPDFTextCheckingType autodetectTextLinkTypes;

/// Iterates over all pages in `pageRange` and creates new annotations for defined types in `textLinkTypes`.
/// Will ignore any text that is already linked with the same URL.
/// It is your responsibility to add the annotations to the document.
///
/// @note To analyze the whole document, use
/// `[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, document.pageCount)]`
///
/// `options` can take a PSPDFObjectsAnnotationsKey of type NSDictionary -> page to prevent auto-fetching for comparison.
///
/// @warning Performs text and annotation extraction and analysis. Might be slow.
/// `progressBlock` might be called from different threads.
/// Ensure you dispatch to the main queue for progress updates.
- (NSDictionary<NSNumber *, NSArray<__kindof PSPDFAnnotation *> *> *)annotationsFromDetectingLinkTypes:(PSPDFTextCheckingType)textLinkTypes pagesInRange:(NSIndexSet *)pageRange options:(nullable NSDictionary<NSString *, NSDictionary<NSNumber *, NSArray<PSPDFAnnotation *> *> *> *)options progress:(nullable void (^)(NSArray<__kindof PSPDFAnnotation *> *annotations, NSUInteger page, BOOL *stop))progressBlock error:(NSError **)error;

@end

@interface PSPDFDocument (TextParser)

/**
 Filters out watermarks from text selection and extraction. Defaults to YES.
 @note Toggling this will invalidate all current text parsers.
 @note Not all watermarks are properly identified by the PDF file. Due to this, PSPDFKit has to try to identify possible
 watermarks. This might accidentially filter out wanted text. If this is the case, please set `isWatermarkFilterEnabled`
 to `NO` and send a support request (https://pspdfkit.com/support/request) with the misbehaving PDF file.
 */
@property (nonatomic, getter=isWatermarkFilterEnabled) BOOL watermarkFilterEnabled;

/// Return a textParser for the specific document page. Thread safe.
- (nullable PSPDFTextParser *)textParserForPageAtIndex:(NSUInteger)pageIndex;

@end

@interface PSPDFDocument (ObjectFinder)

/// Find objects (glyphs, words, images, annotations) at the specified `pdfPoint`.
/// If `options` is nil, we assume `PSPDFObjectsText` and `PSPDFObjectsWordsKey`.
/// @note Unless set otherwise, for points `PSPDFObjectsTestIntersectionKey` is YES automatically.
/// Returns objects in certain key dictionaries .(`PSPDFObjectsGlyphsKey`, etc)
///
/// This method is thread safe.
- (NSDictionary<NSString *, id> *)objectsAtPDFPoint:(CGPoint)pdfPoint pageIndex:(NSUInteger)pageIndex options:(nullable NSDictionary<NSString *, NSNumber *> *)options;

/// Find objects (glyphs, words, images, annotations) at the specified `pdfRect`.
/// If `options` is nil, we assume `PSPDFObjectsGlyphsKey` only.
/// Returns objects in certain key dictionaries (`PSPDFObjectsGlyphsKey`, etc)
///
/// This method is thread safe.
- (NSDictionary<NSString *, id> *)objectsAtPDFRect:(CGRect)pdfRect pageIndex:(NSUInteger)pageIndex options:(nullable NSDictionary<NSString *, NSNumber *> *)options;

/// @name Options for the object finder.

/// Search glyphs.
PSPDF_EXPORT NSString *const PSPDFObjectsGlyphsKey;

/// Always return full `PSPDFWord`s. Implies `PSPDFObjectsTextKey`.
PSPDF_EXPORT NSString *const PSPDFObjectsWordsKey;

/// Include Text.
PSPDF_EXPORT NSString *const PSPDFObjectsTextKey;

/// Include text blocks, sorted after most appropriate.
PSPDF_EXPORT NSString *const PSPDFObjectsTextBlocksKey;

/// Include Image info.
PSPDF_EXPORT NSString *const PSPDFObjectsImagesKey;

/// Output category for annotations.
PSPDF_EXPORT NSString *const PSPDFObjectsAnnotationsKey;

/// Ignore too large text blocks (that are > 90% of a page)
PSPDF_EXPORT NSString *const PSPDFObjectsIgnoreLargeTextBlocksKey;

/// Include annotations of attached type
PSPDF_EXPORT NSString *const PSPDFObjectsAnnotationTypesKey;

/// Special case; used for PSPDFAnnotationTypeNote hit testing.
PSPDF_EXPORT NSString *const PSPDFObjectsAnnotationPageBoundsKey;

/// Special case; Used to correctly hit test zoom-invariant annotations.
PSPDF_EXPORT NSString *const PSPDFObjectsPageZoomLevelKey;

/// Include annotations that are part of a group.
PSPDF_EXPORT NSString *const PSPDFObjectsAnnotationIncludedGroupedKey;

/// Will sort words/annotations (smaller words/annotations first). Use for touch detection.
PSPDF_EXPORT NSString *const PSPDFObjectsSmartSortKey;

/// Will use path-based hit-testing based on the center point if set.
/// All annotations that support path based hit-testing but fail the test will be excluded from the results.
PSPDF_EXPORT NSString *const PSPDFObjectMinDiameterKey;

/// Will look at the text flow and select full sentences, not just what's within the rect.
PSPDF_EXPORT NSString *const PSPDFObjectsTextFlowKey;

/// Will stop after finding the first matching object.
PSPDF_EXPORT NSString *const PSPDFObjectsFindFirstOnlyKey;

/// Only relevant for rect. Will test for intersection instead of objects that are fully included in the pdfRect. Defaults to YES if not set.
PSPDF_EXPORT NSString *const PSPDFObjectsTestIntersectionKey;

@end

NS_ASSUME_NONNULL_END
