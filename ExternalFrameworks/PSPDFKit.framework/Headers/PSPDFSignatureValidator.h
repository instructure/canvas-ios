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

/// Allows to validate digital signatures.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFSignatureValidator : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Initialize with a signature form element.
/// If `formElement` is nil, nil will be returned.
- (instancetype)initWithSignatureFormElement:(PSPDFSignatureFormElement *)formElement NS_DESIGNATED_INITIALIZER;

/// The signature form element.
@property (nonatomic, readonly) PSPDFSignatureFormElement *signatureFormElement;

/**
 *  Starts the digital signature verification process.
 *  If `trustedCertificates` is nil, the default from the shared signature manager is used.
 *
 *  @return nil if OpenSSL is not found.
 */
- (nullable PSPDFSignatureStatus *)verifySignatureWithTrustedCertificates:(nullable NSArray<PSPDFX509 *> *)trustedCertificates error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
