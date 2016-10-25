//
//  PSPDFAESCryptoInputStream.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFCryptoInputStream.h"

NS_ASSUME_NONNULL_BEGIN

/// AES encryption, RNCryptor data format  (see https://github.com/RNCryptor/RNCryptor-Spec/blob/master/RNCryptor-Spec-v3.md )
PSPDF_CLASS_AVAILABLE @interface PSPDFAESCryptoInputStream : PSPDFCryptoInputStream

/// Designated initializer with the passphrase. The encryption key salt and HMAC key salt will be loaded from the file header.
- (instancetype)initWithInputStream:(NSInputStream *)stream passphrase:(NSString *)passphrase;

/// On the first call the provided data buffer size must be at least 98 bytes (82 bytes if original data were < 16 bytes) due to the RNCryptor data format,
/// otherwise an exception will be thrown.
- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len;

/// Use this method to close the stream and append the provided data to previously decrypted data.
/// @return leftovers of the decrypted data (due to the way CBC decryption works).
/// Returns nil is the error is occurred, otherwise return NSData instance (even if there is no decrypted data left).
- (nullable NSData *)closeWithData;

/// DO NOT CALL this method to close the stream. Instead, call the - (NSData *)closeWithData;
/// Throws the exception if called.
- (void)close;

@end

/// The PSPDFAESCryptoInputStream Error Domain.
/// @note Used in the PSPDFAESCryptoInputStream -(NSError *)streamError method.
PSPDF_EXPORT NSString *const PSPDFAESCryptoInputStreamErrorDomain;

/// List of documented errors within the PSPDFAESCryptoInputStream.
/// @note Used in the PSPDFAESCryptoInputStream -(NSError *)streamError method.
typedef NS_ENUM(NSInteger, PSPDFAESCryptoInputStreamErrorCode) {
    PSPDFErrorCodeAESCryptoInputStreamUnknownVersionInFileHeader = 110,
    PSPDFErrorCodeAESCryptoInputStreamWrongCloseCalled = 120,
    PSPDFErrorCodeAESCryptoInputStreamCryptorCreationFailed = 130,
    PSPDFErrorCodeAESCryptoInputStreamCryptorResetToIVFailed = 140,
    PSPDFErrorCodeAESCryptoInputStreamCloseExpectedInsteadOfRead = 150,
    PSPDFErrorCodeAESCryptoInputStreamErrorDecryptingBlock = 160,
    PSPDFErrorCodeAESCryptoInputStreamCryptorFinalFailed = 170,
    PSPDFErrorCodeAESCryptoInputStreamHMACCheckFailed = 180,
    PSPDFErrorCodeAESCryptoInputStreamIncorrectHMACInFile = 190,
    PSPDFErrorCodeAESCryptoInputStreamFailedToAllocateMemory = 200,
    PSPDFErrorCodeAESCryptoInputStreamUnknown = NSIntegerMax
} PSPDF_ENUM_AVAILABLE;

NS_ASSUME_NONNULL_END
