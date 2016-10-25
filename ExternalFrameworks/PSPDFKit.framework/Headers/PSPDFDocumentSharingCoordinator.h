//
//  PSPDFDocumentSharingCoordinator.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFDocumentSharingViewController.h"
#import "PSPDFOverridable.h"
#import "PSPDFPresentationActions.h"
#import "PSPDFApplicationPolicy.h"
#import "PSPDFFileManager.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument, PSPDFDocumentSharingCoordinator, PSPDFFile;
@protocol PSPDFApplicationPolicy;

PSPDF_AVAILABLE_DECL @protocol PSPDFDocumentSharingCoordinatorDelegate <PSPDFOverridable>

- (void)documentSharingCoordinator:(PSPDFDocumentSharingCoordinator *)coordinator didFailWithError:(NSError *)error;

@end

/// A document sharing coordinator represents a document action.
/// This is an abstract class - see concrete implementations such as `PSPDFMailCoordinator` or `PSPDFPrintCoordinator`.
PSPDF_CLASS_AVAILABLE @interface PSPDFDocumentSharingCoordinator : NSObject <PSPDFDocumentSharingViewControllerDelegate>

PSPDF_EMPTY_INIT_UNAVAILABLE

// Initialize with a document.
- (instancetype)initWithDocument:(PSPDFDocument *)document NS_DESIGNATED_INITIALIZER;

/// The document this coordinator operates on.
@property (nonatomic, readonly) PSPDFDocument *document;

/// Pages that should be offered for the sharing.
@property (nonatomic, copy, nullable) NSOrderedSet<NSNumber *> *visiblePages;

/// Attached delegate.
@property (nonatomic, weak) id <PSPDFDocumentSharingCoordinatorDelegate> delegate;

/// Defines what sharing options should be displayed.
@property (nonatomic) PSPDFDocumentSharingOptions sharingOptions;

/// Allows to check if the action can be performed.
@property (nonatomic, getter=isAvailable, readonly) BOOL available;

/// Indicates that a background operation is running.
@property (atomic, getter=isExecuting, readonly) BOOL executing;

/// Presents the view controller to `targetController`.
/// @note Might work on a background thread to crunch the document before presenting the final view controller.
- (void)presentToViewController:(nullable UIViewController <PSPDFPresentationActions> *)targetController options:(nullable NSDictionary<NSString *, id> *)options sender:(nullable id)sender animated:(BOOL)animated completion:(nullable void (^)(void))completion;

@end

@interface PSPDFDocumentSharingCoordinator (SubclassingHooks)

/// Title and action button are different for each subclass.
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *commitButtonTitle;
@property (nonatomic, copy, readonly) NSString *policyEvent;

/// Subclass to add custom checks.
- (BOOL)isAvailableUserInvoked:(BOOL)userInvoked error:(NSError **)error;

/// Hook to customize the sharing controller.
- (BOOL)configureSharingController:(PSPDFDocumentSharingViewController *)sharingController NS_REQUIRES_SUPER;

@property (nonatomic, readonly, nullable) PSPDFDocumentSharingViewController *sharingController;

- (void)showActionControllerToViewController:(UIViewController <PSPDFPresentationActions> *)targetController sender:(id)sender sendOptions:(PSPDFDocumentSharingOptions)sendOptions files:(NSArray<PSPDFFile *> *)files annotationSummary:(nullable NSAttributedString *)annotationSummary animated:(BOOL)animated;

@end

@interface PSPDFDocumentSharingCoordinator (Dependencies)

@property (nonatomic, nullable) id<PSPDFApplicationPolicy> policy;
@property (nonatomic, nullable) id<PSPDFFileManager> fileManager;

@end

NS_ASSUME_NONNULL_END
