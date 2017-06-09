//
//  PSPDFAnnotationToolbarController.h
//  PSPDFKit
//
//  Copyright © 2014-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFFlexibleToolbarContainer.h"
#import "PSPDFFlexibleToolbarController.h"

@class PSPDFAnnotationToolbar;

NS_ASSUME_NONNULL_BEGIN

/// Fired whenever the toolbar visibility changes.
PSPDF_EXPORT NSNotificationName const PSPDFAnnotationToolbarControllerVisibilityDidChangeNotification;

/// Key inside the notification's userInfo.
PSPDF_EXPORT NSString *const PSPDFAnnotationToolbarControllerVisibilityAnimatedKey;

/// Helper for showing/hiding the toolbar on a view controller.
/// Internally manages a `PSPDFFlexibleToolbarContainer`.
PSPDF_CLASS_AVAILABLE @interface PSPDFAnnotationToolbarController : PSPDFFlexibleToolbarController

/// Initialize with an annotation toolbar.
- (instancetype)initWithAnnotationToolbar:(PSPDFAnnotationToolbar *)annotationToolbar;

/// Displayed annotation toolbar.
@property (nonatomic, readonly) PSPDFAnnotationToolbar *annotationToolbar;

/// Optional. Forwards calls from internal delegate handler.
@property (nonatomic, weak) id<PSPDFFlexibleToolbarContainerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
