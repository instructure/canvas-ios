//
//  PSPDFDocumentEditorToolbarController.h
//  PSPDFKit
//
//  Copyright (c) 2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFFlexibleToolbarController.h"
#import "PSPDFMacros.h"
#import "PSPDFFlexibleToolbarContainer.h"
#import "PSPDFDocumentEditor.h"
#import "PSPDFNewPageViewController.h"
#import "PSPDFSaveViewController.h"

@class PSPDFDocumentEditorToolbar, PSPDFDocumentEditorToolbarController;
@protocol PSPDFPresentationContext;

NS_ASSUME_NONNULL_BEGIN

/// Fired whenever the toolbar visibility changes.
PSPDF_EXPORT NSString *const PSPDFDocumentEditorToolbarControllerVisibilityDidChangeNotification;

/// Key inside the notification's userInfo.
PSPDF_EXPORT NSString *const PSPDFDocumentEditorToolbarControllerVisibilityAnimatedKey;

PSPDF_AVAILABLE_DECL @protocol PSPDFDocumentEditorToolbarControllerDelegate <PSPDFFlexibleToolbarContainerDelegate>

/// Called when the toolbar changes the selected pages. The delegate should update its state and UI for the new selection.
- (void)documentEditorToolbarController:(PSPDFDocumentEditorToolbarController *)controller didSelectPages:(NSSet<NSNumber *> *)pages;

@optional

/// Allows customization of the insertion point for new pages. Page page 0 is assumed, if not implemented.
- (NSUInteger)documentEditorToolbarController:(PSPDFDocumentEditorToolbarController *)controller indexForNewPageWithConfiguration:(PSPDFNewPageConfiguration *)configuration;

@end

/// Manages the document editor toolbar state and presents various document editing controllers.
/// @note This class requires the Document Editor component to be enabled for your license.
PSPDF_CLASS_AVAILABLE @interface PSPDFDocumentEditorToolbarController : PSPDFFlexibleToolbarController <PSPDFDocumentEditorDelegate, PSPDFNewPageViewControllerDelegate, PSPDFSaveViewControllerDelegate>

/// Initialize with a document editor toolbar.
- (instancetype)initWithDocumentEditorToolbar:(PSPDFDocumentEditorToolbar *)documentEditorToolbar;

/// Displayed document editor toolbar.
@property (nonatomic, readonly) PSPDFDocumentEditorToolbar *documentEditorToolbar;

/// The document editor on which the toolbar actions are performed.
@property (nonatomic, nullable) PSPDFDocumentEditor *documentEditor;

/// The page indexes of the pages that should be affected by actions that require page selection.
/// Should be set to an empty set when there are no selected items.
@property (nonatomic, copy) NSSet<NSNumber *> *selectedPages;

/// Forwards actions from internal handlers.
@property (nonatomic, weak) id<PSPDFDocumentEditorToolbarControllerDelegate> delegate;

/// Used for modal presentation, class overrides, etc.
@property (nonatomic, weak) id<PSPDFPresentationContext> presentationContext;

/// Configuration object with various controller options.
@property (nonatomic, readonly) PSPDFDocumentEditorConfiguration *documentEditorConfiguration;

/// @name Controllers

/// Shows or hides the new page view controller, depending on whether it is already visible.
/// @param sender A `UIView` or `UIBarButtonItem` used as the anchor view for the popover controller (iPad only).
/// @param options A dictionary of presentation options. See PSPDFPresentationActions.h for possible values.
- (nullable PSPDFNewPageViewController *)toggleNewPageController:(nullable id)sender presentationOptions:(nullable NSDictionary<NSString *, id> *)options;

/// Shows or hides an action sheet with save options (save, save as, and discard changes - depending on the document editor).
/// @param sender A `UIView` or `UIBarButtonItem` used as the anchor view for the popover controller (iPad only).
/// @param options A dictionary of presentation options. See PSPDFPresentationActions.h for possible values.
/// @param completionHandler A completion callback, called when saving completes. Might be called after the save controller completes if "Save As..." is selected. If `cancelled` is yes, the save flow was interrupted.
- (nullable UIAlertController *)toggleSaveActionSheet:(nullable id)sender presentationOptions:(nullable NSDictionary<NSString *, id> *)options completionHandler:(nullable void(^)(BOOL cancelled))completionHandler;

/// Shows or hides a view controller with saving options.
/// @param sender A `UIView` or `UIBarButtonItem` used as the anchor view for the popover controller (iPad only).
/// @param options A dictionary of presentation options. See PSPDFPresentationActions.h for possible values.
/// @param completionHandler A completion callback, called when saving completes. If `cancelled` is yes, the save flow was interrupted.
- (nullable PSPDFSaveViewController *)toggleSaveController:(nullable id)sender presentationOptions:(nullable NSDictionary<NSString *, id> *)options completionHandler:(nullable void(^)(BOOL cancelled))completionHandler;

@end

NS_ASSUME_NONNULL_END
