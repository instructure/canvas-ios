//
//  PSPDFSigner.h
//  PSPDFKit
//
//  Copyright © 2013-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFDocument.h"
#import "PSPDFDocumentProvider.h"
#import "PSPDFEnvironment.h"
#import "PSPDFSignatureFormElement.h"
#import "PSPDFX509.h"

NS_ASSUME_NONNULL_BEGIN

PSPDF_EXPORT NSString *const PSPDFSignerErrorDomain;

typedef NS_ENUM(NSUInteger, PSPDFSignerError) {
    /// No error during the signing process.
    PSPDFSignerErrorNone = noErr,
    /// A signature form element was not found in the document.
    PSPDFSignerErrorNoFormElementSet = 0x1,
    PSPDFSignerErrorCannotNotCreatePKCS7 = 0x100,
    PSPDFSignerErrorCannotNotAddSignatureToPKCS7 = 0x101,
    PSPDFSignerErrorCannotNotInitPKCS7 = 0x102,
    PSPDFSignerErrorCannotGeneratePKCS7Signature = 0x103,
    PSPDFSignerErrorCannotWritePKCS7Signature = 0x104,
    /// The document was signed correctly but couldn't be verified afterwards.
    PSPDFSignerErrorCannotVerifySignature = 0x105,
    /// The signed document could not be created. Check that you have the necessary permissions for the destination folder.
    PSPDFSignerErrorCannotSaveToDestination = 0x106,
    /// The subfilter type specified to create the signature is not supported.
    PSPDFSignerErrorUnsupportedSubfilterType = 0x107,
    PSPDFSignerErrorCannotFindSignature = 0x108,
    PSPDFSignerErrorCannotSignAttributes = 0x108
} PSPDF_ENUM_AVAILABLE;

/// `PSPDFSigner` is an abstract signer class. Override methods in subclasses as necessary.
PSPDF_CLASS_AVAILABLE @interface PSPDFSigner : NSObject

/// (Override) The PDF filter name to use for this signer. Typical values are
/// `Adobe.PPKLite`, `Entrust.PPKEF`, `CICI.SignIt`, and `VeriSign.PPKVS`.
/// Returns `Adobe.PPKLite` as default value.
@property (nonatomic, readonly) NSString *filter;

/// (Override) The PDF SubFilter entry value. Typical values are
/// `adbe.x509.rsa_sha1`, `adbe.pkcs7.detached`, and `adbe.pkcs7.sha1`.
/// Returns `adbe.pkcs7.detached` as default value.
@property (nonatomic, readonly) NSString *subFilter;

/// (Override) The name displayed in the UI.
@property (nonatomic, readonly) NSString *displayName;

/// (Override) This method requests the signing certificate on demand. If the
/// certificate is for instance password protected or must be fetched over the
/// network, you can push a custom `UIViewController` on the passed navigation
/// controller to display a custom UI while unlocking/fetching the certificate.
/// If you are done, call the done handler with the fetched certificate and/or
/// and error value.
/// `sourceController` should be of type `UINavigationController`.
- (void)requestSigningCertificate:(id)sourceController completionBlock:(nullable void (^)(PSPDFX509 *_Nullable x509, NSError *_Nullable error))completionBlock;

/// (Optional) Signs the passed form element |elem| and writes the signed document
/// to |path|.  Returns YES for |success|, NO otherwise and error |err| is set.
- (void)signFormElement:(PSPDFSignatureFormElement *)element withCertificate:(PSPDFX509 *)x509 writeTo:(NSString *)path completionBlock:(nullable void (^)(BOOL success, PSPDFDocument *_Nullable document, NSError *_Nullable error))completionBlock NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
