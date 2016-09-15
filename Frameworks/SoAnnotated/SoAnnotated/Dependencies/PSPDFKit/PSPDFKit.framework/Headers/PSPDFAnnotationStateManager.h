//
//  PSPDFAnnotationStateManager.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>

#import "PSPDFViewController.h"
#import "PSPDFAbstractLineAnnotation.h"
#import "PSPDFDrawView.h"
#import "PSPDFMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFAnnotationStyleViewController;

/// Allows to customize what image quality options we offer for adding image annotations.
typedef NS_OPTIONS(NSUInteger, PSPDFImageQuality) {
    PSPDFImageQualityLow    = 1 << 0,
    PSPDFImageQualityMedium = 1 << 1,
    PSPDFImageQualityHigh   = 1 << 2,
    PSPDFImageQualityAll    = NSUIntegerMax
} PSPDF_ENUM_AVAILABLE;

@class PSPDFAnnotationStateManager, PSPDFToolbarButton;

/// Special type of "annotation" that will add an eraser feature to the toolbar.
PSPDF_EXPORT NSString *const PSPDFAnnotationStringEraser;

/// Special type that will add a selection tool to the toolbar.
PSPDF_EXPORT NSString *const PSPDFAnnotationStringSelectionTool;

/// Special type that will show a view controller with saved/pre-created annotations.
/// Currently this will also require `PSPDFAnnotationStringStamp` to be displayed.
PSPDF_EXPORT NSString *const PSPDFAnnotationStringSavedAnnotations;

/// The annotation state manager delegate allows to react to state changes.
/// @note The manager class supports registering multiple delegate implementations.
PSPDF_AVAILABLE_DECL @protocol PSPDFAnnotationStateManagerDelegate <NSObject>

@optional

/// Called before the manager's `state` and or `variant` attribute changes.
/// As a convenience it also provides access the current `state` and `variant`.
/// If any of the delegates returns `NO`, the state change won't be applied. 
- (BOOL)annotationStateManager:(PSPDFAnnotationStateManager *)manager shouldChangeState:(nullable NSString *)state to:(nullable NSString *)newState variant:(nullable NSString *)variant to:(nullable NSString *)newVariant;

/// Called after the manager's `state` and or `variant` attribute changes.
/// As a convenience it also provides access the previous `state` and `variant` for any state-related cleanup.
- (void)annotationStateManager:(PSPDFAnnotationStateManager *)manager didChangeState:(nullable NSString *)state to:(nullable NSString *)newState variant:(nullable NSString *)variant to:(nullable NSString *)newVariant;

/// Called when the internal undo state changes (pdfController.undoManager state changes or uncommitted drawing related changes).
- (void)annotationStateManager:(PSPDFAnnotationStateManager *)manager didChangeUndoState:(BOOL)undoEnabled redoState:(BOOL)redoEnabled;

@end

/// `PSPDFAnnotationStateManager` holds the current annotation state and configures the associated `PSPDFViewController` to accept input related to the currently selected annotation state. The class also provides several convenience methods and user interface components required for annotation creation and configuration.
///
/// Interested parties can use KVO to observe the manager's properties.
///
/// You should never use more than one `PSPDFAnnotationStateManager` for any given `PSPDFViewController`. It's recommended to use `-[PSPDFViewController annotationStateManager]` instead of creating your own one in order to make sure this requirement is always met.
///
/// `PSPDFAnnotationStateManager` is internally used by `PSPDFAnnotationToolbar` and can be re-used for any custom annotation related user interfaces.
///
/// @note Do not create this class yourself. Use the existing class that is exposed in the `PSPDFViewController.`
PSPDF_CLASS_AVAILABLE @interface PSPDFAnnotationStateManager : NSObject <PSPDFOverridable>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Attached pdf controller.
@property (nonatomic, weak, readonly) PSPDFViewController *pdfController;

/// Adds an annotation state delegate to the subscriber list.
/// @note Delegates are weakly retained, but be a good citizen and manually deregister.
- (void)addDelegate:(id <PSPDFAnnotationStateManagerDelegate>)delegate;

/// Removes an annotation state delegate from the subscriber list.
- (BOOL)removeDelegate:(id <PSPDFAnnotationStateManagerDelegate>)delegate;

/// Active annotation state. State is an annotation type, e.g. `PSPDFAnnotationStringHighlight`.
/// @note Setting a state will temporarily disable the long press gesture recognizer on the `PSPDFScrollView` to disable the new annotation menu. Setting the state on it's own resets the variant to nil.
@property (nonatomic, copy, nullable) NSString *state;

/// Sets the specified state, if it differs from the currently set `state`, otherwise sets the `state` to `nil`.
/// @note This will load the previous used color into `drawColor` and set all other options like `lineWidth`.
/// Set these value AFTER setting the state if you want to customize them, or set the default in `PSPDFStyleManager`
- (void)toggleState:(NSString *)state;

/// Sets the annotation variant for the current state.
/// States with different variants uniquely preserve the annotation style settings.
/// This is handy for defining multiple tools of the same annotation type, each with different style settings.
@property (nonatomic, copy, nullable) NSString *variant;

/// Sets the state and variant at the same time.
/// @see state, variant
- (void)setState:(nullable NSString *)state variant:(nullable NSString *)variant;

/// Toggles the and variant at the same time.
/// If the state and variant both match the currently set values, it sets both to `nil`.
/// Convenient for selectable toolbar buttons.
- (void)toggleState:(nullable NSString *)state variant:(nullable NSString *)variant;

/// String identifier used as the persistence key for the current state - variant combination.
@property (nonatomic, copy, readonly) NSString *stateVariantIdentifier;

/// Input mode (draw or erase) for `PSPDFDrawView` instances. Defaults to `PSPDFDrawViewInputModeDraw`.
@property (nonatomic) PSPDFDrawViewInputMode drawingInputMode;

/// Default/current drawing color. KVO observable.
/// Defaults to `[UIColor colorWithRed:0.121f green:0.35f blue:1.f alpha:1.f]`
/// @note PSPDFKit will save the last used drawing color in the NSUserDefaults.
/// If you want to change the default value, use `-[PSPDFAnnotationStyleManager setLastUsedValue:forProperty:forKey:]`.
@property (nonatomic, nullable) UIColor *drawColor;

/// Default/current fill color. KVO observable.
/// Defaults to nil.
/// @note PSPDFKit will save the last used fill color in the NSUserDefaults.
/// If you want to change the default value, use `-[PSPDFAnnotationStyleManager setLastUsedValue:forProperty:forKey:]`.
@property (nonatomic, nullable) UIColor *fillColor;

/// Current drawing line width. Defaults to 3.f. KVO observable.
/// @note PSPDFKit will save the last used line width in the NSUserDefaults.
/// If you want to change the default value, use `-[PSPDFAnnotationStyleManager setLastUsedValue:forProperty:forKey:]`.
@property (nonatomic) CGFloat lineWidth;

/// Starting line end type for lines and polylines. KVO observable.
/// @note PSPDFKit will save the last used line end in the NSUserDefaults.
/// If you want to change the default value, use `-[PSPDFAnnotationStyleManager setLastUsedValue:forProperty:forKey:]`.
@property (nonatomic) PSPDFLineEndType lineEnd1;

/// Ending line end type for lines and polylines. KVO observable.
/// @note PSPDFKit will save the last used line end in the NSUserDefaults.
/// If you want to change the default value, use `-[PSPDFAnnotationStyleManager setLastUsedValue:forProperty:forKey:]`.
@property (nonatomic) PSPDFLineEndType lineEnd2;

/// The stroke dash pattern. Draws a solid line when `nil` (default).
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *dashArray;

/// Font name for free text annotations. KVO observable.
/// @note PSPDFKit will save the last used font name in the NSUserDefaults.
/// If you want to change the default value, use `-[PSPDFAnnotationStyleManager setLastUsedValue:forProperty:forKey:]`.
@property (nonatomic, copy, nullable) NSString *fontName;

/// Font size for free text annotations. KVO observable.
/// @note PSPDFKit will save the last used font size in the NSUserDefaults.
/// If you want to change the default value, use `-[PSPDFAnnotationStyleManager setLastUsedValue:forProperty:forKey:]`.
@property (nonatomic) CGFloat fontSize;

/// Text alignment for free text annotations. KVO observable.
/// @note PSPDFKit will save the last used text alignment in the NSUserDefaults.
/// If you want to change the default value, use `-[PSPDFAnnotationStyleManager setLastUsedValue:forProperty:forKey:]`.
@property (nonatomic) NSTextAlignment textAlignment;

/// Allows to customize the offered image qualities.
/// Defaults to `PSPDFImageQualityAll`.
@property (nonatomic) PSPDFImageQuality allowedImageQualities;

/// Shows the style picker for the current annotation class and configures it with annotation state manager style attributes.
/// @param sender A `UIView` or `UIBarButtonItem` used as the anchor view for the popover controller (iPad only).
/// @param options A dictionary of presentation options. See PSPDFPresentationActions.h for possible values.
/// @note This will change style properties on this annotation state manager.
- (nullable PSPDFAnnotationStyleViewController *)toggleStylePicker:(nullable id)sender presentationOptions:(nullable NSDictionary<NSString *, id> *)options;

/// Displays a `PSPDFSignatureViewController` and toggles the state to `PSPDFAnnotationStringSignature`.
/// @param sender A `UIView` or `UIBarButtonItem` used as the anchor view for the popover controller (iPad only).
/// @param options A dictionary of presentation options. See PSPDFPresentationActions.h for possible values.
- (nullable UIViewController *)toggleSignatureController:(nullable id)sender presentationOptions:(nullable NSDictionary<NSString *, id> *)options;

/// Displays a `PSPDFStampViewController` and toggles the state to `PSPDFAnnotationStringStamp`.
/// @param sender A `UIView` or `UIBarButtonItem` used as the anchor view for the popover controller (iPad only).
/// @param includeSavedAnnotations Whether to include saved annotation using PSPDFSavedAnnotationsViewController or not.
/// @param options A dictionary of presentation options. See PSPDFPresentationActions.h for possible values.
- (nullable UIViewController *)toggleStampController:(nullable id)sender includeSavedAnnotations:(BOOL)includeSavedAnnotations presentationOptions:(nullable NSDictionary<NSString *, id> *)options;

/// Displays a `PSPDFImagePickerController` and toggles the state to `PSPDFAnnotationStringImage`.
/// @param sender A `UIView` or `UIBarButtonItem` used as the anchor view for the popover controller (iPad only).
/// @param options A dictionary of presentation options. See PSPDFPresentationActions.h for possible values.
- (nullable UIViewController *)toggleImagePickerController:(nullable id)sender presentationOptions:(nullable NSDictionary<NSString *, id> *)options;

@end

@interface PSPDFAnnotationStateManager (StateHelper)

/// Checks if `state` is a drawing state.
- (BOOL)isDrawingState:(nullable NSString *)state;

/// Checks if `state` is a highlight state.
- (BOOL)isHighlightAnnotationState:(nullable NSString *)state;

/// Subclass to control if the state supports a style picker.
- (BOOL)stateShowsStylePicker:(nullable NSString *)state;

@end


@interface PSPDFAnnotationStateManager (SubclassingHooks)

/// Only allowed in drawing state (ink, line, polyline, polygon, circle, ellipse)
- (void)cancelDrawingAnimated:(BOOL)animated;
- (void)doneDrawingAnimated:(BOOL)animated;

/// Color management.
- (void)setLastUsedColor:(nullable UIColor *)lastUsedDrawColor annotationString:(NSString *)annotationString;
- (UIColor *)lastUsedColorForAnnotationString:(NSString *)annotationString;

/// If we're in drawing state, this dictionary contains the `PSPDFDrawView` classes that are overlaid on the `PSPDFPageView`.
/// The key is the current page.
@property (nonatomic, readonly) NSDictionary<NSNumber *, PSPDFDrawView *> *drawViews;

@end

@interface PSPDFAnnotationStateManager (Deprecated)

/// Undoes the last operation.
- (void)undo PSPDF_DEPRECATED(5.3, "Call on `document.undoController` instead.");

/// Undoes the last operation.
- (void)redo PSPDF_DEPRECATED(5.3, "Call on `document.undoController` instead.");

/// Returns YES if undo can be performed.
/// @see undo
@property (nonatomic, readonly) BOOL canUndo PSPDF_DEPRECATED(5.3, "Call on `document.undoController` instead.");

/// Returns YES if redo can be performed.
/// @see redo
@property (nonatomic, readonly) BOOL canRedo PSPDF_DEPRECATED(5.3, "Call on `document.undoController` instead.");

@end

NS_ASSUME_NONNULL_END
