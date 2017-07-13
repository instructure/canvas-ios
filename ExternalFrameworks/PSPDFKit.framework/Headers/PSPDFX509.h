//
//  PSPDFX509.h
//  PSPDFKit
//
//  Copyright © 2013-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFRSAKey.h"

#import "PSPDFMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// This class represents a X.509 certificate.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFX509 : NSObject

/// The Adobe certification authority.
+ (instancetype)adobeCA;

/// Initializes the certificate from certificate data.
+ (nullable NSArray<PSPDFX509 *> *)certificatesFromPKCS7Data:(NSData *)data error:(NSError **)error;

PSPDF_EMPTY_INIT_UNAVAILABLE

/// The public key.
@property (nonatomic, readonly) PSPDFRSAKey *publicKey;

/// The CN entry.
@property (nonatomic, copy, readonly, nullable) NSString *commonName;

@end

NS_ASSUME_NONNULL_END
