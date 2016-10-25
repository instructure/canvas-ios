//
//  PSPDFProcessorSaveOptions.h
//  PSPDFModel
//
//  Copyright (c) 2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>

#import "PSPDFMacros.h"
#import "PSPDFDocumentProvider.h"

@class PSPDFDocument;

NS_ASSUME_NONNULL_BEGIN

/// This class describes the save options you want to enforce when processing a
/// pdf file. Using a save options object overrides the default options of a file.
///
/// @note In order to use this class, you need a license that enables you to use
///       the Document Editor. If you want to process a file while keeping the
///       options of the original file, simply use `nil` as safe option.
PSPDF_CLASS_AVAILABLE @interface PSPDFProcessorSaveOptions : NSObject

/// Returns a `PSPDFProcessorSaveOptions` instance with owner and user password set.
/// `keyLength` must be divisible by 8 and in the range of 40 to 128.
/// @note This method requires the Document Editor component to be enabled for your license.
+ (instancetype)optionsWithOwnerPassword:(NSString *)ownerPassword userPassword:(NSString *)userPassword keyLength:(NSUInteger)keyLength;

/// Returns a `PSPDFProcessorSaveOptions` instance with owner and user password set.
/// `keyLength` must be divisible by 8 and in the range of 40 to 128.
/// @note This method requires the Document Editor component to be enabled for your license.
+ (instancetype)optionsWithOwnerPassword:(NSString *)ownerPassword userPassword:(NSString *)userPassword keyLength:(NSUInteger)keyLength permissions:(PSPDFDocumentPermissions)documentPermissions;

/// Allows you to set different passwords and on the resulting document.
/// @note This method requires the Document Editor component to be enabled for your license.
- (instancetype)initWithOwnerPassword:(nullable NSString *)ownerPassword userPassword:(nullable NSString *)userPassword keyLength:(nullable NSNumber *)keyLength;

/// Allows you to set different passwords and permissions on the resulting document.
/// @note This method requires the Document Editor component to be enabled for your license.
- (instancetype)initWithOwnerPassword:(nullable NSString *)ownerPassword userPassword:(nullable NSString *)userPassword keyLength:(nullable NSNumber *)keyLength permissions:(PSPDFDocumentPermissions)documentPermissions NS_DESIGNATED_INITIALIZER;

/// The owner password that will be set in the processed document or `nil` if the password should be removed.
@property (nonatomic, nullable, copy, readonly) NSString *ownerPassword;

/// The user password that will be set in the processed document or `nil` if the password should be removed.
@property (nonatomic, nullable, copy, readonly) NSString *userPassword;

/// The key-length of the encryption.
@property (nonatomic, nullable, copy, readonly) NSNumber *keyLength;

/// The `PSPDFDocumentPermissions` that will be set.
@property (nonatomic, readonly) PSPDFDocumentPermissions permissions;

@end

NS_ASSUME_NONNULL_END
