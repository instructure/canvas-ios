//
//  PSPDFDocumentEditorToolbar.h
//  PSPDFKit
//
//  Copyright (c) 2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFFlexibleToolbar.h"

@class PSPDFToolbarButton;

NS_ASSUME_NONNULL_BEGIN

/// A flexible toolbar with various document editing functions. 
/// @note This class requires the Document Editor component to be enabled for your license.
PSPDF_CLASS_AVAILABLE @interface PSPDFDocumentEditorToolbar : PSPDFFlexibleToolbar

/// Preset button for showing the new page UI.
@property (nonatomic, readonly) PSPDFToolbarButton *addPageButton;

/// Preset button for deleting selected pages.
@property (nonatomic, readonly) PSPDFToolbarButton *deletePagesButton;

/// Preset button for duplicating selected pages.
@property (nonatomic, readonly) PSPDFToolbarButton *duplicatePagesButton;

/// Preset button for rotating selected pages 90 clockwise.
@property (nonatomic, readonly) PSPDFToolbarButton *rotatePagesButton;

/// Preset button for exporting selected pages into a new PDF file.
@property (nonatomic, readonly) PSPDFToolbarButton *exportPagesButton;

/// Preset button for selecting or deselecting all pages.
/// @see `allPagesSelected`.
@property (nonatomic, readonly) PSPDFToolbarButton *selectAllPagesButton;

/// Preset button for undoing the last change.
@property (nonatomic, readonly) PSPDFToolbarButton *undoButton;

/// Preset button for redoing the last undo action.
@property (nonatomic, readonly) PSPDFToolbarButton *redoButton;

/// Preset button for dismissing or showing the save UI if changes were made.
@property (nonatomic, readonly) PSPDFToolbarButton *doneButton;

/// Toggles beteen the select all and select none state for `selectAllPagesButton`.
@property (nonatomic) BOOL allPagesSelected;

@end

@interface PSPDFDocumentEditorToolbar (SubclassingHooks)

/// Subclassing hook that allows customization of the visible buttons for the given toolbar width.
/// Call `super` and modify the returned array or construct your own toolbar using the preset buttons.
- (NSArray<__kindof PSPDFToolbarButton *> *)buttonsForWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
