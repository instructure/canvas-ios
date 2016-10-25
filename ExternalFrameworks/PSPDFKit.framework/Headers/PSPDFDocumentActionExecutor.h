//
//  PSPDFDocumentActionExecutor.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFDocumentSharingCoordinator.h"

#import "PSPDFControlDelegate.h"
#import "PSPDFOverridable.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument, PSPDFDocumentActionExecutor;

PSPDF_AVAILABLE_DECL @protocol PSPDFDocumentActionExecutorDelegate <PSPDFErrorHandler, PSPDFOverridable>

@optional

/// Allows to fetch defaults for actions.
- (NSDictionary<NSString *, id> *)documentActionExecutor:(PSPDFDocumentActionExecutor *)documentActionExecutor defaultOptionsForAction:(NSString *)action;

@end

/// @name Keys for `options`

/// Customize the sharing options. The default options will be used if not set.
PSPDF_EXPORT NSString *const PSPDFDocumentActionSharingOptionsKey;

/// Allows to customize the page range. By default all pages are used. Expects an `NSOrderedSet`.
PSPDF_EXPORT NSString *const PSPDFDocumentActionVisiblePagesKey;


/// @name Available actions

/// Presents the `UIPrintInteractionController`.
PSPDF_EXPORT NSString *const PSPDFDocumentActionPrint;

/// Presents the `MFMailComposeViewController`.
PSPDF_EXPORT NSString *const PSPDFDocumentActionEmail;

/// Presents the `UIDocumentInteractionController`.
PSPDF_EXPORT NSString *const PSPDFDocumentActionOpenIn;

/// Presents the `MFMessageComposeViewController`.
PSPDF_EXPORT NSString *const PSPDFDocumentActionMessage;


/// Helper class that can invoke common actions on the document.
PSPDF_CLASS_AVAILABLE @interface PSPDFDocumentActionExecutor : NSObject <PSPDFDocumentSharingCoordinatorDelegate>

/// Initialize with the controller we should present on.
/// Requires the controller to implement the `<PSPDFPresentationActions>` protocol to have additional control over presentation options.
/// @warning Will return nil if `sourceViewController` is nil.
- (instancetype)initWithSourceViewController:(UIViewController <PSPDFPresentationActions> *)sourceViewController NS_DESIGNATED_INITIALIZER;

PSPDF_EMPTY_INIT_UNAVAILABLE

/// The view controller from which the document action interface should be presented. Weakly held. If this is nil, actions will no longer work.
@property (nonatomic, weak, readonly) UIViewController <PSPDFPresentationActions> *sourceViewController;

/// Delegate to forward errors and also fetch the currently visible pages.
@property (nonatomic, weak) id <PSPDFDocumentActionExecutorDelegate> delegate;

/// The attached document this class operates on.
@property (nonatomic, nullable) PSPDFDocument *document;

/// Checks if `action` can be called. Returns NO on unknown actions, asserts if action is nil.
- (BOOL)canExecuteAction:(NSString *)action;

/// Executes `action` with `options` (optional). `sender` is optional as well.
/// Asserts if action is nil; will NOP if action is unknown.
/// `options` can contain `PSPDFDocumentActionVisiblePagesKey` and `PSPDFDocumentActionSharingOptionsKey`.
/// Also accepts presentation option keys.
- (void)executeAction:(NSString *)action options:(nullable NSDictionary<NSString *, id> *)options sender:(nullable id)sender animated:(BOOL)animated completion:(nullable void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
