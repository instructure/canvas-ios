//
//  PSPDFSignatureManager.h
//  PSPDFKit
//
//  Copyright © 2013-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFSigner, PSPDFX509;

/// Manages signature handlers for digital signature creation. Thread safe.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFSignatureManager : NSObject

/// Returns all registered signers.
@property (nonatomic, readonly) NSArray<PSPDFSigner *> *registeredSigners;

/// Registers a signer.
/// Registering the same signing object more than once will be ignored.
- (void)registerSigner:(PSPDFSigner *)signer;

/// Removes all registered signers.
- (void)clearRegisteredSigners;

/// Returns the trusted certificate stack.
@property (nonatomic, readonly) NSArray<PSPDFX509 *> *trustedCertificates;

/// Adds a trusted certificate to the stack.
- (void)addTrustedCertificate:(PSPDFX509 *)x509;

/// Removes all trusted certificates from the stack.
- (void)clearTrustedCertificates;

@end

NS_ASSUME_NONNULL_END
