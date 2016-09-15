//
//  PSPDFAnnotationToolbar.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFFlexibleToolbar.h"
#import "PSPDFAnnotationStateManager.h"

@class PSPDFAnnotationToolbar, PSPDFAnnotationToolbarConfiguration, PSPDFColorButton, PSPDFToolbarDualButton;

NS_ASSUME_NONNULL_BEGIN

/// The annotation toolbar allows the creation of most annotation types supported by PSPDFKit.
///
/// To customize which annotation icons should be displayed, edit `editableAnnotationTypes` in PSPDFDocument.
/// Further appearance customization options are documented in the superclass header (`PSPDFFlexibleToolbar.h`).
///
/// `PSPDFAnnotationToolbar` needs to be used together with a `PSPDFFlexibleToolbarContainerView` just like its superclass `PSPDFFlexibleToolbar`.
 ///
/// @note Directly updating `buttons` will not work. Use `additionalButtons` if you want to add custom buttons.
PSPDF_CLASS_AVAILABLE @interface PSPDFAnnotationToolbar : PSPDFFlexibleToolbar <PSPDFAnnotationStateManagerDelegate>

PSPDF_DEFAULT_VIEW_INIT_UNAVAILABLE

/// Designated initializer.
- (instancetype)initWithAnnotationStateManager:(PSPDFAnnotationStateManager *)annotationStateManager NS_DESIGNATED_INITIALIZER;

/// Attached annotation state manager.
@property (nonatomic) PSPDFAnnotationStateManager *annotationStateManager;

/// The annotation types that may be shown in the annotation toolbar.
/// In the default state, and if set to `nil`, this will return `pdfController.configuration.editableAnnotationTypes`.
/// KVO observable.
@property (nonatomic, copy, null_resettable) NSSet<NSString *> *editableAnnotationTypes;

/// @name Configuration

/// Specifies a list of toolbar configurations amongst which the toolbar can pick when laying out items.
/// The toolbar automatically picks an appropriate configuration based on the available space.
/// Items are grouped by default. Set to `nil` to disable grouping. In that case the toolbar will be populated
/// by ungrouped items based based on `editableAnnotationTypes`.
/// @note Annotation types that are present in a toolbar configuration but missing in
/// `editableAnnotationTypes` will be not be shown.
@property (nonatomic, copy, nullable) NSArray<PSPDFAnnotationToolbarConfiguration *> *configurations;

/// Returns `annotationGroups` based on the selected configuration if set,
/// or implicitly created groups based on `editableAnnotationTypes`.
@property (nonatomic, readonly) NSArray<__kindof PSPDFAnnotationGroup *> *annotationGroups;

/// @name Buttons

/// Access to buttons created based on the state of `annotationGroups`.
/// If `createFromGroup` is set to `YES`, the toolbar will automatically update and display the queried button,
/// in case it was previously not the chosen item in the corresponding annotation group.
- (UIButton *)buttonWithType:(NSString *)type variant:(nullable NSString *)variant createFromGroup:(BOOL)createFromGroup;

/// Allows custom `UIButton` objects to be added after the buttons in `annotationGroups`.
/// For best results use `PSPDFToolbarButton` objects. Defaults to nil.
/// @note The buttons should have unique accessibility labels so we can show them in a menu if needed.
@property (nonatomic, copy, nullable) NSArray<__kindof UIButton *> *additionalButtons;

/// Collapses the undo and redo buttons into one button for smaller toolbar sizes. Defaults to `YES`.
/// @note This currently just hides the redo button.
@property (nonatomic) BOOL collapseUndoButtonsForCompactSizes;

/// @name Behavior

/// This will issue a save event after the toolbar has been dismissed.
/// @note Since saving can take some time, this defaults to NO.
@property (nonatomic) BOOL saveAfterToolbarHiding;

@end

/// Standard toolbar buttons (return nil if you don't want them).
@interface PSPDFAnnotationToolbar (SubclassingHooks)

/// Dismisses the annotation toolbar.
/// @note Not `nil` by default, but can be overridden to return `nil` to remove it from the toolbar.
@property (nonatomic, readonly, nullable) UIButton *doneButton;

/// Undos the last action.
/// @note Not `nil` by default, but can be overridden to return `nil` to remove it from the toolbar.
@property (nonatomic, readonly, nullable) UIButton *undoButton;

/// Redos the last action.
/// @note Not `nil` by default, but can be overridden to return `nil` to remove it from the toolbar.
@property (nonatomic, readonly, nullable) UIButton *redoButton;

/// Shows a menu with undo / redo options. Used in compact sizes instead of `undoButton` and `redoButton`.
/// @note Not `nil` by default, but can be overridden to return `nil` to remove it from the toolbar.
@property (nonatomic, readonly, nullable) PSPDFToolbarDualButton *undoRedoButton;

/// Shows the annotation inspector for the selected annotation type. Hidden (but not removed), if a relevant type
/// is currently not selected. Only added to the toolbar, if the toolbar contains buttons for supported annotation types.
/// @note Not `nil` by default, but can be override to return `nil` to remove it from the toolbar.
@property (nonatomic, readonly, nullable) PSPDFColorButton *strokeColorButton;

/// The done action.
- (void)done:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
