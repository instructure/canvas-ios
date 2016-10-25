//
//  PSPDFDrawView.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <QuartzCore/QuartzCore.h>
#import "PSPDFEnvironment.h"
#import "PSPDFSquareAnnotation.h"
#import "PSPDFPolygonAnnotation.h"
#import "PSPDFAbstractLineAnnotation.h"
#import "PSPDFAnnotationViewProtocol.h"
#import "PSPDFOverridable.h"
#import "PSPDFDrawingPoint.h"

@class PSPDFDrawView, PSPDFDrawLayer, PSPDFPageView, PSPDFInkAnnotation;

typedef NS_ENUM(NSInteger, PSPDFDrawViewInputMode) {
    /// Touches perform drawing operations.
    PSPDFDrawViewInputModeDraw,
    /// Touches perform erase operations.
    PSPDFDrawViewInputModeErase
} PSPDF_ENUM_AVAILABLE;

NS_ASSUME_NONNULL_BEGIN

/// `PSPDFDrawView` allows drawing or erasing on top of a `PSPDFPageView` and handles new annotation creation.
/// The class holds an array of `PSPDFDrawLayer` objects that will later be converted into PDF annotations
/// (`PSPDFAnnotation` and it's subclasses). The conversion from draw view to annotation isn't necessary 1:1.
/// Some draw actions can be left out (for instance if there are validation errors like to few points for the annotation
/// type in question). Others might be combined into a single annotation (see `combineInk`).
PSPDF_CLASS_AVAILABLE @interface PSPDFDrawView : UIView <PSPDFAnnotationViewProtocol, PSPDFOverridable>

/// Current annotation type.
@property (nonatomic) PSPDFAnnotationType annotationType;

/// The selected tool variant. Applied to new annotations.
@property (nonatomic, nullable) NSString *annotationVariant;

/// Determines what effect touch events have. Defaults to `PSPDFDrawViewInputModeDraw`.
/// `PSPDFDrawViewInputModeErase` only affects Ink annotations.
@property (nonatomic) PSPDFDrawViewInputMode inputMode;

/// Current active draw layer. This action is currently receiving input.
/// Set only during input while in `PSPDFDrawViewInputModeDraw` input mode.
@property (nonatomic, readonly, nullable) PSPDFDrawLayer *currentDrawLayer;

/// Array of `PSPDFDrawLayer` objects that have been created during the draw view session
/// or imported using `updateActionsForAnnotations:`.
/// @note Allows KVO observation.
@property (nonatomic, readonly) NSArray<PSPDFDrawLayer *> *drawLayers;

/// Clear all actions. Registers as a single undo action, if undo is supported. 
- (void)clearAllLayers;

/// All annotations currently managed by the draw view.
@property (nonatomic, readonly) NSArray<__kindof PSPDFAnnotation *> *annotations;

/// Advanced property that allows you to customize how ink annotations are created.
/// Set to NO to cause separate ink drawings in the same drawing session to result in separate ink annotations. Defaults to YES.
@property (nonatomic) BOOL combineInk;

/// @name Styling properties

/// Current stroke color.
@property (nonatomic, nullable) UIColor *strokeColor;

/// Current fill color.
@property (nonatomic, nullable) UIColor *fillColor;

/// Current line width.
@property (nonatomic) CGFloat lineWidth;

/// Starting line end type for lines and polylines.
@property (nonatomic) PSPDFLineEndType lineEnd1;

/// Ending line end type for lines and polylines.
@property (nonatomic) PSPDFLineEndType lineEnd2;

/// The stroke dash pattern. Draws a solid line when `nil` (default).
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *dashArray;

/// Natural drawing.
@property (nonatomic) BOOL naturalDrawingEnabled;

/// Guide color. Defaults to `UIColor.pspdf_guideColor`.
@property (nonatomic, nullable) UIColor *guideBorderColor UI_APPEARANCE_SELECTOR;

/// @name Annotation import

/// Converts the provided annotations into `PSPDFDrawLayer` objects, making them available for editing.
/// @note Currently only supports Ink annotations (ink eraser).
/// @return An array of newly inserted layers, if any.
- (NSArray<PSPDFDrawLayer *> *)updateActionsForAnnotations:(NSArray<PSPDFInkAnnotation *> *)annotations;

/// Used to compute approximate line widths during drawing.
/// When a `pageView` is associated this will automatically be set to it's `scaleForPageView`.
/// Defaults to 1.f.
@property (nonatomic) CGFloat scale;

/// Draw view zoom scale, used for zoom dependent eraser sizing.
/// When a `pageView` is associated this will automatically be set to it's `scrollView.zoomScale`.
/// Defaults to 1.f.
@property (nonatomic) CGFloat zoomScale;

/// @name Drawing

/// Starts a drawing operation at the given point.
/// The `inputMode` needs to be set to `PSPDFDrawViewInputModeDraw`.
- (void)startDrawingAtPoint:(PSPDFDrawingPoint)location;

/// Continues a drawing operation at with the given points and optional predicted points.
/// The `inputMode` needs to be `PSPDFDrawViewInputModeDraw`.
- (void)continueDrawingAtPoints:(NSArray<NSValue *> *)locations predictedPoints:(NSArray<NSValue *> *)predictedLocations;

/// Commits the drawing.
/// The `inputMode` needs to be set to `PSPDFDrawViewInputModeDraw`.
- (void)endDrawing;

/// Cancels the drawing.
/// The `inputMode` needs to be set to `PSPDFDrawViewInputModeDraw`.
- (void)cancelDrawing;

/// Defines how aggressively shapes snap to square aspect ratio. Defaults to 20.f.
/// Set to 0.f do disable guides.
@property (nonatomic) CGFloat guideSnapAllowance;

/// @name Erase

/// Performs an erase at the given locations.
/// The `inputMode` needs to be set to `PSPDFDrawViewInputModeErase`.
- (void)eraseAt:(NSArray<NSValue *> *)locations;

/// Commits the erase operation (registers the undo action, etc.). 
/// The `inputMode` needs to be set to `PSPDFDrawViewInputModeErase`.
- (void)endErase;

@end

@interface PSPDFDrawView (SubclassingHooks)

/// Return `NO` to prevent touch handling processing.
- (BOOL)shouldProcessTouches:(NSSet *)touches withEvent:(UIEvent *)event;

@end

NS_ASSUME_NONNULL_END
