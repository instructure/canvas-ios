//
//  PSPDFMemoryCache.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFDiskCache.h"

@class PSPDFRenderReceipt;
@protocol PSPDFSettings;

NS_ASSUME_NONNULL_BEGIN

/// The memory cache is designed to take up as much memory as it can possibly get (the more, the faster!)
/// On a memory warning, it will call `clearCache` all release all stored images.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFMemoryCache : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// The designated initializer.
- (instancetype)initWithSettings:(id<PSPDFSettings>)settings NS_DESIGNATED_INITIALIZER;

/// @name Accessing Data

/// Access an image from the memory cache.
- (nullable PSPDFCacheInfo *)cacheInfoForImageWithUID:(NSString *)UID page:(NSUInteger)page size:(CGSize)size infoSelector:(nullable PSPDFCacheInfoSelector)infoSelector;

/// @name Storing Data

/// Store images into the cache. Storing is async.
- (void)storeImage:(UIImage *)image UID:(NSString *)UID page:(NSUInteger)page receipt:(NSString *)renderReceipt;

/// @name Invalidating Cache Entries

/// Invalidate all images that match `UID`.
- (BOOL)invalidateAllImagesWithUID:(NSString *)UID;

/// Invalidate all images that match `UID` and `page`.
- (BOOL)invalidateAllImagesWithUID:(NSString *)UID page:(NSUInteger)page;

/// Clears all entries in the memory cache.
- (void)clearCache;

/// @name Statistics

/// Number of objects that are currently in the cache.
@property (nonatomic, readonly) NSUInteger count;

/// Tracks the current amount of pixels cached.
/// One pixel roughly needs 4 byte (+structure overhead).
@property (nonatomic, readonly) NSUInteger numberOfPixels;

/// Maximum number of pixels allowed to be cached. Device dependent.
@property (nonatomic) NSUInteger maxNumberOfPixels;

/// Maximum number of pixels allowed to be cached after a memory warning. Device dependent.
@property (nonatomic) NSUInteger maxNumberOfPixelsUnderStress;

@end

NS_ASSUME_NONNULL_END
