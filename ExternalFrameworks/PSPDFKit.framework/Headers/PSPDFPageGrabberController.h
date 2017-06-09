//
//  PSPDFPageGrabberController.h
//  PSPDFKit
//
//  Copyright © 2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PSPDFPresentationContext;
@class PSPDFPageGrabber;

/**
 The page grabber controller is used to configure the state of the page grabber.
 It is the owner of the associated page grabber and is responsible for laying it
 out inside the presentation context as well as handling whether it is enabled or
 not.

 @note You should not initialize an instance of this class yourself. Instead you
       should ask an instance of `PSPDFViewController` for a fully configured instance.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFPageGrabberController : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/**
 The page grabber added to the screen that processes touch inputs and shows a representation
 of the current position.
 */
@property (nonatomic, readonly) PSPDFPageGrabber *pageGrabber;

@end

NS_ASSUME_NONNULL_END
