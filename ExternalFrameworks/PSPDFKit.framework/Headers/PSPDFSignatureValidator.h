//
//  PSPDFSignatureValidator.h
//  PSPDFKit
//
//  Copyright © 2014-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFSignatureFormElement, PSPDFSignatureStatus, PSPDFX509;

/**
 * This class validates digital signatures in a PDF document.
 * Validation consists of two steps: Checking that the signature integrity is correct (that is, the document was not modified after it was signed), and
 * ensuring that the chain of certificates contained in the signature is trusted.
 */
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFSignatureValidator : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/**
 * Initializes a `PSPDFSignatureValidator` with a signature form element.
 * If `formElement` is nil, nil will be returned.
 */
- (instancetype)initWithSignatureFormElement:(PSPDFSignatureFormElement *)formElement NS_DESIGNATED_INITIALIZER;

/// The signature form element.
@property (nonatomic, readonly) PSPDFSignatureFormElement *signatureFormElement;

/**
 *  Starts the digital signature verification process.
 *  If `trustedCertificates` is nil, the default from the shared signature manager is used.
 *
 *  @return nil if signature not found.
 */
- (nullable PSPDFSignatureStatus *)verifySignatureWithTrustedCertificates:(nullable NSArray<PSPDFX509 *> *)trustedCertificates error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
