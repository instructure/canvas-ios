//
//  PSPDFAnnotationStateManager+StylusSupport.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnnotationStateManager.h"
#import "PSPDFStylusDriverDelegate.h"

NS_ASSUME_NONNULL_BEGIN

PSPDF_CLASS_AVAILABLE @interface PSPDFAnnotationStateManagerStylusSupport : NSObject <PSPDFStylusDriverDelegate>

/// The `PSPDFAnnotationStateManager` instance used by this class.
@property (nonatomic, weak, readonly) PSPDFAnnotationStateManager *annotationStateManager;

@end

@interface PSPDFAnnotationStateManager (StylusSupport)

/// Accessing this class will enable stylus support.
@property (nonatomic, readonly) PSPDFAnnotationStateManagerStylusSupport *stylusSupport;

/// Provides a pre-created stylus button. Accessing this button will enable stylus support.
@property (nonatomic, readonly) PSPDFToolbarButton *stylusStatusButton;

@end

NS_ASSUME_NONNULL_END
