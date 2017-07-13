//
//  PSPDFScrollView.h
//  PSPDFKit
//
//  Copyright © 2011-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAvoidingScrollView.h"
#import "PSPDFPresentationContext.h"

@protocol PSPDFAnnotationViewProtocol;
@class PSPDFDocument, PSPDFPageView, PSPDFViewController, PSPDFConfiguration;

NS_ASSUME_NONNULL_BEGIN

/// Scroll view that manages one or multiple `PSPDFPageView`s.
///
/// Depending on the `pageTransition`, either every `PSPDFPageView` is embedded in a `PSPDFScrollView`,
/// or there is one global `PSPDFScrollView` for all `PSPDFPageView`s.
/// This is also the center for all the gesture recognizers. Subclass to customize behavior (e.g. override `gestureRecognizerShouldBegin:`)
///
/// @warning If you manually zoom/change the contentOffset, you must use the methods with animation extension.
/// (You don't have to animate, but those are overridden by PSPDFKit to properly inform the `PSPDFPageViews` to re-render. You can also use the default `UIScrollView` properties and manually call updateRenderView on each visible PSPDFPageView)
///
///`- (void)setZoomScale:(float)scale animated:(BOOL)animated;`
///`- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated;`
///`- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;`
PSPDF_CLASS_AVAILABLE @interface PSPDFScrollView : PSPDFAvoidingScrollView<UIScrollViewDelegate, UIGestureRecognizerDelegate>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Current displayed spread.
/**
 Index of the currently displayed spread.

 The spread index describes the viewport of a pdf. This essentially means that for
 documents being displayed in single page mode, the spread index equals the page index,
 however if displayed in double page mode, one spread contains two pages.

 If you are interested in the actual page index displayed by the scroll view, check
 the page index from the `leftPage` or `rightPage` property.
 */
@property (nonatomic) NSUInteger spreadIndex;

/// Use `spreadIndex` instead, the value returned is the same.
@property (nonatomic) NSUInteger pageIndex PSPDF_DEPRECATED_IOS(6.5, "Renamed to spreadIndex to be more clear about what this property represents.");

/// The configuration data source for this scroll view
@property (nonatomic, weak, readonly) id<PSPDFPresentationContext> presentationContext;

/// Left page. Always set. Not used in `PSPDFPageTransitionCurl`.
@property (nonatomic, readonly) PSPDFPageView *leftPage;

/// Right page, if doublePageMode is enabled. Not used if the pageCurl transition is used.
@property (nonatomic, readonly) PSPDFPageView *rightPage;

/// Enables/Disables zooming. Defaults to YES. If set to NO, will lock current zoom level.
@property (nonatomic, getter=isZoomingEnabled) BOOL zoomingEnabled;

@end

@interface PSPDFScrollView (Advanced)

/// Returns all selected annotations of all visible `PSPDFPageViews`.
@property (nonatomic, copy, readonly) NSArray<__kindof PSPDFAnnotation *> *selectedAnnotations;

@end

@interface PSPDFScrollView (SubclassingHooks)

/// Tap gesture recognizer to sync with your own recognizers.
/// @warning Don't change the delegate.
@property (nonatomic, readonly) UITapGestureRecognizer *singleTapGesture;

/// Double tap gesture recognizer to sync with your own recognizers.
/// @warning Don't change the delegate.
@property (nonatomic, readonly) UITapGestureRecognizer *doubleTapGesture;

/// Long press gesture recognizer to sync with your own recognizers.
/// @warning Don't change the delegate.
@property (nonatomic, readonly) UILongPressGestureRecognizer *longPressGesture;

/// Hit-Testing
///
/// PSPDFKit has a `UITapGestureRecognizer` to detects taps. There are several different actions called, if one succeeds further processing will be stopped.
///
/// First, we check if we hit a `PSPDFLinkAnnotationView` and invoke the delegates and default action if found.
///
/// Next, we check if there's text selection and discard if.
/// Then, touches are relayed to all visible `PSPDFPageView`s and `singleTapped:` is called. If one page reports that the touch has been processed; the loop is stopped.
///
/// Next, the `didTapOnPageView:atPoint:` delegate is called if the touch still hasn't been processed.
///
/// Lastly, if even the delegate returned NO, we look if `isScrollOnTapPageEndEnabled` and scroll to the next/previous page if the border is near enough; or just toggle the HUD (if that is allowed)
///
/// Do note that the single and double tap gestures do not have dependencies. This has been made to improve single tap performance.
/// If your app requires this, you can manually add this dependency.
- (void)singleTapped:(UITapGestureRecognizer *)recognizer;
- (void)doubleTapped:(UITapGestureRecognizer *)recognizer;
- (void)longPress:(UILongPressGestureRecognizer *)recognizer;

/// Manually trigger a scroll indicator update.
- (void)updateScrollViewIndicator;

/// Manually re-center the content.
- (void)ensureContentIsCentered;

/// View that gets zoomed. attach your views here instead of the `PSPDFScrollView` to get them zoomed.
@property (nonatomic, readonly) UIView *compoundView;

/// If you override any of these, make sure you call super.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView NS_REQUIRES_SUPER;
- (void)scrollViewDidZoom:(UIScrollView *)scrollView NS_REQUIRES_SUPER;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView NS_REQUIRES_SUPER;
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_REQUIRES_SUPER;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate NS_REQUIRES_SUPER;
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView NS_REQUIRES_SUPER;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView NS_REQUIRES_SUPER;
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView NS_REQUIRES_SUPER;
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view NS_REQUIRES_SUPER;
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale NS_REQUIRES_SUPER;
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
