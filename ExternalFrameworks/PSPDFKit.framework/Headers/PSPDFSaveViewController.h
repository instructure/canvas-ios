//
//  PSPDFSaveViewController.h
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

@class PSPDFSaveViewController;

NS_ASSUME_NONNULL_BEGIN

PSPDF_AVAILABLE_DECL @protocol PSPDFSaveViewControllerDelegate <NSObject>

/// Called when the save or cancel button is pressed. The delegate should save the document requested.
- (void)saveViewControllerDidEnd:(PSPDFSaveViewController *)controller shouldSave:(BOOL)shouldSave;

@optional

/// Allows the delegate to conditionally allow or prevent saving. Called after the save button is invoked.
/// If a NSError object is assigned to the `error` reference, than an alert is shown with the error's
/// `localizedDescription` as content.
- (BOOL)saveViewControllerShouldSave:(PSPDFSaveViewController *)controller toPath:(NSString *)path error:(NSError **)error;

@end

/// Manages a UI for saving documents. Allows file naming and directory selection based on the `PSPDFDirectory` entires
/// from the passed in  `PSPDFDocumentEditorConfiguration` object.
/// @note This class requires the Document Editor component to be enabled for your license.
PSPDF_CLASS_AVAILABLE @interface PSPDFSaveViewController : PSPDFStaticTableViewController <PSPDFDocumentEditorConfigurationConfigurable>

PSPDF_DEFAULT_TABLEVIEWCONTROLLER_INIT_UNAVAILABLE

/// Initializes the controller with a document editor configuration and file path.
- (instancetype)initWithDocumentEditorConfiguration:(PSPDFDocumentEditorConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

/// Should be the object responsible for dismissal and perform the actual save operation.
@property (nonatomic, weak) id<PSPDFSaveViewControllerDelegate> delegate;

/// The desired file name. Might not always be a valid file name (may have illegal characters).
@property (nonatomic, copy, nullable) NSString *fileName;

/// The resulting full path with the PDF extension. Considers the filename and selected directory.
/// Will be `nil`, if `fileName` is not a valid.
@property (nonatomic, nullable, readonly) NSString *fullFilePath;

/// Shows a directory picker based on the `configuration` presets. Defaults to `YES`.
@property (nonatomic) BOOL showDirectoryPicker;

@end

NS_ASSUME_NONNULL_END
