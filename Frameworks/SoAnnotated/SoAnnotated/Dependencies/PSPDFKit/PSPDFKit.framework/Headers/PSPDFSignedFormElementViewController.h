//
//  PSPDFSignedFormElementViewController.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFBaseTableViewController.h"
#import "PSPDFSignatureStatus.h"
#import "PSPDFPresentationContext.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument, PSPDFSignatureFormElement;

@protocol PSPDFSignedFormElementViewControllerDelegate;

PSPDF_CLASS_AVAILABLE @interface PSPDFSignedFormElementViewController : PSPDFBaseTableViewController

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Inits the signed view controller with a signature form element.
/// `element` can not be nil.
- (instancetype)initWithSignatureFormElement:(PSPDFSignatureFormElement *)element NS_DESIGNATED_INITIALIZER;

/// The signature form element the controller was initialized with.
@property (nonatomic, strong, readonly) PSPDFSignatureFormElement *formElement;

/// Verifies the signature of the `formElement` set.
- (nullable PSPDFSignatureStatus *)verifySignature:(NSError **)error;

/// The signed form element view controller delegate
@property (nonatomic, weak) IBOutlet id<PSPDFSignedFormElementViewControllerDelegate> delegate;

@end

PSPDF_AVAILABLE_DECL @protocol PSPDFSignedFormElementViewControllerDelegate <NSObject>

@optional

- (void)signedFormElementViewController:(PSPDFSignedFormElementViewController *)controller removedSignatureFromDocument:(PSPDFDocument *)document;

@end

NS_ASSUME_NONNULL_END
