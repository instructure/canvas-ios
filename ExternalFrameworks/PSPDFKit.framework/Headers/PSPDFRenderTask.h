//
//  PSPDFRenderTask.h
//  PSPDFKit
//
//  Copyright © 2016-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFMacros.h"
#import "PSPDFRenderQueue.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFRenderRequest;

@class PSPDFRenderTask;

/// Implement this delegate to get rendered pages. (Most of the times, you want to use `PSPDFCache` instead)
PSPDF_AVAILABLE_DECL @protocol PSPDFRenderTaskDelegate<NSObject>
@optional

/// Called when a render task finished. Guaranteed to be called from the main thread.
- (void)renderTaskDidFinish:(PSPDFRenderTask *)task;

@end

/**
 A render task is used to create an image from the page (or part of it) of a document.

 Depending on the `PSPDFRenderRequest` cache policy, a render task checks the cache
 before actually triggering a new rendering.

 You create a render task by passing it an instance of `PSPDFRenderRequest`. Once
 you have created a render request make sure to fully set it up before scheduling
 it in a render queue.

 A simple example of requesting an image from a page:

 ```objc
 PSPDFMutableRenderRequest *request = [[PSPDFMutableRenderRequest alloc] initWithDocument:document];
 request.pageIndex = pageIndex;
 request.imageSize = CGSizeMake(320.0f, 480.0f);

 PSPDFRenderTask *task = [[PSPDFRenderTask alloc] initWithRequest:request];
 task.priority = PSPDFRenderQueuePriorityUtility;
 task.delegate = self;

 [PSPDFKit.sharedInstance.renderManager.renderQueue scheduleTask:task];
 ```

 ```swift
 let request = PSPDFMutableRenderRequest(document: document)
 request.pageIndex = 0
 request.imageSize = CGSize(width: 320.0, height: 480.0)

 let task = PSPDFRenderTask(request: request)!
 task.priority = .utility
 task.delegate = self

 PSPDFKit.sharedInstance.renderManager.renderQueue.schedule(task)
 ```
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFRenderTask : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE;

/**
 Initializes a task with a given render request.

 The render request is copyied so you can no longer make changes to it after creating
 a render task out of it.

 @note The initializer verifies the request and returns nil if the request is not valid.

 @param request The render request the task should fullfil.

 @return An initialized instance that is ready to be scheduled in a render queue.
 */
- (nullable instancetype)initWithRequest:(PSPDFRenderRequest *)request NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) PSPDFRenderRequest *request;

/**
 The delegate that is used for reporting progress on this render task.
 */
@property (nonatomic, weak) id<PSPDFRenderTaskDelegate> delegate;

/**
 The completion handler to be called after the rendering has completed.
 */
@property (atomic, copy, nullable) void (^completionHandler)(UIImage *image);

/// @name Prioritizing Render Tasks

/**
 The priority of the render task.

 Defaults to PSPDFRenderQueuePriorityUnspecified.
 */
@property (atomic) PSPDFRenderQueuePriority priority;

/// @name Output of a Render Task

/**
 The rendered image after the task has completed.
 */
@property (atomic, readonly, nullable) UIImage *image;

/// @name Managing the Status of a Render Task

/**
 `YES` if the task has been cancelled, `NO` otherwise.
 */
@property (atomic, readonly, getter=isCancelled) BOOL cancelled;

/**
 Cancels a task.

 You will no longer receive any callbacks from this task after cancelling it.
 */
- (void)cancel;

/**
 Groups a number of tasks together and executes a completion handler once all grouped
 tasks complete.

 @param tasks The tasks you want to group.
 @param completionHandler The completion handler that is executed once all render
                          tasks in the `tasks` array completed.
 */
+ (void)groupTasks:(NSArray<PSPDFRenderTask *> *)tasks completionHandler:(void (^)(void))completionHandler;

@end

NS_ASSUME_NONNULL_END
