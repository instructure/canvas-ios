//
//  PSPDFNoteAnnotationView.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnnotationView.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFNoteAnnotation;

/// Note annotations are handled as subviews to be draggable.
PSPDF_CLASS_AVAILABLE @interface PSPDFNoteAnnotationView : PSPDFAnnotationView

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Designated initializer.
- (instancetype)initWithAnnotation:(PSPDFAnnotation *)noteAnnotation;

/// Image of the rendered annotation.
@property (nonatomic, nullable) UIImageView *annotationImageView;

@end

@interface PSPDFNoteAnnotationView (SubclassingHooks)

/// Override to customize the image tinting.
@property (nonatomic, readonly, nullable) UIImage *renderNoteImage;

/// Force image re-render.
- (void)updateImageAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
