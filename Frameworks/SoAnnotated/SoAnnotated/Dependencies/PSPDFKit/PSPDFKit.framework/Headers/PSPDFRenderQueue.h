//
//  PSPDFRenderQueue.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "PSPDFMacros.h"
#import "PSPDFAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument, PSPDFRenderJob, PSPDFRenderQueue, PSPDFRenderReceipt;

/// Notification that will be thrown when we enqueue a job.
PSPDF_EXPORT NSString *const PSPDFRenderQueueDidEnqueueJobNotification;

/// Notification that will be thrown after a job finished. (in addition to the delegate)
PSPDF_EXPORT NSString *const PSPDFRenderQueueDidFinishJobNotification;

/// Notification that will be thrown when we cancel a job.
PSPDF_EXPORT NSString *const PSPDFRenderQueueDidCancelJobNotification;

/// Absolute limit for image rendering (memory constraint)
PSPDF_EXPORT const CGSize PSPDFRenderSizeLimit;

/// Implement this delegate to get rendered pages. (Most of the times, you want to use `PSPDFCache` instead)
PSPDF_AVAILABLE_DECL @protocol PSPDFRenderDelegate <NSObject>

/// Called when a render job finished. Guaranteed to be called from the main thread.
- (void)renderQueue:(PSPDFRenderQueue *)renderQueue jobDidFinish:(PSPDFRenderJob *)job;

@end

typedef NS_ENUM(NSUInteger, PSPDFRenderQueuePriority) {
    /// Used to re-render annotation changes.
    PSPDFRenderQueuePriorityVeryLow,

    /// Low and VeryLow are used from within `PSPDFCache`.
    PSPDFRenderQueuePriorityLow,

    /// Live page renderings.
    PSPDFRenderQueuePriorityNormal,

    /// Zoomed renderings.
    PSPDFRenderQueuePriorityHigh,

    /// Highest priority. Unused.
    PSPDFRenderQueuePriorityVeryHigh
} PSPDF_ENUM_AVAILABLE;

/// Render Queue. Does not cache. Used for rendering pages/page parts in `PSPDFPageView`.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFRenderQueue : NSObject

/// @name Requests

/// Requests a (freshly) rendered image from a specified document. Does not use the file cache.
/// For options, see `PSPDFPageRender`.
/// If `queueAsNext` is set, the request will be processed ASAP, skipping the current queue.
- (nullable PSPDFRenderJob *)requestRenderedImageForDocument:(PSPDFDocument *)document page:(NSUInteger)page size:(CGSize)size clippedToRect:(CGRect)clipRect annotations:(nullable NSArray<__kindof PSPDFAnnotation *> *)annotations options:(nullable NSDictionary<NSString *, id> *)options priority:(PSPDFRenderQueuePriority)priority queueAsNext:(BOOL)queueAsNext delegate:(nullable id<PSPDFRenderDelegate>)delegate completionBlock:(nullable void (^)(PSPDFRenderJob *renderJob, PSPDFRenderQueue *renderQueue))completionBlock;

/// Return all queued jobs for the current `document` and `page`. (bound to `delegate`)
- (NSArray<PSPDFRenderJob *> *)renderJobsForDocument:(PSPDFDocument *)document page:(NSUInteger)page delegate:(id<PSPDFRenderDelegate>)delegate;

/// Returns YES if currently a RenderJob is scheduled or running for delegate.
- (BOOL)hasRenderJobsForDelegate:(id<PSPDFRenderDelegate>)delegate;

/// Return how many jobs are currently queued.
@property (nonatomic, readonly) NSUInteger numberOfQueuedJobs;

/// @name Cancellation

/// Cancel a single render job.
/// @return YES if cancellation was successful, NO if not found.
- (BOOL)cancelJob:(PSPDFRenderJob *)job onlyIfQueued:(BOOL)onlyIfQueued;

/// Cancel all queued and running jobs.
- (void)cancelAllJobs;

/// Cancel rendering jobs that match the criterias specified in the parameters.
///
/// @param document       The document for which renderings should be stopped.
/// @param page           The page for which renderings should be stopped. Use `NSNotFound` to match all pages.
/// @param delegate       The delegate for which renderings should be stopped.
/// @param includeRunning `YES` if you also want to cancel currently running renderings, `NO` if only queued renederings should be cancelled.
- (void)cancelJobsForDocument:(nullable PSPDFDocument *)document page:(NSUInteger)page delegate:(nullable id<PSPDFRenderDelegate>)delegate includeRunning:(BOOL)includeRunning;

/// Cancels all queued render-calls.
- (void)cancelJobsForDelegate:(id<PSPDFRenderDelegate>)delegate;

/// @name Settings

/// The minimum priority for requests. Defaults to `PSPDFRenderQueuePriorityVeryLow`.
/// Set to `PSPDFRenderQueuePriorityNormal` to temporarily pause cache requests.
@property (nonatomic) PSPDFRenderQueuePriority minimumProcessPriority;

/// Amount of render requests that run at the same time. Defaults to 2.
@property (atomic) NSUInteger concurrentRunningRenderRequests;

@end

/// Gets a 'receipt' of the current render operation, allows to compare different renders of the same page.
PSPDF_CLASS_AVAILABLE @interface PSPDFRenderReceipt : NSObject <NSSecureCoding>

PSPDF_EMPTY_INIT_UNAVAILABLE

@property (nonatomic, readonly, nullable) NSString *renderFingerprint;

@end

NS_ASSUME_NONNULL_END
