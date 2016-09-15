//
//  PSPDFPKCS12.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFX509.h"
#import "PSPDFRSAKey.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PSPDFPKCS12Error) {
    PSPDFPKCS12ErrorNone = noErr,
    PSPDFPKCS12ErrorCannotOpenFile,
    PSPDFPKCS12ErrorCannotReadFile
} PSPDF_ENUM_AVAILABLE;

PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFPKCS12 : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Inits the object with data from a PKCS12 blob
- (instancetype)initWithData:(NSData *)data NS_DESIGNATED_INITIALIZER;

/// Unlocks the PKCS12 archive and retrieves the certificate and public key
- (void)unlockWithPassword:(NSString *)password done:(nullable void (^)(PSPDFX509 *_Nullable x509, PSPDFRSAKey *_Nullable pk, NSError * _Nullable error))done;

@end

NS_ASSUME_NONNULL_END
