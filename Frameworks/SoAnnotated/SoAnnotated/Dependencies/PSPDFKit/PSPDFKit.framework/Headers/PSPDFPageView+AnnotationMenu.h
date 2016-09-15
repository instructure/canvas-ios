//
//  PSPDFPageView+AnnotationMenu.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFPageView.h"
#import "PSPDFTextSelectionView.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFSignatureFormElement;

PSPDF_EXPORT const char *PSPDFImagePickerTargetPoint;

@interface PSPDFPageView (AnnotationMenu) <PSPDFSignatureViewControllerDelegate, PSPDFSignatureSelectorViewControllerDelegate, PSPDFAnnotationStyleViewControllerDelegate, PSPDFNoteAnnotationViewControllerDelegate, PSPDFFontPickerViewControllerDelegate, PSPDFTextSelectionViewDelegate>

/// Returns available `PSPDFMenuItem's` for the current annotation.
/// The better way to extend this is to use the `shouldShowMenuItems:*` delegates.
- (NSArray<PSPDFMenuItem *> *)menuItemsForAnnotations:(nullable NSArray<PSPDFAnnotation *> *)annotations;

/// Menu for new annotations (can be disabled in `PSPDFViewController`)
- (NSArray<PSPDFMenuItem *> *)menuItemsForNewAnnotationAtPoint:(CGPoint)point;

/// Returns available `PSPDFMenuItem's` to change the color.
/// The better way to extend this is to use the shouldShowMenuItems:* delegates.
- (NSArray<PSPDFMenuItem *> *)colorMenuItemsForAnnotation:(PSPDFAnnotation *)annotation;

/// Returns available `PSPDFMenuItem's` to change the fill color (only applies to certain annotations)
- (NSArray<PSPDFMenuItem *> *)fillColorMenuItemsForAnnotation:(PSPDFAnnotation *)annotation;

/// Returns the opacity menu item
- (PSPDFMenuItem *)opacityMenuItemForAnnotation:(PSPDFAnnotation *)annotation withColor:(nullable UIColor *)color;

/// Show the inspector.
/// `options` takes presentation option keys.
- (nullable PSPDFAnnotationStyleViewController *)showInspectorForAnnotations:(NSArray<PSPDFAnnotation *> *)annotations options:(nullable NSDictionary<NSString *, id> *)options animated:(BOOL)animated;

/// Called when an annotation is found at the tapped location.
/// This will usually call `menuItemsForAnnotation:` to show an `UIMenuController`, except for `PSPDFAnnotationTypeNote` which is handled differently on iPad. (`showNoteControllerForAnnotation`)
/// @note The better way to extend this is to use the `shouldShowMenuItems:*` delegates.
- (void)showMenuForAnnotations:(NSArray<PSPDFAnnotation *> *)annotations targetRect:(CGRect)targetRect allowPopovers:(BOOL)allowPopovers animated:(BOOL)animated;

/// Shows a popover/modal controller to edit a `PSPDFAnnotation`.
- (PSPDFNoteAnnotationViewController *)showNoteControllerForAnnotation:(PSPDFAnnotation *)annotation showKeyboard:(BOOL)showKeyboard animated:(BOOL)animated;

/// Shows the font picker.
- (void)showFontPickerForAnnotation:(PSPDFFreeTextAnnotation *)annotation animated:(BOOL)animated;

/// Shows the color picker.
- (void)showColorPickerForAnnotation:(PSPDFAnnotation *)annotation animated:(BOOL)animated;

/// Show the signature controller.
- (void)showSignatureControllerAtRect:(CGRect)viewRect withTitle:(nullable NSString *)title shouldSaveSignature:(BOOL)shouldSaveSignature options:(nullable NSDictionary *)options animated:(BOOL)animated;

/// Font sizes for the free text annotation menu. Defaults to `@[@10, @12, @14, @18, @22, @26, @30, @36, @48, @64]`
@property (nonatomic, readonly) NSArray<NSNumber *> *availableFontSizes;

/// Line width options (ink, border). Defaults to `@[@1, @3, @6, @9, @12, @16, @25, @40]`
@property (nonatomic, readonly) NSArray<NSNumber *> *availableLineWidths;

/// Returns the passthrough views for the popover controllers (e.g. color picker).
/// By default this is fairly aggressive and returns the `pdfController`/`navController`. If you dislike this behavior return nil to enforce the rule first touch after popover = no reaction. However the passthroughViews allow a faster editing of annotations.
@property (nonatomic, readonly) NSArray<__kindof UIView *> *passthroughViewsForPopoverController;

@end

@interface PSPDFPageView (AnnotationMenuSubclassingHooks)

/// Show signature menu.
- (void)showNewSignatureMenuAtRect:(CGRect)viewRect options:(nullable NSDictionary *)options animated:(BOOL)animated;

/// Show digital signature menu.
- (BOOL)showDigitalSignatureMenuForSignatureField:(PSPDFSignatureFormElement *)signatureField animated:(BOOL)animated;

/// Returns the default color options for the specified annotation type.
/// @note The default implementation uses colors from the style manager color presets for certain annotation types (e.g., PSPDFAnnotationTypeHighlight).
- (NSArray<UIColor *> *)defaultColorOptionsForAnnotationType:(PSPDFAnnotationType)annotationType;

/// Controls if the annotation inspector is used or manipulation via `UIMenuController`.
- (BOOL)useAnnotationInspectorForAnnotations:(NSArray<PSPDFAnnotation *> *)annotations;

/// Used to prepare the `UIMenuController`-based color menu.
- (void)selectColorForAnnotation:(PSPDFAnnotation *)annotation isFillColor:(BOOL)isFillColor;

/// By default, the highlight menu on iPad and iPhone is different, since on iPad there's more screen real estate - thus we pack the menu options into a "Style..." submenu on iPhone. Override this to customize the behavior. Returns `!PSPDFIsiPad();` by default.
@property (nonatomic, readonly) BOOL shouldMoveStyleMenuEntriesIntoSubmenu;

/// Will create and show the action sheet on long-press above a `PSPDFLinkAnnotation`.
/// Return YES if this was successful.
- (BOOL)showLinkPreviewActionSheetForAnnotation:(PSPDFLinkAnnotation *)annotation fromRect:(CGRect)viewRect animated:(BOOL)animated;

/// Show menu if annotation/text is selected.
- (void)showMenuIfSelectedAnimated:(BOOL)animated;
- (void)showMenuIfSelectedAnimated:(BOOL)animated allowPopovers:(BOOL)allowPopovers;

@end

/// Text Menu Items
PSPDF_EXPORT NSString *const PSPDFTextMenuCopy;
PSPDF_EXPORT NSString *const PSPDFTextMenuDefine;
PSPDF_EXPORT NSString *const PSPDFTextMenuSearch;
PSPDF_EXPORT NSString *const PSPDFTextMenuWikipedia;
PSPDF_EXPORT NSString *const PSPDFTextMenuCreateLink;
PSPDF_EXPORT NSString *const PSPDFTextMenuSpeak;
PSPDF_EXPORT NSString *const PSPDFTextMenuPause;
/// Text menu also uses PSPDFAnnotationMenu[Highlight|Underline|Strikeout|Squiggle].

/// General
/// Annotation types are used from PSPDFAnnotationString* defines
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuCancel;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuNote;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuGroup;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuUngroup;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuSave;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuRemove;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuCopy;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuPaste;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuMerge;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuPreviewFile; // File annotations

/// Annotation Style
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuInspector;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuStyle;       // Highlight annotations on iPhone

/// Colors
/// For menu colors, we use PSPDFAnnotationMenuColor_index_colorName.
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuColor;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuFillColor;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuOpacity;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuCustomColor; // Color Picker

/// Highlights
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuHighlightType; // Type
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuHighlight;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuUnderline;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuStrikeout;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuSquiggle;

/// Ink
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuThickness;

/// Sound annotations
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuPlay;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuPause;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuPauseRecording;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuContinueRecording;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuFinishRecording;

/// Free Text
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuEdit;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuSize;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuFont;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuAlignment;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuAlignmentLeft;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuAlignmentCenter;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuAlignmentRight;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuFitToText;

/// Line/Polyline
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuLineStart;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuLineEnd;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuLineTypeNone;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuLineTypeSquare;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuLineTypeCircle;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuLineTypeDiamond;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuLineTypeOpenArrow;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuLineTypeClosedArrow;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuLineTypeButt;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuLineTypeReverseOpenArrow;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuLineTypeReverseClosedArrow;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuLineTypeSlash;

/// Signature
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuMySignature;
PSPDF_EXPORT NSString *const PSPDFAnnotationMenuCustomerSignature;

NS_ASSUME_NONNULL_END
