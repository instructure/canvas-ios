//
//  PSPDFMailCoordinator.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "PSPDFDocumentSharingCoordinator.h"

NS_ASSUME_NONNULL_BEGIN

/// The mail coordinator shows the document sharing sheet and then the mail sheet and manages the flow during that operation.
PSPDF_CLASS_AVAILABLE @interface PSPDFMailCoordinator : PSPDFDocumentSharingCoordinator <MFMailComposeViewControllerDelegate>

@end

@interface PSPDFMailCoordinator (SubclassingHooks)

/// Keeps a reference to the mail compose view controller, if visible.
@property (nonatomic, weak, readonly) MFMailComposeViewController *mailComposeViewController;

/// By default, this simply forwards to the `mailComposeViewController`. Subclass to customize file names or skip elements.
- (void)addAttachmentData:(NSData *)attachment mimeType:(NSString *)mimeType fileName:(NSString *)filename;

@end

NS_ASSUME_NONNULL_END
