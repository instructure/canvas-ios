//
//  PSPDFDocumentSharingCoordinator.h
//  PSPDFKit
//
//  Copyright © 2014-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFApplicationPolicy.h"
#import "PSPDFDocumentSharingViewController.h"
#import "PSPDFEnvironment.h"
#import "PSPDFFileManager.h"
#import "PSPDFOverridable.h"
#import "PSPDFPresentationActions.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument, PSPDFDocumentSharingCoordinator, PSPDFFile;
@protocol PSPDFApplicationPolicy;

/// Delegate for the document sharing coordinator.
PSPDF_AVAILABLE_DECL @protocol PSPDFDocumentSharingCoordinatorDelegate<PSPDFOverridable>

/**
 Callback when the document sharing coordinator finished.

 @param coordinator Corresponding `PSPDFDocumentSharingCoordinator` object.
 @param error Only set if the document sharing coordinator finished with an error.
 */
- (void)documentSharingCoordinator:(PSPDFDocumentSharingCoordinator *)coordinator didFinishWithError:(nullable NSError *)error;

@end

/**
 A document sharing coordinator represents a document action.
 This is an abstract class - see concrete implementations such as `PSPDFMailCoordinator`, `PSPDFPrintCoordinator` or `PSPDFExportCoordinator`.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFDocumentSharingCoordinator : NSObject<PSPDFDocumentSharingViewControllerDelegate>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Initialize with the documents.
- (instancetype)initWithDocuments:(NSArray<PSPDFDocument *> *)documents NS_DESIGNATED_INITIALIZER;

/// Initialize with a document.
- (instancetype)initWithDocument:(PSPDFDocument *)document PSPDF_DEPRECATED(6.2, "Use -initWithDocuments: instead.");

/// The documents this coordinator operates on.
@property (nonatomic, copy, readonly) NSArray<PSPDFDocument *> *documents;

/// Pages that should be offered for the sharing.
@property (nonatomic, copy, nullable) NSOrderedSet<NSNumber *> *visiblePageIndexes;

/// Attached delegate.
@property (nonatomic, weak) id<PSPDFDocumentSharingCoordinatorDelegate> delegate;

/// Defines what sharing options should be displayed.
@property (nonatomic) PSPDFDocumentSharingOptions sharingOptions;

/// Allows to check if the action can be performed.
@property (nonatomic, getter=isAvailable, readonly) BOOL available;

/// Indicates that a background operation is running.
@property (atomic, getter=isExecuting, readonly) BOOL executing;

/**
 Presents the view controller to `targetController`.
 @note Might work on a background thread to crunch the document before presenting the final view controller.
 */
- (void)presentToViewController:(nullable UIViewController<PSPDFPresentationActions> *)targetController options:(nullable NSDictionary<NSString *, id> *)options sender:(nullable id)sender animated:(BOOL)animated completion:(nullable void (^)(void))completion;

@end

@interface PSPDFDocumentSharingCoordinator (SubclassingHooks)

/// Title and action button are different for each subclass.
@property (nonatomic, copy, readonly) NSString *title;

/// Title for the commit button.
@property (nonatomic, copy, readonly) NSString *commitButtonTitle;

/// Policy event. Specified in `PSPDFApplicationPolicy.h`.
@property (nonatomic, copy, readonly) NSString *policyEvent;

/// Subclass hook to add custom checks.
- (BOOL)isAvailableUserInvoked:(BOOL)userInvoked error:(NSError **)error;

/// Hook to customize the sharing controller.
- (BOOL)configureSharingController:(PSPDFDocumentSharingViewController *)sharingController NS_REQUIRES_SUPER;

/// Sharing view controller, available when presented.
@property (nonatomic, readonly, weak) PSPDFDocumentSharingViewController *sharingController;

/// Present action controller. When overwritten, please call `documentSharingCoordinator:didFinishWithError:` when done.
- (void)showActionControllerToViewController:(UIViewController<PSPDFPresentationActions> *)targetController sender:(id)sender sendOptions:(PSPDFDocumentSharingOptions)sendOptions files:(NSArray<PSPDFFile *> *)files annotationSummary:(nullable NSAttributedString *)annotationSummary animated:(BOOL)animated;

@end

@interface PSPDFDocumentSharingCoordinator (Dependencies)

/// Application policy responsible for handling sharing permissions.
@property (nonatomic, nullable) id<PSPDFApplicationPolicy> policy;

/// File manager used for file operations.
@property (nonatomic, nullable) id<PSPDFFileManager> fileManager;

@end

NS_ASSUME_NONNULL_END
