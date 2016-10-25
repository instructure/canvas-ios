//
//  PSPDFNoteAnnotationViewController.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFStyleable.h"
#import "PSPDFBaseViewController.h"
#import "PSPDFOverridable.h"
#import "PSPDFPresentationActions.h"

@class PSPDFAnnotation, PSPDFPageView, PSPDFNoteAnnotationViewController;

NS_ASSUME_NONNULL_BEGIN

PSPDF_AVAILABLE_DECL @protocol PSPDFNoteAnnotationViewControllerDelegate <PSPDFOverridable>

@optional

/// Called when the `noteController` has deleted the annotation.
- (void)noteAnnotationController:(PSPDFNoteAnnotationViewController *)noteController didDeleteAnnotation:(PSPDFAnnotation *)annotation;

/// Called when the `noteController` has cleared the contents of the annotation.
- (void)noteAnnotationController:(PSPDFNoteAnnotationViewController *)noteController didClearContentsForAnnotation:(PSPDFAnnotation *)annotation;

/// Called when the `noteController` changes the annotation look. (color/iconName)
- (void)noteAnnotationController:(PSPDFNoteAnnotationViewController *)noteController didChangeAnnotation:(PSPDFAnnotation *)annotation;

/// Called before the `noteController` is closed.
- (void)noteAnnotationController:(PSPDFNoteAnnotationViewController *)noteController willDismissWithAnnotation:(nullable PSPDFAnnotation *)annotation;

@end

/// Note annotation controller for editing `PSPDFObjectsAnnotationsKey`.
/// For note annotations, special options will be displayed.
PSPDF_CLASS_AVAILABLE @interface PSPDFNoteAnnotationViewController : PSPDFBaseViewController <PSPDFStyleable>

/// Convenience initializer to initialize with an annotation.
/// @note Automatically sets the editable state based on the annotation `isEditable` property
/// And what is set in `document.editableAnnotationTypes`.
- (instancetype)initWithAnnotation:(PSPDFAnnotation *)annotation;

/// Attached annotation. All types are allowed.
@property (nonatomic, nullable) PSPDFAnnotation *annotation;

/// If NO, the Edit/Delete buttons are not displayed and the text will be readonly.
/// @note While you could set `allowEditing` here with a value different than the annotation, it's not advised to do so as the content won't be saved.
/// Use `annotation.isEditable` && `[configuration.editableAnnotationTypes containsObject:annotation.typeString]` to test for edit capabilities.
@property (nonatomic) BOOL allowEditing;

/// If YES, the edit button will be displayed to show color/icon editing. Defaults to YES.
/// Will be ignored if `allowEditing` is NO or annotation type is not `PSPDFAnnotationTypeNote`.
@property (nonatomic) BOOL showColorAndIconOptions;

/// Shows the copy button. Disabled by default for space reasons. (and because copying text is easy)
@property (nonatomic) BOOL showCopyButton;

/// If enabled, we enable the edit mode during controller presentation.
/// by calling `beginEditing` at the correct timing. Defaults to NO.
@property (nonatomic) BOOL shouldBeginEditModeWhenPresented;

/// Allow to customize the textView. (font etc)
/// @note The best way to customize the font is to use UIAppearance.
@property (nonatomic, readonly) UITextView *textView;

/// Attached delegate.
@property (nonatomic, weak) IBOutlet id<PSPDFNoteAnnotationViewControllerDelegate> delegate;

@end


@interface PSPDFNoteAnnotationViewController (SubclassingHooks)

/// Called when we're about to show the annotation delete menu.
- (void)deleteAnnotation:(UIBarButtonItem *)barButtonItem;

/// Will delete annotation (note) or clear note text (any other type) without confirmation.
- (void)deleteOrClearAnnotationWithoutConfirmation;

/// Returns "Delete Note" or "Remove Note" - depending if the annotation is a note annotation or a different type.
@property (nonatomic, readonly) NSString *deleteAnnotationActionTitle;

/// Sets the text view as first responder and enables editing if allowed.
/// Returns YES on success, false if not editable or first responder couldn't be set.
- (BOOL)beginEditing;

/// Called as we update the text view.
/// This can be used to update various text view properties like font.
/// @note An even better way is to use UIAppearance:
/// `[[UITextView appearanceWhenContainedIn:PSPDFNoteAnnotationViewController.class, nil] setFont:[UIFont fontWithName:@"Helvetica" size:20.f]];`
- (void)updateTextView NS_REQUIRES_SUPER;

/// Background gradient view.
@property (nonatomic, readonly) UIView *backgroundView;

/// Option view (note annotations)
@property (nonatomic, readonly) UIView *optionsView;

/// The border color of items in the option view.
@property (nonatomic, nullable) UIColor *borderColor;

/// Tap gesture on the `textView` to enable/disable edit mode.
@property (nonatomic, readonly) UITapGestureRecognizer *tapGesture;

/// Called initially and every time a property changes to re-build the toolbar.
- (void)setupToolbar;

/// Called whenever text is changed and after toolbar creation.
/// Used to control the delete button enabled state.
- (void)updateToolbar;

@end

NS_ASSUME_NONNULL_END
