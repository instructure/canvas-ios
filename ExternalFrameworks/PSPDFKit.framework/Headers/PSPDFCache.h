//
//  PSPDFCache.h
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

@class PSPDFDocument, PSPDFKit, PSPDFRenderRequest, PSPDFMemoryCache, PSPDFDiskCache;

NS_ASSUME_NONNULL_BEGIN

typedef void (^PSPDFCacheDocumentImageRenderingCompletionBlock)(UIImage *image, PSPDFDocument *document, NSUInteger page, CGSize size);

typedef NS_ENUM(NSInteger, PSPDFCacheStoragePolicy) {
    PSPDFCacheStoragePolicyAutomatic = 0,

    PSPDFCacheStoragePolicyAllowed,
    PSPDFCacheStoragePolicyAllowedInMemoryOnly,
    PSPDFCacheStoragePolicyNotAllowed,
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSInteger, PSPDFCacheStatus) {
    PSPDFCacheStatusNotCached,
    PSPDFCacheStatusInMemory,
    PSPDFCacheStatusOnDisk,
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSInteger, PSPDFDiskCacheStrategy) {
    /// No files are saved. (slowest)
    PSPDFDiskCacheStrategyNothing,
    /// Only thumbnails are cached to disk.
    PSPDFDiskCacheStrategyThumbnails,
    /// Only a few files are saved and all thumbnails.
    PSPDFDiskCacheStrategyNearPages,
    /// The whole PDF document is converted to images and saved. (fastest)
    PSPDFDiskCacheStrategyEverything
} PSPDF_ENUM_AVAILABLE;

/**
 `PSPDFCacheImageSizeMatching` is a bit mask that can be used to control how
 the cache determines if an image's size matches a given request.
 */
typedef NS_OPTIONS(NSUInteger, PSPDFCacheImageSizeMatching) {
    /// Requires the exact size, the default option.
    PSPDFCacheImageSizeMatchingExact = 0,
    /// Allow serving images of larger size.
    PSPDFCacheImageSizeMatchingAllowLarger = 1 << 0,
    /// Allow serving images of smaller size.
    PSPDFCacheImageSizeMatchingAllowSmaller = 1 << 1,

    PSPDFCacheImageSizeMatchingDefault = PSPDFCacheImageSizeMatchingExact
} PSPDF_ENUM_AVAILABLE;

/**
 The `PSPDFCache` is responsible for managing the memory and disk cache of rendered
 images.

 Usually you do not access any methods of `PSPDFCache` directly but instead schedule
 a `PSPDFRenderTask` in a `PSPDFRenderQueue` which will then reach out to the cache
 and check if there are images available before rendering a new one.

 @see PSPDFRenderTask
 */
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFCache : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// The designated initializer.
- (instancetype)initWithSettings:(PSPDFKit *)pspdfkit NS_DESIGNATED_INITIALIZER;

/// @name Access cache

/// The memory cached store used to keep images in memory for fast access.
@property (nonatomic, readonly) PSPDFMemoryCache *memoryCache;

/// The disk cache used to persist images on disk for fast access.
@property (nonatomic, readonly) PSPDFDiskCache *diskCache;

/// Get the cache status of a rendered image.
- (PSPDFCacheStatus)cacheStatusForRequest:(PSPDFRenderRequest *)request imageSizeMatching:(PSPDFCacheImageSizeMatching)imageSizeMatching;

/**
 Get the image for a certain document page.
 Will first check the memory cache, then the disk cache.
 If `requireExactSize` is set, images will either be downscaled or dynamically rendered. (There's no point in upscaling)
 */
- (nullable UIImage *)imageForRequest:(PSPDFRenderRequest *)request imageSizeMatching:(PSPDFCacheImageSizeMatching)imageSizeMatching;

/// @name Store into cache

/**
 Caches the image in memory and disk for later re-use.
 PSPDFCache will decide at runtime if the image is worth saving into memory or just disk. (And disk will only be hit if the image is different)
 */
- (void)saveImage:(UIImage *)image forRequest:(PSPDFRenderRequest *)request;

/// @name Document pre-processing

/**
 Asynchronously pre-renders and caches the document. The delegate method `didRenderImage:document:page:size:` gets called after each image is rendered (number of pages x number of sizes).

 @note Under certain conditions (such as if the device is running low on power)
       the cache may suspend pre caching operations until everything has been restored
       to normal conditions.

 @param document The document to render and cache — if `nil`, this message is ignored.
 @param sizes    An array of NSValue objects constructed with CGSize. Each page will be rendered for each size specified in this array.
 @param strategy The caching strategy to use.
 @param pageIndex If using PSPDFDiskCacheStrategyNearPages a few pages before and after the provided page will be cached only. The parameter is otherwise ignored.
 */
- (void)cacheDocument:(nullable PSPDFDocument *)document pageSizes:(NSArray<NSValue *> *)sizes withDiskCacheStrategy:(PSPDFDiskCacheStrategy)strategy aroundPageAtIndex:(NSUInteger)pageIndex;

/**
 Asynchronously pre-renders and caches the document. The delegate method `didRenderImage:document:page:size:` gets called after each image is rendered (number of pages x number of sizes).

 @note Under certain conditions (such as if the device is running low on power)
       the cache may suspend pre caching operations until everything has been restored
       to normal conditions.

 @param document            The document to render and cache — if `nil`, this message is ignored.
 @param sizes               An array of NSValue objects constructed with CGSize. Each page will be rendered for each size specified in this array.
 @param strategy            The caching strategy to use.
 @param pageIndex           If using PSPDFDiskCacheStrategyNearPages a few pages before and after the provided page will be cached only. The parameter is otherwise ignored.
 @param pageCompletionBlock This block will be executed each time a page is rendered for each size (the delegates, if any, will still be called!).
 */
- (void)cacheDocument:(nullable PSPDFDocument *)document pageSizes:(NSArray<NSValue *> *)sizes withDiskCacheStrategy:(PSPDFDiskCacheStrategy)strategy aroundPageAtIndex:(NSUInteger)pageIndex imageRenderingCompletionBlock:(nullable PSPDFCacheDocumentImageRenderingCompletionBlock)pageCompletionBlock;

/// Stops all cache requests (render requests, queued disk writes) for the document.
- (void)stopCachingDocument:(nullable PSPDFDocument *)document;

/// @name Cache invalidation

/**
 Allows to invalidate a single page in the document.
 This usually is called after an annotation changes (and thus the image needs to be re-rendered)
 @note If the document is nil, the request is silently ignored.
 */
- (void)invalidateImageFromDocument:(nullable PSPDFDocument *)document pageIndex:(NSUInteger)pageIndex;

/**
 Removes the whole cache (memory/disk) for `document`. Will cancel any open writes as well.
 Enable `deleteDocument` to remove the document and the associated metadata.
 */
- (void)removeCacheForDocument:(nullable PSPDFDocument *)document;

/// Clears the disk and memory cache.
- (void)clearCache;

@end

@interface PSPDFCache (Deprecated)

/// @name Settings

/**
 Cache files are saved in a subdirectory of `NSCachesDirectory`. Defaults to "PSPDFKit/Pages".
 @note The cache directory is not backed up by iCloud and will be purged when memory is low.
 @warning Set this early during class initialization. Will clear the current cache before changing.
 */
@property (nonatomic, copy) NSString *cacheDirectory PSPDF_DEPRECATED("6.1", "Use the properties on PSPDFDiskCache instead.");

/**
 Defines the global disk cache strategy. Defaults to `PSPDFDiskCacheStrategyEverything`.
 If `PSPDFDocument` also defines a strategy, that one is prioritized.
 */
@property (nonatomic) PSPDFDiskCacheStrategy diskCacheStrategy PSPDF_DEPRECATED("6.1", "Disk cache strategy is controlled automatically now. To disable the disk cache completely set its allowedDiskSpace to 0.");

/// @name Access internal caches

/**
 The maximum amount of disk space the cache is allowed to use (in bytes).

 This value is a non strict maximum value. The cache might also start evicting images
 before this limit is reached, depending on the memory and disk state of the device.

 @note Set to 0 to disable the disk cache.
 */
@property (nonatomic) unsigned long long allowedDiskSpace PSPDF_DEPRECATED("6.1", "Use the properties on PSPDFDiskCache instead.");

/// The disk space currently used by the cache (in bytes).
@property (nonatomic, readonly) unsigned long long usedDiskSpace PSPDF_DEPRECATED("6.1", "Use the properties on PSPDFDiskCache instead.");

/// @name Disk Cache Settings

/**
 JPG is almost always faster, and uses less memory (<50% of a PNG, usually). Defaults to YES.
 If you have very text-like pages, you might want to set this to NO.
 */
@property (nonatomic) BOOL useJPGFormat PSPDF_DEPRECATED("6.1", "Use the properties on PSPDFDiskCache instead.");

/**
 Compression strength for JPG. (PNG is loss-less)
 The higher the compression, the larger the files and the slower is decompression. Defaults to 0.9.
 This will load the pdf and remove any jpg artifacts.
 */
@property (nonatomic) CGFloat JPGFormatCompression PSPDF_DEPRECATED("6.1", "Use the properties on PSPDFDiskCache instead.");

/// @name Encryption/Decryption Handlers

/**
 Decrypt data from the path. Requires the `PSPDFFeatureMaskStrongEncryption` feature flag.
 If set to nil, the default implementation will be used.
 */
@property (atomic, copy) NSData * (^decryptFromPathBlock)(PSPDFDocument *document, NSString *path)PSPDF_DEPRECATED("6.1", "Use the properties on PSPDFDiskCache instead.");

/**
 Encrypt mutable data. Requires the `PSPDFFeatureMaskStrongEncryption` feature flag.
 If set to nil, the default implementation will be used.
 */
@property (atomic, copy) void (^encryptDataBlock)(PSPDFDocument *document, NSMutableData *data) PSPDF_DEPRECATED("6.1", "Use the properties on PSPDFDiskCache instead.");

/// @name Starting/Stopping

/**
 Will pause queued cache requests on the render queue.
 For `service` use the class object that requests the pause.
 */
- (void)pauseCachingForService:(id)service PSPDF_DEPRECATED("6.6.1", "Pause caching is no longer supported. The cache handles this on its own.");

/**
 Will resume queued cache requests on the render queue.
 For `service` use the class object that requested the pause.
 */
- (void)resumeCachingForService:(id)service PSPDF_DEPRECATED("6.6.1", "Pause caching is no longer supported. The cache handles this on its own.");

@end

NS_ASSUME_NONNULL_END
