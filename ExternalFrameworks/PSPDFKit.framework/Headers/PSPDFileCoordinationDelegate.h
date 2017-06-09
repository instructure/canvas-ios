//
//  PSPDFileCoordinationDelegate.h
//  PSPDFFoundation
//
//  Copyright © 2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

PSPDF_AVAILABLE_DECL @protocol PSPDFileCoordinationDelegate<NSObject>

/**
 Called after the underlaying file got modified.

 Corresponds to a `presentedItemDidChange` `NSFilePresenter` notification.

 @param presenter The requesting file presenter.
 */
- (void)presentedItemDidChangeForPresenter:(id<NSFilePresenter>)presenter;

/**
 Called when the underlaying file is about to be deleted.

 Corresponds to a `accommodatePresentedItemDeletionWithCompletionHandler:` `NSFilePresenter` notification.

 @param presenter The requesting file presenter.
 @param completionHandler Should be invoked to allow the deletion to continue.
 */
- (void)accommodatePresentedItemDeletionForPresenter:(id<NSFilePresenter>)presenter withCompletionHandler:(void (^)(NSError *_Nullable))completionHandler;

@end

NS_ASSUME_NONNULL_END
