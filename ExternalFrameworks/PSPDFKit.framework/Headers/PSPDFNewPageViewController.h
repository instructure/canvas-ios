//
//  PSPDFNewPageViewController.h
//  PSPDFKit
//
//  Copyright (c) 2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFStaticTableViewController.h"
#import "PSPDFDocumentEditorConfiguration.h"
#import "PSPDFOverridable.h"

@class PSPDFNewPageViewController, PSPDFNewPageConfiguration;

NS_ASSUME_NONNULL_BEGIN

/// Delegate that allows connecting a `PSPDFNewPageViewController` to
/// receive the event when a selection has been chosen.
PSPDF_AVAILABLE_DECL @protocol PSPDFNewPageViewControllerDelegate <NSObject, PSPDFOverridable>

/// Called when the selection process completes (i.e., the commit button is pressed).
/// The delegate should dismiss the view controller at this point.
/// New page action should be ignored if `configuration` is `nil`.
- (void)newPageController:(PSPDFNewPageViewController *)controller didFinishSelectingConfiguration:(nullable PSPDFNewPageConfiguration *)configuration;

@end

/// Manages new selection of various configuration options for new PDF pages. Builds the user interface
/// based on the passed in `configuration` object.
/// @note This class requires the Document Editor component to be enabled for your license.
PSPDF_CLASS_AVAILABLE @interface PSPDFNewPageViewController : PSPDFStaticTableViewController <PSPDFDocumentEditorConfigurationConfigurable>

PSPDF_DEFAULT_TABLEVIEWCONTROLLER_INIT_UNAVAILABLE

/// Initializes the controller with a configuration library.
- (instancetype)initWithDocumentEditorConfiguration:(PSPDFDocumentEditorConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

/// Receives notifications about the new page view controller state.
@property (nonatomic, weak) id<PSPDFNewPageViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
