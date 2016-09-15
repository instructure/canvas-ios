//
//  PSPDFLinkAnnotation.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(UInt8, PSPDFLinkAnnotationType) {
    PSPDFLinkAnnotationPage = 0,
    PSPDFLinkAnnotationWebURL,
    PSPDFLinkAnnotationDocument,
    PSPDFLinkAnnotationVideo,
    PSPDFLinkAnnotationYouTube,
    PSPDFLinkAnnotationAudio,
    PSPDFLinkAnnotationImage,
    PSPDFLinkAnnotationBrowser,
    /// Any annotation format that is not recognized is custom. (e.g. tel://)
    PSPDFLinkAnnotationCustom
} PSPDF_ENUM_AVAILABLE;

@class PSPDFAction, PSPDFURLAction, PSPDFGoToAction;

/// The `PSPDFLinkAnnotation` represents both classic PDF page/document/web links, and more types not supported by other PDF readers (video, audio, image, etc)
///
/// PSPDFKit will automatically figure out the type for PDF link annotations loaded from a document, based on the file type. ("mp4" belongs to `PSPDFLinkAnnotationVideo`; a YouTube-URL to `PSPDFLinkAnnotationYouTube`, etc)
///
/// If you create a `PSPDFLinkAnnotation` at runtime, be sure to set the correct type and use the URL parameter for your link.
/// `boundingBox` defines the frame, in PDF space coordinates.
///
/// If you want to customize how links look in the PDF, customize `PSPDFLinkAnnotationView's` properties. There's currently no mapping between `color`/`lineWidth`/etc and the properties of the view. This might change in a future release.
PSPDF_CLASS_AVAILABLE @interface PSPDFLinkAnnotation : PSPDFAnnotation

/// Designated initializer for custom, at runtime created `PSPDFLinkAnnotations`.
- (instancetype)initWithLinkAnnotationType:(PSPDFLinkAnnotationType)linkAnnotationType;

/// Initialize with an action.
- (instancetype)initWithAction:(PSPDFAction *)action;

/// Initialize link annotation with target URL.
- (instancetype)initWithURL:(NSURL *)URL;

/// PSPDFKit addition - will be updated if the `pspdfkit://` protocol is detected.
@property (nonatomic) PSPDFLinkAnnotationType linkType;

/// The associated PDF action that will be executed on tap.
/// Will update the `linkType` when set.
/// @note Only evaluated if `isMultimediaExtension` returns NO.
@property (nonatomic, nullable) PSPDFAction *action;

/// Convenience cast. Will return the URL action if action is of type `PSPDFActionTypeURL`, else nil.
@property (nonatomic, readonly, nullable) PSPDFURLAction *URLAction;

/// Convenience method, gets the URL if `action` is a `PSPDFURLAction`.
@property (nonatomic, copy, readonly, nullable) NSURL *URL;

/// Will be YES if this is a regular link or a multimedia link annotation that should be displayed as link. (e.g. if `isPopover/isModal` is set to yes)
@property (nonatomic, readonly) BOOL showAsLinkView;

/// Returns YES if this link is specially handled by PSPDFKit.
/// Returns true for any linkType >= `PSPDFLinkAnnotationVideo` && linkType <= `PSPDFLinkAnnotationBrowser`.
@property (nonatomic, readonly, getter=isMultimediaExtension) BOOL multimediaExtension;

/// Show or hide controls. Valid for `PSPDFLinkAnnotationVideo`, `PSPDFLinkAnnotationAudio`
/// and `PSPDFLinkAnnotationBrowser`. Defaults to YES.
/// Some controls will add alternative ways to control if this is disabled.
/// e.g. Videos can be paused via touch on the view if this is set to NO.
/// Websites will not receive touches if controlsEnabled is set to NO.
@property (nonatomic) BOOL controlsEnabled;

/// Autoplay video/audio. Only valid for `PSPDFLinkAnnotationVideo` and `PSPDFLinkAnnotationAudio`. Defaults to NO.
@property (nonatomic, getter=isAutoplayEnabled) BOOL autoplayEnabled;

/// Loop media. Only valid for `PSPDFLinkAnnotationVideo` and `PSPDFLinkAnnotationAudio`. Defaults to NO.
@property (nonatomic, getter=isLoopEnabled) BOOL loopEnabled;

/// Allow fullscreen presentation of the media item. Defaults to YES.
@property (nonatomic, getter=isFullscreenEnabled) BOOL fullscreenEnabled;

/// Used for the preview string when the user long-presses on a link annotation.
/// Forwards to `action.localizedDescription`.
@property (nonatomic, readonly, copy) NSString * _Nullable targetString;

@end

NS_ASSUME_NONNULL_END
