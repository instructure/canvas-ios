//
//  PSPDFDownloadManager.h
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
#import "PSPDFReachability.h"
#import "PSPDFFileManager.h"
#import "PSPDFDownloadManagerPolicy.h"

NS_ASSUME_NONNULL_BEGIN

/// Posted whenever a task starts loading.
PSPDF_EXPORT NSString *const PSPDFDownloadManagerDidStartLoadingTaskNotification;

/// Posted whenever a task finishes loading.
PSPDF_EXPORT NSString *const PSPDFDownloadManagerDidFinishLoadingTaskNotification;

/// Posted whenever a task failed to load.
PSPDF_EXPORT NSString *const PSPDFDownloadManagerDidFailToLoadTaskNotification;

typedef NS_ENUM(NSUInteger, PSPDFDownloadManagerObjectState) {
    PSPDFDownloadManagerObjectStateNotHandled,
    PSPDFDownloadManagerObjectStateWaiting,
    PSPDFDownloadManagerObjectStateLoading,
    PSPDFDownloadManagerObjectStateFailed
} PSPDF_ENUM_AVAILABLE;

@protocol PSPDFRemoteContentObject, PSPDFDownloadManagerDelegate;

PSPDF_CLASS_AVAILABLE @interface PSPDFDownloadManager : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// @name Configuration

/// The maximum number of concurrent downloads. Defaults to 2.
/// If `enableDynamicNumberOfConcurrentDownloads` is enabled, this property will change dynamically
/// and must be considered readonly.
@property (nonatomic) NSUInteger numberOfConcurrentDownloads;

/// Enable this property to let `PSPDFDownloadManager` decide what the best number of concurrent downloads
/// is depending on the network connection. Defaults to YES.
@property (nonatomic) BOOL enableDynamicNumberOfConcurrentDownloads;

/// The `PSPDFDownloadManager` delegate.
@property (nonatomic, weak) id <PSPDFDownloadManagerDelegate> delegate;

/// Controls if objects that are currently loading when the app moves to the background
/// should be completed in the background. Defaults to YES. iOS only.
@property (nonatomic) BOOL shouldFinishLoadingObjectsInBackground;

/// @name Enqueueing and Dequeueing Objects

/// See enqueueObject:atFront:. Enqueues the object at the end of the queue.
- (void)enqueueObject:(id <PSPDFRemoteContentObject>)object;

/// Enqueues an `PSPDFRemoteContentObject` for download. If the object is already downloading,
/// nothing is enqueued. If the object has been downloaded previously and has failed, it will be
/// removed from the failedObjects array and re-enqueued.
/// @param object The object to enqueue.
/// @param enqueueAtFront Set this to YES to add the object to the front of the queue.
- (void)enqueueObject:(id <PSPDFRemoteContentObject>)object atFront:(BOOL)enqueueAtFront;

/// Calls enqueueObject:atFont: multiple times. Enqueues the object at the end of the queue.
/// @param objects need to implement the `PSPDFRemoteContentObject` protocol.
- (void)enqueueObjects:(NSArray<id<PSPDFRemoteContentObject>> *)objects;

/// Calls enqueueObject:atFont: multiple times.
/// @param objects need to implement the `PSPDFRemoteContentObject` protocol.
- (void)enqueueObjects:(NSArray<id<PSPDFRemoteContentObject>> *)objects atFront:(BOOL)enqueueAtFront;

/// Cancels the download process for the given object.
/// @param object The object to be cancelled.
- (void)cancelObject:(id <PSPDFRemoteContentObject>)object;

/// Calls `cancelObject:` for all objects in `pendingObjects`, `loadingObjects`, and `failedObjects`.
- (void)cancelAllObjects;

/// @name State

/// The current reachability of the device.
@property (nonatomic, readonly) PSPDFReachability reachability;

/// Contains all objects waiting to be downloaded.
@property (nonatomic, copy, readonly) NSArray<id<PSPDFRemoteContentObject>> *waitingObjects;

/// Contains all currently loading objects.
@property (nonatomic, copy, readonly) NSArray<id<PSPDFRemoteContentObject>> *loadingObjects;

/// Contains all objects that have failed because of a network error and are scheduled for retry.
@property (nonatomic, copy, readonly) NSArray<id<PSPDFRemoteContentObject>> *failedObjects;

/// Helper that iterates loadingObjects, waitingObjects and failedObjects (in that order) and returns all matches.
- (NSArray<id<PSPDFRemoteContentObject>> *)objectsPassingTest:(BOOL (^)(id<PSPDFRemoteContentObject> obj, NSUInteger index, BOOL *stop))predicate;

/// Checks if the given object is currently handled by the download manager.
/// @param object The object.
/// @return YES if the download manager handles the object, that is if it is either pending, loading or failed.
- (BOOL)handlesObject:(id <PSPDFRemoteContentObject>)object;

/// Checks and returns the current state of a given object. If the object has never been enqueued,
/// `PSPDFDownloadManagerObjectStateNotHandled` will be returned.
/// @param object The object.
/// @return The state of the object.
- (PSPDFDownloadManagerObjectState)stateForObject:(id <PSPDFRemoteContentObject>)object;

@end

PSPDF_AVAILABLE_DECL @protocol PSPDFDownloadManagerDelegate <NSObject>

@optional

/// If the delegate wants to handle authentication challenges.
- (void)downloadManager:(PSPDFDownloadManager *)downloadManager authenticationChallenge:(NSURLAuthenticationChallenge *)authenticationChallenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler;

/// Informs the delegate that the state of the given object has changed.
/// @param downloadManager The download manager.
/// @param object The changed object.
- (void)downloadManager:(PSPDFDownloadManager *)downloadManager didChangeObject:(id <PSPDFRemoteContentObject>)object;

/// Informs the delegate that the reachability has changed.
/// @param downloadManager The download manager.
/// @param reachability The new reachability.
- (void)downloadManager:(PSPDFDownloadManager *)downloadManager reachabilityDidChange:(PSPDFReachability)reachability;

@end

NS_ASSUME_NONNULL_END
