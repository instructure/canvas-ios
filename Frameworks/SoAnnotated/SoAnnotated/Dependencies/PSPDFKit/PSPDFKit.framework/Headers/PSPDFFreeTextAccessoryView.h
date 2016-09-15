//
//  PSPDFFreeTextAccessoryView.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFToolbar.h"
#import "PSPDFFontPickerViewController.h"
#import "PSPDFAnnotationStyleViewController.h"
#import "PSPDFPresentationContext.h"

@class PSPDFFreeTextAnnotation, PSPDFFreeTextAccessoryView, PSPDFToolbarButton;
@class PSPDFToolbarSelectableButton, PSPDFToolbarSeparatorButton, PSPDFPresentationContext;

NS_ASSUME_NONNULL_BEGIN

/// Notification when someone presses "Clear".
PSPDF_EXPORT NSString *const PSPDFFreeTextAccessoryViewDidPressClearButtonNotification;

/// Delegate to receive actions from the free text accessory view.
PSPDF_AVAILABLE_DECL @protocol PSPDFFreeTextAccessoryViewDelegate <NSObject>

@optional

/// Called when the done button is pressed.
/// You should resign first responder status at this point.
- (void)doneButtonPressedOnFreeTextAccessoryView:(PSPDFFreeTextAccessoryView *)inputView;

/// Called when the clear text button is pressed.
/// Use this to clear the text field and update the annotation.
- (void)clearButtonPressedOnFreeTextAccessoryView:(PSPDFFreeTextAccessoryView *)inputView;

/// Show the text inspector (relevant only if the inspector button is used - only on iPhone by default).
- (nullable PSPDFAnnotationStyleViewController *)freeTextAccessoryViewDidRequestInspector:(PSPDFFreeTextAccessoryView *)inputView;

/// Allow or reject a property change. Assumes always YES if left unimplemented.
- (BOOL)freeTextAccessoryView:(PSPDFFreeTextAccessoryView *)styleController shouldChangeProperty:(NSString *)propertyName;

/// Called whenever a style property of `PSPDFFreeTextAccessoryView` changes.
/// Use this to also update the annotation bounding box and view frames as needed.
- (void)freeTextAccessoryView:(PSPDFFreeTextAccessoryView *)styleController didChangeProperty:(NSString *)propertyName;

@end

/// Free Text accessory toolbar for faster styling.
PSPDF_CLASS_AVAILABLE @interface PSPDFFreeTextAccessoryView : PSPDFToolbar <PSPDFFontPickerViewControllerDelegate, PSPDFAnnotationStyleViewControllerDelegate>

/// The input accessory delegate.
@property (nonatomic, weak) id<PSPDFFreeTextAccessoryViewDelegate> delegate;

/// Used to present popover pickers for certain button types.
@property (nonatomic, weak) id <PSPDFPresentationContext> presentationContext;

/// The annotation that is being edited.
@property (nonatomic) PSPDFFreeTextAnnotation *annotation;

/// @name Customization

/// List of supported inspector properties for various annotation types
/// Dictionary in format annotation type string : array of arrays of property strings (`NSArray<NSArray<NSString *> *> *`) OR a block that returns this and takes `annotations` as argument (`NSArray<NSArray<NSString *> *> *(^block)(PSPDFAnnotation *annotation)`).
/// @note Only the `PSPDFAnnotationStringFreeText` key is relevant for this component.
/// Defaults to an empty dictionary. Normally set to the values from PSPDFConfiguration after initialization.
@property (nonatomic, copy) NSDictionary<NSString *, id> *propertiesForAnnotations;

/// @name Styling

/// Whether a thing border should be added just above the accessory view. Defaults to YES.
@property (nonatomic, getter=isBorderVisible) BOOL borderVisible;

/// The color for the default separators and border.
@property (nonatomic) UIColor *separatorColor UI_APPEARANCE_SELECTOR;

@end

@interface PSPDFFreeTextAccessoryView (SubclassingHooks)

/// By default the accessory view buttons differ based on the available toolbar width.
/// Use this to customize the button order or fixate a certain set of buttons.
/// @note The default arrays include `PSPDFToolbarSeparatorButton` and `PSPDFToolbarSpacerButton` objects.
- (NSArray<__kindof PSPDFToolbarButton *> *)buttonsForWidth:(CGFloat)width;

/// This is called on size changes and when the free text accessory is deallocated.
/// If you present your own controller, add custom logic here to ensure it's dismissed.
- (void)dismissPresentedViewControllersAnimated:(BOOL)animated NS_REQUIRES_SUPER;

/// @name Default toolbar buttons.

@property (nonatomic, readonly) PSPDFToolbarButton *fontNameButton;
@property (nonatomic, readonly) PSPDFToolbarButton *fontSizeButton;
@property (nonatomic, readonly) PSPDFToolbarButton *increaseFontSizeButton;
@property (nonatomic, readonly) PSPDFToolbarButton *decreaseFontSizeButton;
@property (nonatomic, readonly) PSPDFToolbarSelectableButton *leftAlignButton;
@property (nonatomic, readonly) PSPDFToolbarSelectableButton *centerAlignButton;
@property (nonatomic, readonly) PSPDFToolbarSelectableButton *rightAlignButton;
@property (nonatomic, readonly) PSPDFToolbarButton *colorButton;
@property (nonatomic, readonly) PSPDFToolbarButton *clearButton;
@property (nonatomic, readonly) PSPDFToolbarButton *doneButton;

@end

NS_ASSUME_NONNULL_END
