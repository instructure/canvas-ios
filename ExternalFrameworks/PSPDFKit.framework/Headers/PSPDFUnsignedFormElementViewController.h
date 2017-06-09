//
//  PSPDFUnsignedFormElementViewController.h
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

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument, PSPDFSignatureFormElement, PSPDFSigner;
@protocol PSPDFUnsignedFormElementViewControllerDelegate;

/// Displays a view controller to offer digital signing on a signature form element.
PSPDF_CLASS_AVAILABLE @interface PSPDFUnsignedFormElementViewController : PSPDFBaseTableViewController

PSPDF_EMPTY_INIT_UNAVAILABLE

/**
 *  Initializes the view controller with a signature form element.
 *  @param element The signature form element. Cannot be nil.
 *  @param registeredSigners Optional. Will use the default shared singleton state if nil.
 */
- (instancetype)initWithSignatureFormElement:(PSPDFSignatureFormElement *)element registeredSigners:(nullable NSArray<PSPDFSigner *> *)registeredSigners NS_DESIGNATED_INITIALIZER;

/// The signature form element the controller was initialized with
@property (nonatomic, strong, readonly) PSPDFSignatureFormElement *formElement;

/// The unsigned form element view controller delegate.
@property (nonatomic, weak) IBOutlet id<PSPDFUnsignedFormElementViewControllerDelegate> delegate;

/// Whether or not this field allows ink signatures
@property (nonatomic) BOOL allowInkSignature;

@end

/// Delegate for signature status.
PSPDF_AVAILABLE_DECL @protocol PSPDFUnsignedFormElementViewControllerDelegate<NSObject>

- (void)unsignedFormElementViewControllerRequestsInkSignature:(PSPDFUnsignedFormElementViewController *)controller;

@optional

- (void)unsignedFormElementViewController:(PSPDFUnsignedFormElementViewController *)controller signedDocument:(PSPDFDocument *)document error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
