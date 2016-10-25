//
//  PSPDFDocument+Library.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFDocument.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSPDFDocument (Library)

/// The additional metadata that should be stored in the library database.
/// @warning This property can only be set if the metadata is serialized. Otherwise an
/// `NSInternalInconsistencyException` will be raised. To test if a given metadata dictionary is
/// serializable, use `+validateLibraryMetadata:`. By default, the metadata is serialized into binary
/// plist format.
@property (atomic, copy) NSDictionary *libraryMetadata;

/// @name Serialization

/// Serializes a given metadata dictionary for storage in the library.
/// @note The `metadata` property must be set.
+ (nullable NSData *)serializeLibraryMetadata:(NSDictionary *)metadata error:(NSError **)error;

/// Deserializes a given metadata dictionary from storage in the library.
/// @note The `data` property must be set.
+ (nullable NSDictionary *)deserializeLibraryMetadata:(NSData *)data error:(NSError **)error;

/// Validates if a given metadata dictionary can be serialized for storage in the library.
/// @note The `metadata` property must be set.
+ (BOOL)validateLibraryMetadata:(NSDictionary *)metadata;

@end

NS_ASSUME_NONNULL_END
