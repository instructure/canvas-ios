//
//  PSPDFOpenInCoordinator.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import "PSPDFDocumentSharingCoordinator.h"

NS_ASSUME_NONNULL_BEGIN

/// These notifications represent a small subset of `UIDocumentInteractionControllerDelegate` (but the most important ones)
/// To get all callbacks, subclass `PSPDFOpenInCoordinator` and implement the callbacks (and also call super)
PSPDF_EXPORT NSString *const PSPDFDocumentInteractionControllerWillBeginSendingToApplicationNotification;
PSPDF_EXPORT NSString *const PSPDFDocumentInteractionControllerDidEndSendingToApplicationNotification;

PSPDF_CLASS_AVAILABLE @interface PSPDFOpenInCoordinator : PSPDFDocumentSharingCoordinator <UIDocumentInteractionControllerDelegate>
@end

@interface PSPDFOpenInCoordinator (SubclassingHooks)

/// Instance of the document interaction controller while visible.
@property (nonatomic, weak, readonly) UIDocumentInteractionController *documentInteractionController;

@end

NS_ASSUME_NONNULL_END
