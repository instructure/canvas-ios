//
//  PSPDFDiskCache.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import "PSPDFEnvironment.h"

@class PSPDFCacheInfo, PSPDFRenderReceipt, PSPDFKit;

NS_ASSUME_NONNULL_BEGIN

// Cache selector (to fetch sizes)
typedef PSPDFCacheInfo *_Nonnull (^PSPDFCacheInfoSelector)(NSOrderedSet *);
typedef NSArray *_Nonnull (^PSPDFCacheInfoArraySelector)(NSOrderedSet *);

// Encryption/Decryption Helper.
typedef UIImage *_Nullable (^PSPDFCacheDecryptionHelper)(NSString *path);
typedef NSData *_Nullable (^PSPDFCacheEncryptionHelper)(UIImage *image);

/// The disk cache is designed to store and fetch images, including metadata, in a fast way.
/// No actual images will be held in memory (besides during the time they are scheduled for writing to disk).
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFDiskCache : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Initializes the disk cache with the specified directory and the file ending (jpg, png)
- (instancetype)initWithCacheDirectory:(NSString *)cacheDirectory fileFormat:(NSString *)fileFormat settings:(PSPDFKit *)settings NS_DESIGNATED_INITIALIZER;

/// @name Accessing Data

/// Check if there's an matching entry in the cache.
- (nullable PSPDFCacheInfo *)cacheInfoForImageWithUID:(NSString *)UID page:(NSUInteger)page size:(CGSize)size infoSelector:(nullable PSPDFCacheInfoSelector)infoSelector;

/// Will load the image synchronously. The `decryptionHelper` is mandatory.
- (nullable UIImage *)imageWithUID:(NSString *)UID page:(NSUInteger)page size:(CGSize)size infoSelector:(nullable PSPDFCacheInfoSelector)infoSelector decryptionHelper:(PSPDFCacheDecryptionHelper)decryptionHelper cacheInfo:(PSPDFCacheInfo *_Nullable*_Nullable)outCacheInfo;

/// Accessing data will take some time, calls `completionBlock` when done. The `decryptionHelper` is mandatory.
/// Returns `YES` if an image was found and a loading operation is scheduled.
- (nullable PSPDFCacheInfo *)scheduleLoadImageWithUID:(NSString *)UID page:(NSUInteger)page size:(CGSize)size infoSelector:(PSPDFCacheInfoSelector)infoSelector decryptionHelper:(PSPDFCacheDecryptionHelper)decryptionHelper completionBlock:(nullable void (^)(UIImage *cachedImage, PSPDFCacheInfo *cacheInfo))completionBlock;

/// @name Storing Data

/// Store images into the cache.
/// The `encryptionHelper` is mandatory.
- (void)storeImage:(UIImage *)image UID:(NSString *)UID page:(NSUInteger)page encryptionHelper:(PSPDFCacheEncryptionHelper)encryptionHelper receipt:(NSString *)renderReceipt;

/// Store the image into the cache and execute the completion block when the disk write is complete.
- (void)storeImage:(UIImage *)image UID:(NSString *)UID page:(NSUInteger)page encryptionHelper:(PSPDFCacheEncryptionHelper)encryptionHelper receipt:(NSString *)renderReceipt completionBlock:(nullable void(^)(PSPDFCacheInfo *cacheInfo))completionBlock;

/// @name Invalidating Cache Entries

/// Invalidate all images that match `UID`. Will also invalidate any open writes.
- (BOOL)invalidateAllImagesWithUID:(NSString *)UID;

/// Invalidate all images that match `UID` and `page`. Will also invalidate any open writes.
- (BOOL)invalidateAllImagesWithUID:(NSString *)UID page:(NSUInteger)page;

/// Invalidate cancel all write requests that match `UID` and `page` that match `infoSelector`.
/// Use NSNotFound as a wildcard for all pages.
- (void)cancelWriteRequestsWithUID:(NSString *)UID page:(NSUInteger)page;

/// Removes all entries in the disk cache.
- (void)clearCache;

/// @name Settings

/// The maximum amount of disk space the cache is allowed to use (in bytes). Defaults to 500MB (500*1024*1024).
/// @note Set to 0 to disable the disk cache.
@property (nonatomic) unsigned long long allowedDiskSpace;

/// The disk space currently used by the cache (in bytes).
@property (nonatomic, readonly) unsigned long long usedDiskSpace;

/// Returns the available free disk space. (Calculated on every access)
@property (nonatomic, readonly) unsigned long long freeDiskSpace;

/// The file format (png, jpg)
@property (nonatomic, copy) NSString *fileFormat;

@end

NS_ASSUME_NONNULL_END
