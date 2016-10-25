//
//  PSPDFMessageCoordinator.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import <MessageUI/MessageUI.h>
#import "PSPDFDocumentSharingCoordinator.h"

NS_ASSUME_NONNULL_BEGIN

PSPDF_CLASS_AVAILABLE @interface PSPDFMessageCoordinator : PSPDFDocumentSharingCoordinator <MFMessageComposeViewControllerDelegate>

/// Control what data is sent. Defaults to `PSPDFDocumentSharingOptionCurrentPageOnly|PSPDFDocumentSharingOptionPageRange|PSPDFDocumentSharingOptionAllPages|PSPDFDocumentSharingOptionEmbedAnnotations|PSPDFDocumentSharingOptionFlattenAnnotations|PSPDFDocumentSharingOptionOfferMergeFiles`.
///
/// If only one option is set here, no menu will be displayed.
///
/// @note Messages/Mobile Safari in most cases does not display annotations if they are not flattened.
/// (This is a technical limitation and Apple added partial but mostly incomplete support since iOS 7)
@property (nonatomic) PSPDFDocumentSharingOptions sharingOptions;

@end

@interface PSPDFMessageCoordinator (SubclassingHooks)

// Keeps a reference to the mail compose view controller, if visible.
@property (nonatomic, weak, readonly) MFMessageComposeViewController *messageComposeViewController;

@end

NS_ASSUME_NONNULL_END
