//
//  PSPDFHostingAnnotationView.h
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
#import "PSPDFRenderQueue.h"

NS_ASSUME_NONNULL_BEGIN

/// View that will render an annotation.
PSPDF_CLASS_AVAILABLE @interface PSPDFHostingAnnotationView : PSPDFAnnotationView <PSPDFRenderDelegate>

/// Image View that shows the rendered annotation.
@property (nonatomic, readonly) UIImageView *annotationImageView;

@end

NS_ASSUME_NONNULL_END
