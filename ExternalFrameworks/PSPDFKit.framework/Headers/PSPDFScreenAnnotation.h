//
//  PSPDFScreenAnnotation.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAssetAnnotation.h"

typedef NS_ENUM(NSUInteger, PSPDFMediaScreenWindowType) {
    PSPDFMediaScreenWindowTypeFloating,
    PSPDFMediaScreenWindowTypeFullscreen,
    PSPDFMediaScreenWindowTypeHidden,
    /// Default value
    PSPDFMediaScreenWindowTypeUseAnnotationRectangle
} PSPDF_ENUM_AVAILABLE;

/// A screen annotation (PDF 1.5) specifies a region of a page upon which media clips may be played. It also serves as an object from which actions can be triggered. PSPDFKit also supports the matching Rendition Actions to control the video play state.
/// @note iOS cannot play all video/audio formats that can be used for PDF.
PSPDF_CLASS_AVAILABLE  @interface PSPDFScreenAnnotation : PSPDFAssetAnnotation

/// Defaults the window type the media should play in.
/// @note only `.UseAnnotationRectangle` and `.Hidden` is currently supported.
@property (nonatomic, readonly) PSPDFMediaScreenWindowType mediaScreenWindowType;

@end
