//
//  PSPDFX509.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFRSAKey.h"
#import "PSPDFMacros.h"

NS_ASSUME_NONNULL_BEGIN

typedef void *OPENSSL_X509;

PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFX509 : NSObject

/// The Adobe certification authority.
+ (instancetype)adobeCA;

/// Initializes the certificate from certificate data.
+ (nullable NSArray<PSPDFX509 *> *)certificatesFromPKCS7Data:(NSData *)data error:(NSError **)error;

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Initializes the certificate with an OpenSSL X509 type.
- (instancetype)initWithX509:(OPENSSL_X509)x509 NS_DESIGNATED_INITIALIZER;

/// The underlying OpenSSL X509 object.
@property (nonatomic, readonly) OPENSSL_X509 cert;

/// The public key.
@property (nonatomic, readonly) PSPDFRSAKey *publicKey;

/// The CN entry.
@property (nonatomic, copy, readonly) NSString *commonName;

@end

NS_ASSUME_NONNULL_END
