//
//  PSPDFRenderManager.h
//  PSPDFKit
//
//  Copyright © 2011-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFMacros.h"

NS_ASSUME_NONNULL_BEGIN

/**
 This notification is triggered if something happens that changes the way a page looks.

 The user info dictionary of this notification always contains the key `PSPDFRenderManagerRenderResultChangedDocumentKey`
 which contains the document that changed and optionally `PSPDFRenderManagerRenderResultChangedPagesKey`
 which contains an index set of the pages that changed within this document.

 If a document was changed e.g. by adding or removing an annotation, this notification
 tells you that the render engine and the cache have been updated and scheduling
 a new render task is guaranteed to return the new state of the document.

 In other words: If you constantly want to show up to date data, observe this notification
 and request a new image when this notification is posted.

 @note This notification is posted on an arbitraty queue. If you need to react on
 this on the main queue, you need to switch to the main queue yourself.
 */
PSPDF_EXPORT NSNotificationName const PSPDFRenderManagerRenderResultDidChangeNotification;

/**
 The key of a `PSPDFRenderManagerRenderResultDidChangeNotification` userInfo's dictionary,
 containing the `PSPDFDocument` that was changed.
 */
PSPDF_EXPORT NSString *const PSPDFRenderManagerRenderResultChangedDocumentKey;

/**
 The key of a `PSPDFRenderManagerRenderResultDidChangeNotification` userInfo's dictionary,
 containing an `NSIndexSet` with all the relevant pages. If the entry for this
 key in the user info dictionary is `nil`, the whole document should be treated as
 changed.
 */
PSPDF_EXPORT NSString *const PSPDFRenderManagerRenderResultChangedPagesKey;

/// The `PSPDFPageInfo` object containing page info.
PSPDF_EXPORT NSString *const PSPDFPageRendererPageInfoKey;

@class PSPDFAnnotation, PSPDFRenderQueue, PSPDFDocumentProvider;

/// Abstract interface for a page renderer.
PSPDF_AVAILABLE_DECL @protocol PSPDFPageRenderer<NSObject>

/// Currently `options` contains `PSPDFPageRendererPageInfoKey`.
- (BOOL)drawPageIndex:(NSUInteger)pageIndex inContext:(CGContextRef)context documentProvider:(PSPDFDocumentProvider *)documentProvider withOptions:(nullable NSDictionary<NSString *, id> *)options error:(NSError **)error;

/// Renders annotation appearance streams.
/// @return NO if rendering failed.
- (BOOL)renderAppearanceStream:(PSPDFAnnotation *)annotation inContext:(CGContextRef)context withOptions:(nullable NSDictionary<NSString *, id> *)options error:(NSError **)error;

@end

@class PSPDFPageInfo;

typedef NS_ENUM(NSUInteger, PSPDFRenderType) {
    /// Renders a single page.
    PSPDFRenderTypePage,
    /// Exports or transforms a document
    PSPDFRenderTypeProcessor,
    /// Useful to apply settings to all render types.
    PSPDFRenderTypeAll = NSUIntegerMax
} PSPDF_ENUM_AVAILABLE;

typedef NS_OPTIONS(NSUInteger, PSPDFRenderFilter) {
    /// If set, a grayscale filter will be applied.
    PSPDFRenderFilterGrayscale = 1 << 0,
    /// If set and the `PSPDFRenderInvertedKey` key is present, the inverted mode (a.k.a. night mode)
    /// will be rendered color correct.
    PSPDFRenderFilterColorCorrectInverted = 1 << 1,
    /// If set, a sepia filter will be applied.
    PSPDFRenderFilterSepia = 1 << 2
} PSPDF_ENUM_AVAILABLE;

/// Multiplies a color used to color a page.
PSPDF_EXPORT NSString *const PSPDFRenderPageColorKey PSPDF_DEPRECATED_IOS("6.0", "Use PSPDFRenderOptionPageColorKey instead.");

/// Inverts the rendering output. Defaults to `@(NO)`.
PSPDF_EXPORT NSString *const PSPDFRenderInvertedKey PSPDF_DEPRECATED_IOS("6.0", "Use PSPDFRenderOptionInvertedKey instead.");

/// Filters to be applied. Defaults to 0. Filters will increase rendering time.
PSPDF_EXPORT NSString *const PSPDFRenderFiltersKey PSPDF_DEPRECATED_IOS("6.0", "Use PSPDFRenderOptionFiltersKey instead.");

/// Set custom interpolation quality. Defaults to `kCGInterpolationHigh`.
PSPDF_EXPORT NSString *const PSPDFRenderInterpolationQualityKey PSPDF_DEPRECATED_IOS("6.0", "Use PSPDFRenderOptionInterpolationQualityKey instead.");

/// Set to YES to NOT draw page content. (Use to just draw an annotation)
PSPDF_EXPORT NSString *const PSPDFRenderSkipPageContentKey PSPDF_DEPRECATED_IOS("6.0", "Use PSPDFRenderOptionSkipPageContentKey instead.");

/// Set to YES to render annotations that have isOverlay = YES set.
PSPDF_EXPORT NSString *const PSPDFRenderOverlayAnnotationsKey PSPDF_DEPRECATED_IOS("6.0", "Use PSPDFRenderOptionOverlayAnnotationsKey instead.");

/// Skip rendering of any annotations that are in this array.
PSPDF_EXPORT NSString *const PSPDFRenderSkipAnnotationArrayKey PSPDF_DEPRECATED_IOS("6.0", "Use PSPDFRenderOptionSkipAnnotationArrayKey instead.");

/// If YES, will draw outside of page area.
PSPDF_EXPORT NSString *const PSPDFRenderIgnorePageClipKey PSPDF_DEPRECATED_IOS("6.0", "Use PSPDFRenderOptionIgnorePageClipKey instead.");

/// Enabled/Disables antialiasing. Defaults to YES.
PSPDF_EXPORT NSString *const PSPDFRenderAllowAntiAliasingKey PSPDF_DEPRECATED_IOS("6.0", "Use PSPDFRenderOptionAllowAntiAliasingKey instead.");

/// Allows custom render color. Default is white.
PSPDF_EXPORT NSString *const PSPDFRenderBackgroundFillColorKey PSPDF_DEPRECATED_IOS("6.0", "Use PSPDFRenderOptionBackgroundFillColorKey instead.");

/// Sets the interactive fill color, which will override the fill color for all newly
/// rendered form elements that are editable.
///
/// The interactive fill color is used if a form element is editable by the user to
/// indicate that the user can interact with this form element.
///
/// If this value is set, it will always be used if the element is editable and the
/// `fillColor` specified by the PDF is ignored. Remove this key to use the fill color
/// specified in the PDF.
///
/// Defaults to a non-nil, light blue color.
PSPDF_EXPORT NSString *const PSPDFRenderInteractiveFormFillColorKey PSPDF_DEPRECATED_IOS("6.0", "Use PSPDFRenderOptionInteractiveFormFillColorKey instead.");

/// Allow custom content rendering after the PDF. `PSPDFRenderDrawBlock`.
PSPDF_EXPORT NSString *const PSPDFRenderDrawBlockKey PSPDF_DEPRECATED_IOS("6.0", "Use PSPDFRenderOptionDrawBlockKey instead.");

/// The PDF render manager coordinates the PDF renderer used.
PSPDF_AVAILABLE_DECL @protocol PSPDFRenderManager<NSObject>

/// Setup the graphics context to the current PDF.
- (void)setupGraphicsContext:(CGContextRef)context rectangle:(CGRect)displayRectangle pageInfo:(PSPDFPageInfo *)pageInfo;

/// The render queue that manages render jobs.
@property (nonatomic, readonly) PSPDFRenderQueue *renderQueue;

@end

NS_ASSUME_NONNULL_END
