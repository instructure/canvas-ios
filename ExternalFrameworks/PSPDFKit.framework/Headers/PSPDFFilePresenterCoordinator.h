//
//  PSPDFFilePresenterCoordinator.h
//  PSPDFKit
//
//  Copyright © 2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Coordinates file presenters and notifications.
 Observed presenters are automatically unregistered in response to `UIApplicationDidEnterBackgroundNotification` notification.
 */
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFFilePresenterCoordinator : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Shared instance of the coordinator.
@property(class, nonatomic, readonly) PSPDFFilePresenterCoordinator *sharedCoordinator;

/// Registers the specified file presenter object so that it can receive notifications.
- (void)observeFilePresenter:(id<NSFilePresenter>)filePresenter;

/// Unregisters the specified file presenter object.
- (void)unobserveFilePresenter:(id<NSFilePresenter>)filePresenter;

/// @name Collection helpers

/// Observers multiple objects at the same time.
- (void)observeFilePresenters:(nullable NSArray<id<NSFilePresenter>> *)filePresenters;

/// Unobserve multiple objects at the same time.
- (void)unobserveFilePresenters:(nullable NSArray<id<NSFilePresenter>> *)filePresenters;

@end

NS_ASSUME_NONNULL_END
