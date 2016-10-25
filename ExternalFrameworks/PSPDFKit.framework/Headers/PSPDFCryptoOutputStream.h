//
//  PSPDFCryptoOutputStream.h
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

PSPDF_CLASS_AVAILABLE @interface PSPDFCryptoOutputStream : NSOutputStream

/// Returns nil if the encryption feature is not enabled.
- (nullable instancetype)initWithOutputStream:(NSOutputStream *)stream encryptionBlock:(NSData * (^)(PSPDFCryptoOutputStream *stream, const uint8_t *buffer, NSUInteger len))encryptionBlock;

/// Set the encryption handler. If no encryption block is called, this output stream will simply pass the data through.
/// @note Set this property before the output stream is being used.
@property (nonatomic, copy) NSData *(^encryptionBlock)(PSPDFCryptoOutputStream *stream, const uint8_t *buffer, NSUInteger len);

@end

NS_ASSUME_NONNULL_END
