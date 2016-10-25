//
//  PSPDFResizableView.h
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

@class PSPDFResizableView, PSPDFAnnotation, PSPDFPageView;

typedef NS_ENUM(NSUInteger, PSPDFResizableViewOuterKnob) {
    PSPDFResizableViewOuterKnobUnknown,
    PSPDFResizableViewOuterKnobTopLeft,
    PSPDFResizableViewOuterKnobTopMiddle,
    PSPDFResizableViewOuterKnobTopRight,
    PSPDFResizableViewOuterKnobMiddleLeft,
    PSPDFResizableViewOuterKnobMiddleRight,
    PSPDFResizableViewOuterKnobBottomLeft,
    PSPDFResizableViewOuterKnobBottomMiddle,
    PSPDFResizableViewOuterKnobBottomRight
} PSPDF_ENUM_AVAILABLE;

/// Constant used to always force guide snapping.
PSPDF_EXPORT CGFloat const PSPDFGuideSnapAllowanceAlways;

NS_ASSUME_NONNULL_BEGIN

/// Delegate to be notified on session begin/end and frame changes.
PSPDF_AVAILABLE_DECL @protocol PSPDFResizableViewDelegate <NSObject>

@optional

/// The editing session has begun.
- (void)resizableViewDidBeginEditing:(PSPDFResizableView *)resizableView;

/// Called after frame change.
/// On the first call, `isInitialChange` will be true.
- (void)resizableViewChangedFrame:(PSPDFResizableView *)resizableView outerKnobType:(PSPDFResizableViewOuterKnob)outerKnobType isInitialChange:(BOOL)isInitialChange;

/// The editing session has ended.
- (void)resizableViewDidEndEditing:(PSPDFResizableView *)resizableView didChangeFrame:(BOOL)didChangeFrame;

@end

typedef NS_ENUM(NSUInteger, PSPDFKnobType) {
    /// Used to resize the bounding box.
    PSPDFKnobTypeOuter,
    /// Used to alter certain shapes.
    PSPDFKnobTypeInner
} PSPDF_ENUM_AVAILABLE;

/// Required methods for views that represent resizable view knobs.
PSPDF_AVAILABLE_DECL @protocol PSPDFKnobView <NSObject>

/// The knob type. Use to display inner and outer knobs differently.
/// Redraw if this property changes.
@property (nonatomic) PSPDFKnobType type;

/// The preferred knob size at zoom level 1.
/// The frame will be adjusted when zooming, based on this size.
@property (nonatomic, readonly) CGSize knobSize;

@end

typedef NS_ENUM(NSUInteger, PSPDFResizableViewMode) {
    /// Nothing is currently happening.
    PSPDFResizableViewModeIdle,
    /// The annotation is being moved.
    PSPDFResizableViewModeMove,
    /// The annotation is being resized.
    PSPDFResizableViewModeResize,
    /// The shape of the annotation is being adjusted (e.g. polyline shape)
    PSPDFResizableViewModeAdjust
} PSPDF_ENUM_AVAILABLE;

/// A view that shows borders around selected annotations, with handles the user can use to resize the annotation.
/// The handle and border color is determined by the `tintColor` property inherited from `UIView`.
PSPDF_CLASS_AVAILABLE @interface PSPDFResizableView : UIView

/// Delegate called on frame change.
@property (nonatomic, weak) IBOutlet id<PSPDFResizableViewDelegate> delegate;

/// The mode that the resizable view is currently in.
@property (nonatomic) PSPDFResizableViewMode mode;

/// View that will be changed on selection change.
@property (nonatomic, copy, nullable) NSSet *trackedViews;

/// Set zoom scale to be able to draw the page knobs at the correct size.
@property (nonatomic) CGFloat zoomScale;

/// The inner edge insets are used to create space between the bounding box (blue) and tracked view.
/// They will be applied to the content frame in addition to `outerEdgeInsets` to calculate frame. Use negative
/// values to add space around the tracked annotation view. Defaults to -20.f for top, bottom, right, and left.
/// @note `updateAnnotationSelectionView` in PSPDFPageView is used to set the inner edge insets of not
/// resizable annotations (e.g. note annotations) to -2.f for top, bottom, right, and left (ignoring the
/// `innerEdgeInsets` property). If you want to change this, you need to subclass PSPDFPageView and overwrite
/// `updateAnnotationSelectionView`.
@property (nonatomic) UIEdgeInsets innerEdgeInsets;

/// The outer edge insets are used to create space between the bounding box (blue) and the view bounds.
/// They will be applied to the content frame in addition to `innerEdgeInsets` to calculate frame.
/// Use negative values to add space around the tracked annotation view.
/// Defaults to `-40.0f` for top, bottom, right, and left.
@property (nonatomic) UIEdgeInsets outerEdgeInsets;

/// If set to NO, won't show selection knobs and dragging. Defaults to YES.
@property (nonatomic) BOOL allowEditing;

/// Allows view resizing, shows resize knobs.
/// If set to NO, view can only be moved or adjusted, no resize knobs will be displayed. Depends on `allowEditing`. Defaults to YES.
@property (nonatomic) BOOL allowResizing;

/// Allows view adjusting, shows knobs to move single points.
/// If set to NO, view can only be moved or resized, no adjust knobs will be displayed. Depends on `allowEditing`. Defaults to YES.
@property (nonatomic) BOOL allowAdjusting;

/// Enables resizing helper so that aspect ration can be preserved easily.
/// Defaults to YES.
@property (nonatomic) BOOL enableResizingGuides;

/// Shows the bounding box. Defaults to YES.
@property (nonatomic) BOOL showBoundingBox;

/// Defines how aggressively the guide works. Defaults to 20.f.
/// Set to `PSPDFGuideSnapAllowanceAlways` if you want to always snap to guides.
@property (nonatomic) CGFloat guideSnapAllowance;

/// Override the minimum allowed width. This value is ignored if the view is smaller to begin with
/// or the annotation specifies a bigger minimum width. Default is 0.f.
@property (nonatomic) CGFloat minWidth;

/// Override the minimum allowed height. This value is ignored if the view is smaller to begin with
/// or the annotation specifies a bigger minimum height. Default is 0.f.
@property (nonatomic) CGFloat minHeight;

/// Border size. Defaults to 1.f
@property (nonatomic) CGFloat selectionBorderWidth UI_APPEARANCE_SELECTOR;

/// Guide color. Defaults to `UIColor.pspdf_guideColor`.
@property (nonatomic, nullable) UIColor *guideBorderColor UI_APPEARANCE_SELECTOR;

/// Corner radius size. Defaults to 2.f.
@property (nonatomic) NSUInteger cornerRadius UI_APPEARANCE_SELECTOR;

@end

@interface PSPDFResizableView (SubclassingHooks)

// Forward parent gesture recognizer longPress action.
- (BOOL)longPress:(UILongPressGestureRecognizer *)recognizer;

/// All knobs. Can be hidden individually.
/// Note that properties like `allowEditing`/`allowResizing` will update the hidden property.
/// To properly hide a knob, remove it from the superview.
- (nullable UIView<PSPDFKnobView> *)outerKnobOfType:(PSPDFResizableViewOuterKnob)knobType;

/// Allows to customize the position for a knob.
///
/// @param knobType The knob whoes center position should be calculated.
/// @param frame    The frame in which the knob is positioned. Usually this is `self.bounds`, but during resizing, this might be different.
///
/// @return The center point of where the knob view should be drawn.
- (CGPoint)centerPointForOuterKnob:(PSPDFResizableViewOuterKnob)knobType inFrame:(CGRect)frame;

/// Creates and configures a new knob view.
- (UIView<PSPDFKnobView> *)newKnobViewForType:(PSPDFKnobType)type;

@property (nonatomic, readonly) NSSet<PSPDFAnnotation *> *trackedAnnotations;

/// Update the knobs.
- (void)updateKnobsAnimated:(BOOL)animated;

/// The guide layer is used to present the border around annotations.
/// We have great defaults but subclassing this can be used to change the style.
/// @warning Do *NOT* override `drawRect:` in this class, as it will consume a lot of memory when zoomed in.
- (void)configureGuideLayer:(CAShapeLayer *)layer withZoomScale:(CGFloat)zoomScale NS_REQUIRES_SUPER;

@end

@interface PSPDFResizableView (Deprecated)

@property (nonatomic, readonly, nullable) PSPDFAnnotation *trackedAnnotation PSPDF_DEPRECATED("5.3.6", "Use trackedAnnotations instead.");

@end

NS_ASSUME_NONNULL_END
