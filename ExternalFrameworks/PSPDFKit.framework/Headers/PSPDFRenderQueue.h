//
//  PSPDFRenderQueue.h
//  PSPDFKit
//
//  Copyright © 2012-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnnotation.h"
#import "PSPDFEnvironment.h"
#import "PSPDFMacros.h"
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument, PSPDFRenderJob, PSPDFRenderQueue, PSPDFRenderReceipt, PSPDFRenderTask, PSPDFRenderRequest;

/// Absolute limit for image rendering (memory constraint)
PSPDF_EXPORT const CGSize PSPDFRenderSizeLimit;

typedef NS_ENUM(NSUInteger, PSPDFRenderQueuePriority) {
    /// Used for unspecified renderings with the lowest priority.
    PSPDFRenderQueuePriorityUnspecified = 0,

    /// Used for renderings that the user is not aware of, such as building a cache in the background.
    PSPDFRenderQueuePriorityBackground = 100,

    /// Used for renderings that the user might see but that are not necessary to complete, such as generating thumbnails that are not necessary for the user to properly work with a document but.
    PSPDFRenderQueuePriorityUtility = 200,

    /// Used for renderings that the user requested but that are not required for the user to keep using a document.
    PSPDFRenderQueuePriorityUserInitiated = 300,

    /// Used for renderings that the user requested and that are currently blocking their workflow.
    PSPDFRenderQueuePriorityUserInteractive = 400,

    /// Used to re-render annotation changes.
    PSPDFRenderQueuePriorityVeryLow PSPDF_DEPRECATED_IOS("6.0", "Use PSPDFRenderQueuePriorityUnspecified instead.") = PSPDFRenderQueuePriorityUnspecified,

    /// Low and VeryLow are used from within `PSPDFCache`.
    PSPDFRenderQueuePriorityLow PSPDF_DEPRECATED_IOS("6.0", "Use PSPDFRenderQueuePriorityBackground instead.") = PSPDFRenderQueuePriorityBackground,

    /// Live page renderings.
    PSPDFRenderQueuePriorityNormal PSPDF_DEPRECATED_IOS("6.0", "Use PSPDFRenderQueuePriorityUtility instead.") = PSPDFRenderQueuePriorityUtility,

    /// Zoomed renderings.
    PSPDFRenderQueuePriorityHigh PSPDF_DEPRECATED_IOS("6.0", "Use PSPDFRenderQueuePriorityUserInitiated instead.") = PSPDFRenderQueuePriorityUserInitiated,

    /// Highest priority. Unused.
    PSPDFRenderQueuePriorityVeryHigh PSPDF_DEPRECATED_IOS("6.0", "Use PSPDFRenderQueuePriorityUserInteractive instead.") = PSPDFRenderQueuePriorityUserInteractive,
} PSPDF_ENUM_AVAILABLE;

/**
 The render queue is responsible for scheduling and completing tasks. Typically
 you don't create your own render queue but instead use the render queue provided
 by the render manager. Creating your own render queue is possible but due to internal
 resource constraints will almost never speed up rendering but instead the queues
 try to access the same resources and then need to wait until the resource becomes
 available.

 The goal of the render queue is to keep the average time it takes to complete a
 render task at a minimum. To achive this the render queue intelligently schedules
 and bundles tasks. Therefore the order in which scheduled tasks are executed is
 undefined and depends on many factors.
 */
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFRenderQueue : NSObject

/// @name Requests

/**
 Schedules a render task in the receiving queue.

 The order in which tasks are executed is not necessarily the order in which they
 have been scheduled, nor the order of priority. The render queue makes an effort
 to serve as many tasks as possible in a timely manner. You should treat the order
 of execution of tasks as non-deterministic.

 @param task The render task to schedule in the queue.
 */
- (void)scheduleTask:(PSPDFRenderTask *)task NS_SWIFT_NAME(schedule(_:));

/**
 Schedules multiple render tasks in the receiving queue.

 The order in which tasks are executed is not necessarily the order in which they
 have been scheduled, nor the order of priority. The render queue makes an effort
 to serve as many tasks as possible in a timely manner. You should treat the order
 of execution of tasks as non-deterministic.

 @param tasks The render tasks to schedule in the queue.
 */
- (void)scheduleTasks:(NSArray<PSPDFRenderTask *> *)tasks NS_SWIFT_NAME(schedule(_:));

/// @name Settings

#if TARGET_OS_IPHONE
/**
 Number of render jobs that run concurrently. A render job is used internally to
 render the image requested by one or multiple tasks.

 Defaults to a value that is best for the current device.
 */
@property (atomic) NSUInteger concurrentRunningRenderRequests PSPDF_DEPRECATED_IOS(6.7, "The render queue manages this internally based on various factors.");

/**
 Cancel all queued and running jobs.
 */
- (void)cancelAllJobs PSPDF_DEPRECATED_IOS(6.7, "Renamed to cancelAllTasks.");

/**
 The minimum priority for tasks. Defaults to `PSPDFRenderQueuePriorityUnspecified`
 which makes it run all tasks.
 */
@property (atomic) PSPDFRenderQueuePriority minimumProcessPriority PSPDF_DEPRECATED_IOS(6.6.1, "The render queue manages prioritization itself. You should not modify this value.");
#endif

@end

@interface PSPDFRenderQueue (Debugging)

/**
 Cancel all queued and running tasks.

 You should not call this method in production code. Instead to cancel tasks, call
 `cancel` on the tasks you actually want to cancel. Tasks that are started by the
 framework internally are cancelled by their respective owner if their result is
 no longer needed.

 @warning This method should only be used for debugging purpose and might result
          in unexpected behavior when called while the framework is requesting images.
 */
- (void)cancelAllTasks;

@end

NS_ASSUME_NONNULL_END
