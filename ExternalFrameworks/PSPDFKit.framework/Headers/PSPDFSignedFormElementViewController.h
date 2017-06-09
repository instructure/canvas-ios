//
//  PSPDFSignedFormElementViewController.h
//  PSPDFKit
//
//  Copyright © 2013-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFBaseTableViewController.h"
#import "PSPDFPresentationContext.h"
#import "PSPDFSignatureStatus.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument, PSPDFSignatureFormElement, PSPDFX509;

@protocol PSPDFSignedFormElementViewControllerDelegate;

/**
 *  Shows the current signature state of a PSPDFSignatureFormElement.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFSignedFormElementViewController : PSPDFBaseTableViewController

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Inits the signed view controller with a signature form element.
/// `element` can not be nil.
- (instancetype)initWithSignatureFormElement:(PSPDFSignatureFormElement *)element NS_DESIGNATED_INITIALIZER;

/// The signature form element the controller was initialized with.
@property (nonatomic, strong, readonly) PSPDFSignatureFormElement *formElement;

/**
 *  Verifies the signature of the `formElement` set.
 *  @param trustedCertificates Optional. Uses the default shared state if not set.
 */
- (nullable PSPDFSignatureStatus *)verifySignatureWithTrustedCertificates:(nullable NSArray<PSPDFX509 *> *)trustedCertificates error:(NSError **)error;

/// The signed form element view controller delegate
@property (nonatomic, weak) IBOutlet id<PSPDFSignedFormElementViewControllerDelegate> delegate;

@end

PSPDF_AVAILABLE_DECL @protocol PSPDFSignedFormElementViewControllerDelegate<NSObject>

@optional

/// Called when a signature was successfully removed from the document.
- (void)signedFormElementViewController:(PSPDFSignedFormElementViewController *)controller removedSignatureFromDocument:(PSPDFDocument *)document;

@end

NS_ASSUME_NONNULL_END
