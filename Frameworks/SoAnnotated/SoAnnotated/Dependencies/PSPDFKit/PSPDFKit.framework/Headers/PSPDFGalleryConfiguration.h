//
//  PSPDFGalleryConfiguration.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "PSPDFModel.h"
#import "PSPDFMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFGalleryConfigurationBuilder;

/// A `PSPDFGalleryConfiguration` defines the behavior of a `PSPDFGalleryViewController`.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFGalleryConfiguration : PSPDFModel

/// Returns a copy of the default gallery configuration.
+ (PSPDFGalleryConfiguration*)defaultConfiguration;

/// Returns a copy of the default gallery configuration. You can provide a `builderBlock` to change
/// the value of properties.
+ (instancetype)configurationWithBuilder:(void (^)(PSPDFGalleryConfigurationBuilder *))builderBlock;

/// The max. number of concurrent downloads. Defaults to 0, which indicates that the number of downloads
/// will be dynamically decided depending on the connection.
@property (nonatomic, readonly) NSUInteger maximumConcurrentDownloads;

/// The max. number of images after the currently visible one that should be prefetched. Defaults to 3.
/// To disable prefetching, set this to zero.
@property (nonatomic, readonly) NSUInteger maximumPrefetchDownloads;

/// Controls if the user can switch between the fullscreen mode and embedded mode by double-tapping
/// or panning. Defaults to `YES`.
/// @note This only affects user interaction. If you call `setFullscreen:animated:` programmatically,
/// the mode will still be set accordingly.
@property (nonatomic, readonly) BOOL displayModeUserInteractionEnabled;

/// The threshold in points after which the fullscreen mode is exited after a pan. Defaults to 80pt.
@property (nonatomic, readonly) CGFloat fullscreenDismissPanThreshold;

/// Set this to YES if zooming should be enabled in fullscreen mode. Defaults to YES.
@property (nonatomic, readonly, getter=isFullscreenZoomEnabled) BOOL fullscreenZoomEnabled;

/// The maximum zoom scale that you want to allow. Only meaningful if `fullscreenZoomEnabled` is YES
/// Defaults to 20.0.
@property (nonatomic, readonly) CGFloat maximumFullscreenZoomScale;

/// The minimum zoom scale that you want to allow. Only meaningful if `fullscreenZoomEnabled` is YES.
/// Defaults to 1.0.
@property (nonatomic, readonly) CGFloat minimumFullscreenZoomScale;

/// Controls if the gallery should loop infinitely, that is if the user can keep scrolling forever
/// and the content will repeat itself. Defaults to `YES`. Ignored if there's only one item set.
@property (nonatomic, readonly, getter=isLoopEnabled) BOOL loopEnabled;

/// Setting this to `YES` will present a HUD whenever the user goes from the last image to the
/// first one. Defaults to `YES`.
/// @note This property has no effect if `loopEnabled` is set to `NO`.
@property (nonatomic, readonly, getter=isLoopHUDEnabled) BOOL loopHUDEnabled;

/// Indicates whether a media player in the gallery should automatically switch to external playback
/// mode while the external screen mode is active in order to play video content. Defaults to `YES`.
@property (nonatomic, readonly) BOOL usesExternalPlaybackWhileExternalScreenIsActive;

/// Indicates whether multiple galleries can play audio or video content simultaneously.
/// Defaults to `NO`.
@property (nonatomic, readonly) BOOL allowPlayingMultipleInstances;

@end

PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFGalleryConfigurationBuilder : NSObject

@property (nonatomic) NSUInteger maximumConcurrentDownloads;
@property (nonatomic) NSUInteger maximumPrefetchDownloads;
@property (nonatomic) BOOL displayModeUserInteractionEnabled;
@property (nonatomic) CGFloat fullscreenDismissPanThreshold;
@property (nonatomic) BOOL fullscreenZoomEnabled;
@property (nonatomic) CGFloat maximumFullscreenZoomScale;
@property (nonatomic) CGFloat minimumFullscreenZoomScale;
@property (nonatomic) BOOL loopEnabled;
@property (nonatomic) BOOL loopHUDEnabled;
@property (nonatomic) BOOL usesExternalPlaybackWhileExternalScreenIsActive;
@property (nonatomic) BOOL allowPlayingMultipleInstances;

@end

NS_ASSUME_NONNULL_END
