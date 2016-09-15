//
//  PSPDFTabbedViewController.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFMultiDocumentViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocumentPickerController, PSPDFTabbedBar, PSPDFTabbedViewController;

typedef NS_ENUM(NSInteger, PSPDFTabbedViewControllerBarHidingMode) {
    /// Hide the tabbed bar only when there are no loaded documents.
    PSPDFTabbedViewControllerBarHidingModeAutomatic,
    /// Never hide the tabbed bar, even when there are no loaded documents.
    PSPDFTabbedViewControllerBarHidingModeShow,
    /// Always hide the tabbed bar, even if there are loaded documents.
    PSPDFTabbedViewControllerBarHidingModeHide,
} PSPDF_ENUM_AVAILABLE;

/// Delegate for the `PSPDFTabbedViewController`.
PSPDF_AVAILABLE_DECL @protocol PSPDFTabbedViewControllerDelegate <PSPDFMultiDocumentViewControllerDelegate>

@optional

/// Asks the delegate whether to change `visibleDocument` after a tab has been tapped. Defaults to accepting the change if this method is not implemented.
- (BOOL)tabbedPDFController:(PSPDFTabbedViewController *)tabbedPDFController shouldChangeVisibleDocument:(nullable PSPDFDocument *)newVisibleDocument;

/// Informs the delegate that `visibleDocument` has changed after a tab has been tapped.
- (void)tabbedPDFController:(PSPDFTabbedViewController *)tabbedPDFController didChangeVisibleDocument:(nullable PSPDFDocument *)oldVisibleDocument;

/// Asks the delegate whether to close a document after its close button has been tapped. Defaults to closing if this method is not implemented.
- (BOOL)tabbedPDFController:(PSPDFTabbedViewController *)tabbedPDFController shouldCloseDocument:(PSPDFDocument *)document;

/// Informs the delegate that a document has been closed after its close button has been tapped.
- (void)tabbedPDFController:(PSPDFTabbedViewController *)tabbedPDFController didCloseDocument:(PSPDFDocument *)document;

@end

/// Allows displaying multiple `PSPDFDocuments`, easily switchable via a top tab bar.
PSPDF_CLASS_AVAILABLE @interface PSPDFTabbedViewController : PSPDFMultiDocumentViewController

/// Inserts a document at the end of the tabbed bar, optionally making it the visible document.
/// If `documents` already contains `document` then it will not be added again, but may become visible.
- (void)addDocument:(PSPDFDocument *)document makeVisible:(BOOL)shouldMakeDocumentVisible animated:(BOOL)animated;

/// Inserts a document into the tabbed bar after the current visible document, optionally making it the new visible document.
/// If `documents` already contains `document` then it will not be inserted again or moved, but may become visible.
- (void)insertDocumentAfterVisibleDocument:(PSPDFDocument *)document makeVisible:(BOOL)shouldMakeDocumentVisible animated:(BOOL)animated;

/// Inserts a document into the tabbed bar at the specified index, optionally making it the visible document.
/// If `documents` already contains `document` then it will not be inserted again or moved, but may become visible.
- (void)insertDocument:(PSPDFDocument *)document atIndex:(NSUInteger)idx makeVisible:(BOOL)shouldMakeDocumentVisible animated:(BOOL)animated;

/// Removes a document at a specified index in `documents` from the tabbed bar.
/// Raises `NSRangeException` is `idx` is outside the range of `documents`.
- (void)removeDocumentAtIndex:(NSUInteger)idx animated:(BOOL)animated;

/// Removes a specified document from the tabbed bar.
/// Does nothing if `documents` does not contain `document`.
- (BOOL)removeDocument:(PSPDFDocument *)document animated:(BOOL)animated;

/// Changes the currently visible document and optionally scrolls the tabbed bar to make the new selected tab visible.
- (void)setVisibleDocument:(nullable PSPDFDocument *)visibleDocument scrollToPosition:(BOOL)scrollToPosition animated:(BOOL)animated;

/// Delegate to capture events.
@property (nonatomic, weak) IBOutlet id<PSPDFTabbedViewControllerDelegate> delegate;

/// Defaults to `PSPDFTabbedDocumentsPersistKey`.
/// Change if you use multiple instances of `PSPDFTabbedViewController`.
@property (nonatomic, copy) NSString *statePersistenceKey;

/// The bar that shows tabs for switching between documents. Its appearance is customizable.
@property (nonatomic, readonly) PSPDFTabbedBar *tabbedBar;

/// The document picker controller to be shown when the tabbed bar’s document picker button has been tapped.
/// The default is `nil`. Set this property to enable the document picker button.
/// If the document picker controller has no delegate at the time of presentation, the tabbed PDF controller will provide the delegate.
@property (nonatomic, nullable) PSPDFDocumentPickerController *documentPickerController;

/// Whether the tabbed bar should be shown or hidden depending on if there are loaded documents.
/// The default is `PSPDFTabbedViewControllerBarHidingModeAutomatic` if `documentPickerController` is `nil`,
/// or `PSPDFTabbedViewControllerBarHidingModeShow` if `documentPickerController` is non-nil.
@property (nonatomic) PSPDFTabbedViewControllerBarHidingMode barHidingMode;

/// A Boolean value that determines whether the user can close documents.
/// The default is `YES`, which allows the user to close documents (if the delegate also allows this change).
/// Set to `NO` to hide the close buttons in `PSPDFTabbedBar` and disable swipe-to-delete in `PSPDFMultiDocumentListController`.
@property (nonatomic) BOOL allowsClosingDocuments;

/// A Boolean value that determines whether a PDF action that opens another PDF document should show this document in a separate tab.
/// The default is `YES`.
/// If `NO`, the document of the current tab will be changed and the old visible document will be replaced in `documents`.
/// If the target document is already in `documents`, then the selected tab will change to show it whatever the value of this property.
@property (nonatomic) BOOL openDocumentActionInNewTab;

/// Updates the frame of the tabbed bar.
/// It is not usually necessary to call this, but do so if the navigation bar height changes, for example by setting a prompt while the tabbed bar is visible.
/// If the navigation bar has just started animating, this will animate the tabbed bar alongside.
- (void)updateTabbedBarFrameAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
