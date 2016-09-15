//
//  PSPDFPageView.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

#import "PSPDFAnnotation.h"
#import "PSPDFRelayTouchesView.h"
#import "PSPDFAnnotationStyleViewController.h"
#import "PSPDFCache.h"
#import "PSPDFFontPickerViewController.h"
#import "PSPDFMacros.h"
#import "PSPDFNoteAnnotationViewController.h"
#import "PSPDFPresentationContext.h"
#import "PSPDFResizableView.h"
#import "PSPDFSignatureSelectorViewController.h"
#import "PSPDFSignatureViewController.h"
#import "PSPDFStampViewController.h"


NS_ASSUME_NONNULL_BEGIN

@protocol PSPDFAnnotationViewProtocol;
@class PSPDFLinkAnnotation, PSPDFPageInfo, PSPDFScrollView, PSPDFDocument, PSPDFViewController, PSPDFTextParser, PSPDFTextSelectionView, PSPDFAnnotation, PSPDFRenderStatusView, PSPDFNoteAnnotation, PSPDFOrderedDictionary, PSPDFMenuItem, PSPDFFreeTextAnnotation;

PSPDF_CLASS_AVAILABLE @interface PSPDFAnnotationContainerView : PSPDFRelayTouchesView @end

/// Notification is fired when the `selectedAnnotations` value changed.
/// `object` is the pageView.
PSPDF_EXPORT NSString *const PSPDFPageViewSelectedAnnotationsDidChangeNotification;

/// Display a single PDF page. View is reused.
/// You can add your own views on top of the `annotationContainerView` (e.g. custom annotations)
/// Events from a attached `UIScrollView` will be relayed to all visible `PSPDFPageView` classes.
/// @note The `UINavigationControllerDelegate` is only defined to satisfy the `UIImagePickerController` delegate.
PSPDF_CLASS_AVAILABLE @interface PSPDFPageView : UIView <PSPDFRenderDelegate, PSPDFCacheDelegate, PSPDFResizableViewDelegate, PSPDFAnnotationGridViewControllerDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// @name Show / Destroy a document

/// configure page container with data.
- (void)displayPage:(NSUInteger)page pageRect:(CGRect)pageRect scale:(CGFloat)scale presentationContext:(id <PSPDFPresentationContext>)presentationContext;

/// The attached presentation context.
@property (nonatomic, weak, readonly) id <PSPDFPresentationContext> presentationContext;

/// Prepares the `PSPDFPageView` for reuse. Removes all unknown internal `UIViews`.
- (void)prepareForReuse NS_REQUIRES_SUPER;

/// @name Internal views and rendering

/// Redraw the `renderView` (dynamically rendered PDF for maximum sharpness, updated on every zoom level.)
- (void)updateRenderView;

/// Redraw `renderView` and `contentView`.
- (void)updateView;

/// If annotations are already loaded, and the annotation is a view, access it here.
/// (Most PDF annotations are actually rendered into the page; except annotations that return YES for `isOverlay`, like links or notes.
- (nullable UIView <PSPDFAnnotationViewProtocol> *)annotationViewForAnnotation:(PSPDFAnnotation *)annotation;

/// UIImageView displaying the whole document.
@property (nonatomic, readonly) UIImageView *contentView;

/// UIImageView for the zoomed in state.
@property (nonatomic, readonly) UIImageView *renderView;

/// Container view for all overlay annotations.
///
/// This is just a named subclass of `UIView` that will always track the frame of the `PSPDFPageView`.
/// It's useful to coordinate this with your own subviews to get the zIndex right.
///
/// @warning Most annotations will not be rendered as overlays or only when they are currently being selected.
/// Rendering annotations within the pageView has several advantages including performance or view color multiplication (in case of highlight annotations)
/// Do not manually add/remove views into the container view. Contents is managed. Views should respond to the `PSPDFAnnotationViewProtocol`, especially the annotation method.
@property (nonatomic, readonly) PSPDFAnnotationContainerView *annotationContainerView;

/// Access the selectionView. (handles text selection)
@property (nonatomic, readonly) PSPDFTextSelectionView *selectionView;

/// Access the render status view that is displayed on top of a page while we are rendering.
@property (nonatomic) PSPDFRenderStatusView *renderStatusView;

/// Top right offset. Defaults to 30.f.
@property (nonatomic) CGFloat renderStatusViewOffset;

/// Calculated scale. Readonly.
@property (nonatomic, readonly) CGFloat PDFScale;

/// Current CGRect of the part of the page that's visible. Screen coordinate space.
/// @note If the scroll view is currently decelerating, this will show the TARGET rect, not the one that's currently animating.
@property (nonatomic, readonly) CGRect visibleRect;

/// Color used to indicate link or form objects.
@property (nonatomic) UIColor *highlightColor UI_APPEARANCE_SELECTOR;

/// @name Coordinate calculations and object fetching

/// Convert a view point to the corresponding PDF point.
/// @note `pageBounds` usually is `PSPDFPageView` bounds.
- (CGPoint)convertViewPointToPDFPoint:(CGPoint)viewPoint;

/// Convert a PDF point to the corresponding view point.
/// @note `pageBounds` usually is `PSPDFPageView` bounds.
- (CGPoint)convertPDFPointToViewPoint:(CGPoint)pdfPoint;

/// Convert a view rect to the corresponding pdf rect.
/// @note **Important:** The viewRect must be well–formed!
/// Do not, for example, pass something with a less–than–zero width…
- (CGRect)convertViewRectToPDFRect:(CGRect)viewRect;

/// Convert a PDF rect to the corresponding view rect
/// @note **Important:** The viewRect must be well–formed!
/// Do not, for example, pass something with a less–than–zero width…
- (CGRect)convertPDFRectToViewRect:(CGRect)pdfRect;

/// Get the glyphs/words on a specific page.
- (NSDictionary<NSString *, id> *)objectsAtPoint:(CGPoint)viewPoint options:(nullable NSDictionary<NSString *, NSNumber *> *)options;

/// Get the glyphs/words on a specific rect.
/// Usage e.g. `NSDictionary *objects = [pageView objectsAtRect:rect options:@{PSPDFObjectsWordsKey: @ YES}]`;
- (NSDictionary<NSString *, id> *)objectsAtRect:(CGRect)viewRect options:(nullable NSDictionary<NSString *, NSNumber *> *)options;

/// @name Accessors

/// Access parent `PSPDFScrollView` if available. (zoom controller)
/// @note this only lets you access the scrollView if it's in the view hierarchy.
/// If we use pageCurl mode, we have a global scrollView which can be accessed with `pdfController.pagingScrollView`
@property (nonatomic, readonly, nullable) PSPDFScrollView *scrollView;

/// Returns an array of `UIView` `PSPDFAnnotationViewProtocol` objects currently in the view hierarchy.
@property (nonatomic, readonly) NSArray<UIView<PSPDFAnnotationViewProtocol> *> *visibleAnnotationViews;

/// Page that is displayed. Readonly.
@property (nonatomic, readonly) NSUInteger page;

/// Shortcut to access the current boxRect of the set page.
@property (nonatomic, readonly, nullable) PSPDFPageInfo *pageInfo;

/// Return YES if the pdfPage is displayed in a double page mode setup on the right side.
@property (nonatomic, readonly, getter=isRightPage) BOOL rightPage;

@end

// Extensions to handle annotations.
@interface PSPDFPageView (AnnotationViews)

// Associate an annotation with an annotation view
- (void)setAnnotation:(PSPDFAnnotation *)annotation forAnnotationView:(UIView <PSPDFAnnotationViewProtocol> *)annotationView;

// Recall the annotation associated with an annotation view
- (PSPDFAnnotation *)annotationForAnnotationView:(UIView <PSPDFAnnotationViewProtocol> *)annotationView;

/// Currently selected annotations (selected by a tap; showing a menu)
@property (nonatomic, copy, null_resettable) NSArray<__kindof PSPDFAnnotation *> *selectedAnnotations;

/// Hit-testing for a single `PSPDFPageView`. This is usually a relayed event from the parent `PSPDFScrollView`.
/// Returns YES if the tap has been handled, else NO.
///
/// All annotations for the current page are loaded and hit-tested (except `PSPDFAnnotationTypeLink`; which has already been handled by now)
///
/// If an annotation has been hit (via `[annotation hitTest:tapPoint]`; convert the tapPoint in PDF coordinate space via convertViewPointToPDFPoint) then we call showMenuForAnnotation.
///
/// If the tap didn't hit an annotation but we are showing a UIMenuController menu; we hide that and set the touch as processed.
- (BOOL)singleTapped:(UITapGestureRecognizer *)recognizer;

/// Handle long press, potentially relay to subviews.
- (BOOL)longPress:(UILongPressGestureRecognizer *)recognizer;

/// Add an `annotation` to the current pageView.
/// This will either queue a re-render of the PDF, or add an `UIView` subclass for the matching annotation,
/// depending on the annotation type and the value of `isOverlay`.
///
/// @note In PSPDFKit, annotations are managed in two ways:
///
/// 1) Annotations that are fixed and rendered with the page image.
/// Those annotations are `PSPDFHighlightAnnotation`, `PSPDFSquareAnnotation`, `PSPDFInkAnnotation` and more.
/// Pretty much all more or less "static" annotations are handled this way.
///
/// 2) Then, there are the more dynamic annotations like `PSPDFLinkAnnotation` and `PSPDFNoteAnnotation`.
/// Those annotations are not part of the rendered image but are actual subviews in `PSPDFPageView`.
/// Those annotations return YES on the isOverlay property.
///
/// This method is called recursively with all annotation types except if they return isOverlay = NO. In case of isOverlay = NO, it will call updateView to re-render the page.
///
/// @warning This will not change anything on the data model below. Also add an annotation to the document object.
- (void)addAnnotation:(PSPDFAnnotation *)annotation options:(nullable NSDictionary<NSString *, NSNumber *> *)options animated:(BOOL)animated;

/// Removes an `annotation` from the view, either by re-rendering the page image or removing a matching UIView-subclass of the annotation was added as an overlay.
/// @note This will not change the data model of the document.
- (BOOL)removeAnnotation:(PSPDFAnnotation *)annotation options:(nullable NSDictionary<NSString *, NSNumber *> *)options animated:(BOOL)animated;

/// Select annotation and show the menu for it.
- (void)selectAnnotation:(PSPDFAnnotation *)annotation animated:(BOOL)animated;

@end

@interface PSPDFPageView (SubclassingHooks)

/// @name Shadow settings

/// Subclass to change shadow behavior.
- (void)updateShadowAnimated:(BOOL)animated;

/// Called before the page view is reused.
- (void)prepareForReuse;

/// Internally used to add annotations.
- (void)insertAnnotations:(NSArray<PSPDFAnnotation *> *)annotations forPage:(NSUInteger)page inDocument:(PSPDFDocument *)document;

/// Returns annotations that we could tap on. (checks against `editableAnnotationTypes`)
/// The point will have a variance of a few pixels to improve touch recognition.
- (NSArray<__kindof PSPDFAnnotation *> *)tappableAnnotationsAtPoint:(CGPoint)viewPoint;

/// Same as above, but will be called when we're detecting a long press.
- (NSArray<__kindof PSPDFAnnotation *> *)tappableAnnotationsForLongPressAtPoint:(CGPoint)viewPoint;

/// Used within `tappableAnnotationsAtPoint:` to expand the tap point to make tapping objects easier.
/// By default the rect has a size of 10 pixels.
- (CGRect)hitTestRectForPoint:(CGPoint)viewPoint;

/// Can be used for manual tap forwarding.
- (BOOL)singleTappedAtViewPoint:(CGPoint)viewPoint;

/// Get annotation rect (PDF coordinate space)
- (CGRect)rectForAnnotations:(NSArray<PSPDFAnnotation *> *)annotations;

/// Render options that are used for the live-page rendering. (not for the cache)
/// One way to use this would be to customize what annotations types will be rendered with the pdf.
/// See `PSPDFPageRenderer` for a list of options.
- (NSDictionary<NSString *, id> *)renderOptionsDictWithZoomScale:(CGFloat)zoomScale animated:(BOOL)animated;

/// View for the selected annotation. Created and destroyed on the fly.
@property (nonatomic, readonly, nullable) __kindof PSPDFResizableView *annotationSelectionView;

/// Helper to properly place an annotation.
- (void)centerAnnotation:(PSPDFAnnotation *)annotation aroundPDFPoint:(CGPoint)pdfPoint;

/// Load page annotations from the PDF.
- (void)loadPageAnnotationsAnimated:(BOOL)animated blockWhileParsing:(BOOL)blockWhileParsing;

/// Computes a scale value suitable for computation of the line width to use during drawing and selection.
@property (nonatomic, readonly) CGFloat scaleForPageView;

/// If you use child view controller containment, use this as the parent VC.
@property (nonatomic, readonly) UIViewController *parentViewController;

/// Change notification processing.
- (void)annotationsAddedNotification:(NSNotification *)notification NS_REQUIRES_SUPER;
- (void)annotationsRemovedNotification:(NSNotification *)notification NS_REQUIRES_SUPER;
- (void)annotationChangedNotification:(NSNotification *)notification NS_REQUIRES_SUPER;

/// Customize if the `annotation` object should also transform the properties.
- (BOOL)shouldScaleAnnotationWhenResizing:(PSPDFAnnotation *)annotation usesResizeKnob:(BOOL)usesResizeKnob;

/// Customize annotation selection view.
- (void)updateAnnotationSelectionView;

@end

NS_ASSUME_NONNULL_END
