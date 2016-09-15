//
//  PSPDFMultimediaAnnotationView.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFLinkAnnotationBaseView.h"
#import "PSPDFMultimediaViewController.h"

@class PSPDFGalleryViewController;

/// Acts as the container view for an image gallery.
/// @note To get a basic image view without the gallery tap handling, simply set `userInteractionEnabled = NO` on this view.
PSPDF_CLASS_AVAILABLE @interface PSPDFMultimediaAnnotationView : PSPDFLinkAnnotationBaseView

/// The multimedia view controller.
@property (nonatomic, readonly) UIViewController<PSPDFMultimediaViewController> *multimediaViewController;

@end
