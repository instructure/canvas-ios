//
//  PSPDFPKCS12Signer.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFSigner.h"
#import "PSPDFPKCS12.h"

NS_ASSUME_NONNULL_BEGIN

/// Sets `filter` to `Adobe.PPKLite` and `subFilter` to `adbe.pkcs7.detached`.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFPKCS12Signer : PSPDFSigner

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Creates a new PKCS12 signer with the specified display name.
/// The certificate and private key should be contained in p12.
- (instancetype)initWithDisplayName:(NSString *)displayName PKCS12:(PSPDFPKCS12 *)p12 NS_DESIGNATED_INITIALIZER;

/// The signer display name.
@property (nonatomic, copy, readonly) NSString *displayName;

/// The PKCS12 container holding the private key and certificate.
@property (nonatomic, readonly) PSPDFPKCS12 *p12;

/// Private key from the certificate used to produce the signature by encrypting the message digest from the PDF file.
/// (see details https://pspdfkit.com/guides/ios/current/features/digital-signatures/ )
@property (nonatomic, nullable) PSPDFRSAKey *pkey;

/// Signs the element using provided password to open the p12 container (to get the certificate and the private key).
/// Use it only for non-interactive signing process.
- (void)signFormElement:(PSPDFSignatureFormElement *)element usingPassword:(NSString *)password writeTo:(NSString *)path completion:(nullable void (^)(BOOL success, PSPDFDocument *document, NSError *_Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
