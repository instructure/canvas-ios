//
//  PSPDFDiskCache.h
//  PSPDFKit
//
//  Copyright © 2013-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

@class PSPDFKit, PSPDFRenderRequest;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PSPDFDiskCacheFileFormat) {
    PSPDFDiskCacheFileFormatJPEG,
    PSPDFDiskCacheFileFormatPNG,
} PSPDF_ENUM_AVAILABLE;

/**
 The disk cache persists its metadata on disk together with the images and provides
 cached images even after the app restarts.

 The disk cache is designed to store and fetch images, including metadata, in a
 fast way. No actual images will be held in memory (besides during the time they
 are scheduled for writing to disk).
 */
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFDiskCache : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/**
 Initializes the disk cache with the specified directory and the file format.

 @param cacheDirectory The directory that should be used for this cache, relative to the app's cache directory.
 @param fileFormat The file format to use for storing images to disk.
 @param settings The settings used to create the cache.
 @return A newly initialized disk cache.
 */
- (instancetype)initWithCacheDirectory:(NSString *)cacheDirectory fileFormat:(PSPDFDiskCacheFileFormat)fileFormat settings:(PSPDFKit *)settings NS_DESIGNATED_INITIALIZER;

/// @name Settings

/**
 The maximum amount of disk space the cache is allowed to use (in bytes).

 This value is a non strict maximum value. The cache might also start evicting images
 before this limit is reached, depending on the memory and disk state of the device.

 @note Set to 0 to disable the disk cache.
 */
@property (nonatomic) long long allowedDiskSpace;

/**
 The disk space currently used by the cache (in bytes).
 */
@property (nonatomic, readonly) long long usedDiskSpace;

/**
 The directory this cache uses.
 */
@property (nonatomic, copy) NSString *cacheDirectory;

/**
 The file format used to store images.

 Defaults to jpeg.
 */
@property (nonatomic) PSPDFDiskCacheFileFormat fileFormat;

/**
 If the file format is jpeg, this controls the quality (from 0.0 = bad to 1.0 = best).

 Defaults to 0.9.
 */
@property (nonatomic) CGFloat jpegCompression;

/// @name Security

/**
 A block that is called to encrypt data before storing it to the disk.

 @note This block is called on an arbitrary, concurrent background queue.
 */
@property (nonatomic, copy, nullable) NSData *_Nullable (^encryptionHelper)(PSPDFRenderRequest *request, NSData *data);

/**
 A block that is called to decrypt data that was previously encrypted via the encryption
 helper.

 @note This block is called on an arbitrary, concurrent background queue.
 */
@property (nonatomic, copy, nullable) NSData *_Nullable (^decryptionHelper)(PSPDFRenderRequest *request, NSData *encryptedData);

@end

NS_ASSUME_NONNULL_END
