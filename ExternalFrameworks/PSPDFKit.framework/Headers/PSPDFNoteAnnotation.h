//
//  PSPDFNoteAnnotation.h
//  PSPDFKit
//
//  Copyright © 2012-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

/// PDF Note (Text) Annotation.
/// @note Note annotations are rendered as fixed size; much like how Adobe Acrobat renders them.
/// PSPDFKit will always render note annotations at a fixed size of 32x32pt.
/// We recommend that you set the `boundingBox` to the same value.
PSPDF_CLASS_AVAILABLE @interface PSPDFNoteAnnotation : PSPDFAnnotation

/// Initialize with text contents.
- (instancetype)initWithContents:(NSString *)contents;

/// Note Icon name (see PSPDFKit.bundle for available icon names)
/// If set to zero, it will return to the default "Comment".
@property (nonatomic, copy, null_resettable) NSString *iconName;

@end

@interface PSPDFNoteAnnotation (SubclassingHooks)

/// Image that is rendered.
@property (nonatomic, readonly, nullable) UIImage *renderAnnotationIcon;

/// Called to render the note image.
- (void)drawImageInContext:(CGContextRef)context boundingBox:(CGRect)boundingBox options:(nullable NSDictionary<NSString *, id> *)options;

/// If the note annotation is rendered as text, this method returns the bounding box to contain the text.
/// This is used for flattening a note annotation.
@property (nonatomic, readonly) CGRect boundingBoxIfRenderedAsText;

@end

NS_ASSUME_NONNULL_END
