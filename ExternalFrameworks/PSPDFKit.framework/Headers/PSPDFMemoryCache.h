//
//  PSPDFMemoryCache.h
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

@class PSPDFKit;

NS_ASSUME_NONNULL_BEGIN

/**
 The memory cache holds images in memory to give the render engine access to them
 as fast as possible. By default its memory constraints are configured to get the
 best performance out of the current device.
 */
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFMemoryCache : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// The designated initializer.
/**
 Initializes the memory cache with the given settings.

 This is the designated initializer.

 @param settings The settings to use for the cache store.
 @return A newly initialized memory cache.
 */
- (instancetype)initWithSettings:(PSPDFKit *)settings NS_DESIGNATED_INITIALIZER;

/// @name Statistics

/**
 Number of objects that are currently in the cache.
 */
@property (nonatomic, readonly) NSUInteger count;

/**
 Tracks the current amount of pixels cached.

 One pixel roughly needs 4 byte (+ structure overhead).
 */
@property (nonatomic, readonly) long long numberOfPixels;

/**
 Maximum number of pixels allowed to be cached.

 The default is a device dependent value.
 */
@property (nonatomic) long long maxNumberOfPixels;

/**
 Maximum number of pixels allowed to be cached when the device is under stress
 (e.g. when a memory warning arrives).

 The default is a device dependent value.
 */
@property (nonatomic) long long maxNumberOfPixelsUnderStress;

@end

NS_ASSUME_NONNULL_END
