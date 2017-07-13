//
//  PSPDFRenderRequest.h
//  PSPDFKit
//
//  Copyright © 2016-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFMacros.h"

NS_ASSUME_NONNULL_BEGIN

// No support for macOS yet (CIFilter behaves differently there)
#define PSPDF_SUPPORTS_CIFILTER (TARGET_OS_IOS || TARGET_OS_TV)

typedef NSString *PSPDFRenderOption NS_EXTENSIBLE_STRING_ENUM;

/// Changes the rendering to preserve the aspect ratio of the image.
PSPDF_EXPORT PSPDFRenderOption const PSPDFRenderOptionPreserveAspectRatioKey;

/// Controls whether the image is forced to render with a scale of 1.0.
PSPDF_EXPORT PSPDFRenderOption const PSPDFRenderOptionIgnoreDisplaySettingsKey;

/// Multiplies a color used to color a page.
PSPDF_EXPORT PSPDFRenderOption const PSPDFRenderOptionPageColorKey;

/// Inverts the rendering output. Defaults to `@(NO)`.
PSPDF_EXPORT PSPDFRenderOption const PSPDFRenderOptionInvertedKey;

/// Filters to be applied. Defaults to 0. Filters will increase rendering time.
PSPDF_EXPORT PSPDFRenderOption const PSPDFRenderOptionFiltersKey;

/// Set custom interpolation quality. Defaults to `kCGInterpolationHigh`.
PSPDF_EXPORT PSPDFRenderOption const PSPDFRenderOptionInterpolationQualityKey;

/// Set to YES to NOT draw page content. (Use to just draw an annotation)
PSPDF_EXPORT PSPDFRenderOption const PSPDFRenderOptionSkipPageContentKey;

/// Set to YES to render annotations that have isOverlay = YES set.
PSPDF_EXPORT PSPDFRenderOption const PSPDFRenderOptionOverlayAnnotationsKey;

/// Skip rendering of any annotations that are in this array.
PSPDF_EXPORT PSPDFRenderOption const PSPDFRenderOptionSkipAnnotationArrayKey;

/// If YES, will draw outside of page area.
PSPDF_EXPORT PSPDFRenderOption const PSPDFRenderOptionIgnorePageClipKey;

/// Enabled/Disables antialiasing. Defaults to YES.
PSPDF_EXPORT PSPDFRenderOption const PSPDFRenderOptionAllowAntiAliasingKey;

/// Allows custom render color. Default is white.
PSPDF_EXPORT PSPDFRenderOption const PSPDFRenderOptionBackgroundFillColorKey;

/**
 Allows to control if native text rendering via CoreGraphics should be used.
 Native text rendering usually yields better results but is slower.

 @note This key defaults to YES unless explicitely set to no.
 */
PSPDF_EXPORT PSPDFRenderOption const PSPDFRenderOptionTextRenderingUseCoreGraphicsKey;

/**
 Control if ClearType is used for text rendering. Only works if
 `PSPDFRenderOptionTextRenderingUseCoreGraphicsKey` is set to NO.

 @note This key defaults to YES unless explicitely set to no.
 */
PSPDF_EXPORT PSPDFRenderOption const PSPDFRenderOptionTextRenderingClearTypeEnabledKey;

/**
 Sets the interactive fill color, which will override the fill color for all newly
 rendered form elements that are editable.

 The interactive fill color is used if a form element is editable by the user to
 indicate that the user can interact with this form element.

 If this value is set, it will always be used if the element is editable and the
 `fillColor` specified by the PDF is ignored. Remove this key to use the fill color
 specified in the PDF.

 Defaults to a non-nil, light blue color.
 */
PSPDF_EXPORT PSPDFRenderOption const PSPDFRenderOptionInteractiveFormFillColorKey;

/// Allow custom content rendering after the PDF. The value for this key needs to be of type `PSPDFRenderDrawBlock`.
PSPDF_EXPORT PSPDFRenderOption const PSPDFRenderOptionDrawBlockKey;

#if PSPDF_SUPPORTS_CIFILTER
/**
 `CIFilter` that are applied to the rendered image before it is returned from the
 render pipeline.

 The value of this key can either be a `CIFilter` instance or an array of `CIFilter`
 instances.
 */
PSPDF_EXPORT PSPDFRenderOption const PSPDFRenderOptionCIFilterKey;
#endif

/**
 The render request cache policy controls if and how the request, once scheduled,
 access the cache.
 */
typedef NS_ENUM(NSInteger, PSPDFRenderRequestCachePolicy) {
    /// The default policy that works best for the given platform and device.
    PSPDFRenderRequestCachePolicyDefault = 0,

    /// The request will always trigger a rendering as it ignores data from the cache.
    PSPDFRenderRequestCachePolicyReloadIgnoringCacheData,

    /// The request will first check the cache for data and request a rendering if there was no cache hit for that request.
    PSPDFRenderRequestCachePolicyReturnCacheDataElseLoad,

    /// The request will check the cache for data and return nothing if the cache did not contain an image.
    PSPDFRenderRequestCachePolicyReturnCacheDataDontLoad,

    PSPDFRenderRequestCachePolicyReloadIgnoreingCacheData PSPDF_DEPRECATED_IOS(6.7, "Renamed to PSPDFRenderRequestCachePolicyReloadIgnoringCacheData") = PSPDFRenderRequestCachePolicyReloadIgnoringCacheData,
} PSPDF_ENUM_AVAILABLE;

typedef void (^PSPDFRenderDrawBlock)(CGContextRef context, NSUInteger page, CGRect cropBox, NSUInteger rotation, NSDictionary<NSString *, id> *_Nullable options);

@class PSPDFDocument, PSPDFAnnotation;

/**
 A render request specifies the exact parameters of how an image should be rendered.
 You use it in order to configure a `PSPDFRenderTask` which can then be passend
 to a `PSPDFRenderQueue` in order to fulfill the task.

 To create a new render request you usually create a `PSPDFMutableRenderRequest`
 and set the properties you need.

 # Thread safety

 PSPDFRenderRequest is not thread safe, you should never modify a mutable render
 request from multiple threads nor should you modify a mutable render request while
 reading data from it on a different thread.

 As soon as you hand over ownership of a render request to the render engine, it
 is copied, so that you do not need to worry about thread safety between your render
 requests and the ones the render engine holds.

 @see PSPDFRenderTask
 @see PSPDFMutableRenderRequest
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFRenderRequest : NSObject<NSCopying, NSMutableCopying>

PSPDF_EMPTY_INIT_UNAVAILABLE;

/**
 Initializes a new render request for rendering images of pages from the passed
 in document.

 @param document The document this request should render images from.

 @return A newly initialized render request.
 */
- (instancetype)initWithDocument:(PSPDFDocument *)document NS_DESIGNATED_INITIALIZER;

/**
 The document that this object is requesting an image rendering from.
 */
@property (nonatomic, readonly) PSPDFDocument *document;

/**
 The index of the page that should be rendered from the document.

 This defaults to the first page.
 */
@property (nonatomic, readonly) NSUInteger pageIndex;

/**
 The requested size of the rendered image.

 @note The actual image might be of a different size as the rendered image will
       have the aspect ratio of `pdfRect` or the full pdf page, in case you don't
       specify a `pdfRect`. The resulting image will be rendered aspect-fit inside
       the requested `imageSize`, meaning in the resulting image at least one axis
       will be equal to the requested one and the other might be smaller.
 */
@property (nonatomic, readonly) CGSize imageSize;

/**
 The rect in pdf coordinates defining the area of the page that should be rendered.

 The rect that is described here is rendered into the given `renderSize`.

 Defaults to `CGRectNull`, which means the full page is rendered.
 */
@property (nonatomic, readonly) CGRect pdfRect;

/**
 The scale factor the image should be rendered in.

 Defaults to 0.0 which will use the main screen's scale factor on iOS and on macOS
 will always use 1.0.
 */
@property (nonatomic, readonly) CGFloat imageScale;

/**
 Contains the annotations to be rendered in the image.

 If this property contains an empty array, no annotations will be rendered in the
 image. If this property is nil, all annotations will be rendered in the image
 (the default).
 */
@property (nonatomic, copy, readonly, nullable) NSArray<__kindof PSPDFAnnotation *> *annotations;

/**
 Contains additional render options that should be used when rendering the image.
 */
@property (nonatomic, copy, readonly) NSDictionary<PSPDFRenderOption, id> *options;

/**
 The user info dictionary can contain any arbitraty user info that is just passed
 through. Content in this dictionary is not touched at all and has no impact on
 the render result.

 @note Two render requests with different user info content can still be equal.
 */
@property (nonatomic, copy, readonly) NSDictionary *userInfo;

/**
 Determines the cache policy that is used to fullfill the request. If the policy
 is set to `PSPDFRenderRequestCachePolicyDefault` (the default value) the request
 will try to fullfill the request as efficient as possible.
 */
@property (nonatomic, readonly) PSPDFRenderRequestCachePolicy cachePolicy;

/**
 Compares the receiver and the passed in render request for equality.

 @param renderRequest The request to compare the receiver to.

 @return `YES` if both requests are equal, `NO` otherwise.
 */
- (BOOL)isEqualRenderRequest:(PSPDFRenderRequest *)renderRequest;

@end

/**
 The mutual version of a render request can be used to configure it so that it
 matches the desired request.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFMutableRenderRequest : PSPDFRenderRequest

/**
 The document that this object is requesting an image rendering from.
 */
@property (nonatomic) PSPDFDocument *document;

/**
 The index of the page that should be rendered from the document.
 */
@property (nonatomic) NSUInteger pageIndex;

/**
 The requested size of the rendered image.

 @note The actual image might be of a different size as the rendered image will
 have the aspect ratio of `pdfRect` or the full pdf page, in case you don't
 specify a `pdfRect`. The resulting image will be rendered aspect-fit inside
 the requested `imageSize`, meaning in the resulting image at least one axis
 will be equal to the requested one and the other might be smaller.
 */
@property (nonatomic) CGSize imageSize;

/**
 The rect in pdf coordinates defining the area of the page that should be rendered.

 The rect that is described here is rendered as aspect fit into the given `renderSize`.

 Defaults to `CGRectNull`, which means the full page is rendered.
 */
@property (nonatomic) CGRect pdfRect;

/**
 The scale factor the image should be rendered in.

 Defaults to 0.0 which will use the main screen's scale factor on iOS and on macOS
 will always use 1.0.
 */
@property (nonatomic) CGFloat imageScale;

/**
 Contains the annotations to be rendered in the image.

 If this property contains an empty array, no annotations will be rendered in the
 image. If this property is nil, all annotations will be rendered in the image
 (the default).
 */
@property (nonatomic, copy, nullable) NSArray<__kindof PSPDFAnnotation *> *annotations;

/**
 Contains additional render options that should be used when rendering the image.
 */
@property (nonatomic, copy) NSDictionary<NSString *, id> *options;

/**
 Determines the cache policy that is used to fullfill the request. If the policy
 is set to `PSPDFRenderRequestCachePolicyDefault` (the default value) the request
 will try to fullfill the request as efficient as possible.
 */
@property (nonatomic) PSPDFRenderRequestCachePolicy cachePolicy;

/**
 The user info dictionary can contain any arbitraty user info that is just passed
 through. Content in this dictionary is not touched at all and has no impact on
 the render result.

 @note Two render requests with different user info content can still be equal.
 */
@property (nonatomic, copy) NSDictionary *userInfo;

@end

NS_ASSUME_NONNULL_END
