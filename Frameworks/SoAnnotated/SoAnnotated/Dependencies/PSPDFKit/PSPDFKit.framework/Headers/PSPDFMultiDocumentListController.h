//
//  PSPDFMultiDocumentListController.h
//  PSPDFKit
//
//  Copyright (c) 2015-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFBaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFMultiDocumentListController, PSPDFTabbedViewController;

PSPDF_AVAILABLE_DECL @protocol PSPDFMultiDocumentListControllerDelegate <NSObject>

@optional

/// Informs the delegate that the user selected a document from the list.
/// Typically, the presenting view controller will implement this method to dismiss the multi-document list controller.
/// @note The multi-document list controller automatically changes the visible document of its `tabbedViewController` at the same time as calling this method.
- (void)multiDocumentListController:(PSPDFMultiDocumentListController *)multiDocumentListController didSelectDocumentAtIndex:(NSUInteger)idx;

/// Informs the delegate that the user tapped the cancel button in the navigation bar containing the multi-document list controller.
/// By default, the multi-document list controller sets a cancel button as the `leftBarButtonItem` of its `navigationItem`.
/// This method will not be called if the multi-document list controller is not inside a navigation controller.
- (void)multiDocumentListControllerDidCancel:(PSPDFMultiDocumentListController *)multiDocumentListController;

@end

/// Shows a list of documents open in a `PSPDFTabbedViewController`.
/// This is the view controller used when tapping the `overviewButton` in a `PSPDFTabbedBar`.
PSPDF_CLASS_AVAILABLE @interface PSPDFMultiDocumentListController : PSPDFBaseTableViewController

/// The multi-document list controller’s delegate, which is typically the presenting view controller.
@property (nonatomic, weak) IBOutlet id<PSPDFMultiDocumentListControllerDelegate> delegate;

/// The tabbed view controller, which acts as a data source.
@property (nonatomic, weak) PSPDFTabbedViewController *tabbedViewController;

@end

NS_ASSUME_NONNULL_END
