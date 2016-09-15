//
//  PSPDFDocumentEditorViewController.h
//  PSPDFKit
//
//  Copyright (c) 2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>
#import "PSPDFViewModePresenter.h"
#import "PSPDFDocumentEditor.h"

@class PSPDFDocumentEditorToolbarController;

NS_ASSUME_NONNULL_BEGIN

/// The main view controller for document editing. Shows a collection view with page thumbnails that
/// reflect the document editor changes. Selection is performed on this object and the selection state
/// is than forwarded to `toolbarController`.
/// @note This class requires the Document Editor component to be enabled for your license.
PSPDF_CLASS_AVAILABLE @interface PSPDFDocumentEditorViewController : UICollectionViewController <PSPDFViewModePresenter, PSPDFDocumentEditorDelegate>

/// Class used for thumbnails. Defaults to `PSPDFDocumentEditorCell` and customizations should be a subclass of thereof.
/// @see `-[PSPDFViewModePresenter cellClass]`
@property (nonatomic) Class cellClass;

/// The associated document editor. Automatically generated when a document is assigned.
/// @note Will be nil, if the document is `nil` or document editing is not supported for that document.
@property (nonatomic, readonly, nullable) PSPDFDocumentEditor *documentEditor;

/// Manages the document editor toolbar.
/// @note The toolbar is not automatically displayed.
@property (nonatomic, readonly) PSPDFDocumentEditorToolbarController *toolbarController;

@end

NS_ASSUME_NONNULL_END
