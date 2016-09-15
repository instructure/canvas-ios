//
//  PSPDFCryptoInputStream.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

PSPDF_CLASS_AVAILABLE @interface PSPDFCryptoInputStream : NSInputStream

/// Returns nil if the encryption feature is not enabled.
- (nullable instancetype)initWithInputStream:(NSInputStream *)stream decryptionBlock:(nullable NSInteger (^)(PSPDFCryptoInputStream *superStream, uint8_t *buffer, NSInteger len))decryptionBlock;

/// Set the decryption handler. If no decryption block is called, this input stream will simply pass the data through.
/// Return the length of the decrypted buffer. This block is assuming you are decrypting inline.
/// @note Set this property before the input stream is being used.
@property (nonatomic, copy) NSInteger (^decryptionBlock)(PSPDFCryptoInputStream *stream, uint8_t *buffer, NSInteger len);

@end

NS_ASSUME_NONNULL_END
