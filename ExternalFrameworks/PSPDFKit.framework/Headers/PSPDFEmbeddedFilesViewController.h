//
//  PSPDFEmbeddedFilesViewController.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFStatefulTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument, PSPDFEmbeddedFilesViewController, PSPDFEmbeddedFile;

/// Delegate for the `PSPDFEmbeddedFilesViewController`.
PSPDF_AVAILABLE_DECL @protocol PSPDFEmbeddedFilesViewControllerDelegate <NSObject>

/// Will be called when the user touches an annotation cell.
- (void)embeddedFilesController:(PSPDFEmbeddedFilesViewController *)embeddedFilesController didSelectFile:(PSPDFEmbeddedFile *)embeddedFile sender:(nullable id)sender;

@end

/// Shows a list of all embedded files.
PSPDF_CLASS_AVAILABLE @interface PSPDFEmbeddedFilesViewController : PSPDFStatefulTableViewController

/// Designated initializer.
- (instancetype)initWithDocument:(PSPDFDocument *)document NS_DESIGNATED_INITIALIZER;

/// Attached document.
@property (nonatomic) PSPDFDocument *document;

/// The delegate.
@property (nonatomic, weak) IBOutlet id<PSPDFEmbeddedFilesViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
