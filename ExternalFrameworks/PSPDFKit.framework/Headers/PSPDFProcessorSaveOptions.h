//
//  PSPDFProcessorSaveOptions.h
//  PSPDFModel
//
//  Copyright © 2016-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

#import "PSPDFDocumentProvider.h"
#import "PSPDFMacros.h"

@class PSPDFDocument;

NS_ASSUME_NONNULL_BEGIN

/// The constant to be used to indicate that the key length should be determined automatically.
PSPDF_EXPORT const NSUInteger PSPDFProcessorSaveOptionsKeyLengthAutomatic;

/**
 This class describes the save options you want to enforce when processing a
 pdf file. Using a save options object overrides the default options of a file.

 A pdf file can have multiple security-related options set. The owner password
 generally controls the editing of a document and is required as soon as you want
 to encrypt a document in any kind. The user password prevents users from viewing
 the pdf. It is optional but if you specify it you also need to specify an owner
 password.

 You can also specify the key length of the encryption. This controls how large
 the key is that is used for actually encrypting the document. The key is derived
 from the passwords you specify. As soon as you specify at least an owner password
 you also need to decide on a key length to be used. You can also specify
 `PSPDFProcessorSaveOptionsKeyLengthAutomatic` in all cases and let PSPDFKit decide
 on if and what key length to use.

 To specify what operations are allowed when opening the document with user privileges
 you can also set `PSPDFDocumentPermissions`. With user privileges you can always
 view the file in question and by specifying `PSPDFDocumentPermissions` you can
 grant further rights that otherwise would only be available when the user has
 owner privileges.

 @note In order to use this class, you need a license that enables you to use the
       Document Editor. If you want to process a file while keeping the options
       of the original file, simply use `nil` as safe option.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFProcessorSaveOptions : NSObject

/**
 Allows you to set different passwords on the resulting document.

 @param ownerPassword  The password to be used as the document owner password.
 @param userPassword   The password to be used as the password of a regular user.
 @param keyLength      The length of the crypto key. This key must be a multiple
                       of 8 and between 40 and 128. You can also set the length
                       to `PSPDFProcessorSaveOptionsKeyLengthAutomatic` to let
                       PSPDFKit maintain the keylength for you. If you do not have
                       special needs, this might be the best choice for both,
                       encrypted and unencrypted documents.

 @return A newly initialized instance of the receiver.
 */
- (instancetype)initWithOwnerPassword:(nullable NSString *)ownerPassword userPassword:(nullable NSString *)userPassword keyLength:(NSUInteger)keyLength;

/**
 Allows you to set different passwords on the resulting document.

 @param ownerPassword        The password to be used as the document owner password.
 @param userPassword         The password to be used as the password of a regular user.
 @param keyLength            The length of the crypto key. This key must be a multiple
                             of 8 and between 40 and 128. You can also set the length
                             to `PSPDFProcessorSaveOptionsKeyLengthAutomatic` to let
                             PSPDFKit maintain the keylength for you. If you do not have
                             special needs, this might be the best choice for both,
                             encrypted and unencrypted documents.
 @param documentPermissions  The permissions that should be set on the document.

 @return A newly initialized instance of the receiver.
 */
- (instancetype)initWithOwnerPassword:(nullable NSString *)ownerPassword userPassword:(nullable NSString *)userPassword keyLength:(NSUInteger)keyLength permissions:(PSPDFDocumentPermissions)documentPermissions NS_DESIGNATED_INITIALIZER;

/// The owner password that will be set in the processed document or `nil` if the password should be removed.
@property (nonatomic, nullable, copy, readonly) NSString *ownerPassword;

/// The user password that will be set in the processed document or `nil` if the password should be removed.
@property (nonatomic, nullable, copy, readonly) NSString *userPassword;

/// The key-length of the encryption.
@property (nonatomic, readonly) NSUInteger keyLength;

/// The `PSPDFDocumentPermissions` that will be set.
@property (nonatomic, readonly) PSPDFDocumentPermissions permissions;

@end

@interface PSPDFProcessorSaveOptions (Deprecated)

/// Returns a `PSPDFProcessorSaveOptions` instance with owner and user password set.
/// `keyLength` must be divisible by 8 and in the range of 40 to 128.
/// @note This method requires the Document Editor component to be enabled for your license.
+ (instancetype)optionsWithOwnerPassword:(NSString *)ownerPassword userPassword:(NSString *)userPassword keyLength:(NSUInteger)keyLength PSPDF_DEPRECATED("6.0", "Use the initializers instead.");

/// Returns a `PSPDFProcessorSaveOptions` instance with owner and user password set.
/// `keyLength` must be divisible by 8 and in the range of 40 to 128.
/// @note This method requires the Document Editor component to be enabled for your license.
+ (instancetype)optionsWithOwnerPassword:(NSString *)ownerPassword userPassword:(NSString *)userPassword keyLength:(NSUInteger)keyLength permissions:(PSPDFDocumentPermissions)documentPermissions PSPDF_DEPRECATED("6.0", "Use the initializers instead.");

@end

NS_ASSUME_NONNULL_END
