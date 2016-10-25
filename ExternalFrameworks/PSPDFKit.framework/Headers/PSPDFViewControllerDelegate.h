//
//  PSPDFViewControllerDelegate.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFViewController.h"
#import "PSPDFPresentationActions.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PSPDFAnnotationViewProtocol;
@class PSPDFAnnotation, PSPDFDocument, PSPDFGlyph, PSPDFImageInfo, PSPDFMenuItem, PSPDFPageInfo, PSPDFPageView, PSPDFScrollView;

/// Helper method that will dig into popovers, navigation controllers, container view controllers or other controller view hierarchies and dig out the requested class if found.
PSPDF_EXPORT id _Nullable PSPDFChildViewControllerForClass(UIViewController * _Nullable controller, Class controllerClass, BOOL onlyReturnIfVisible);

/// NSNotification equivalent to `didShowPageView:` delegate.
PSPDF_EXPORT NSString *const PSPDFViewControllerDidShowPageViewNotification;

/// NSNotification equivalent to `didLoadPageView:` delegate.
PSPDF_EXPORT NSString *const PSPDFViewControllerDidLoadPageViewNotification;

/// Implement this delegate in your `UIViewController` to get notified of `PSPDFViewController` events.
PSPDF_AVAILABLE_DECL @protocol PSPDFViewControllerDelegate <NSObject>

@optional

/// @name Document Handling

/// Will be called when an action tries to change the document (For example, a PDF link annotation pointing to another document).
/// Will also be called when the document is changed via using the `document` property.
/// Return NO to block changing the document.
- (BOOL)pdfViewController:(PSPDFViewController *)pdfController shouldChangeDocument:(nullable PSPDFDocument *)document;

/// Will be called after the document has been changed.
/// @note This will also be called for nil and broken documents. use `document.isValid` to check.
- (void)pdfViewController:(PSPDFViewController *)pdfController didChangeDocument:(nullable PSPDFDocument *)document;

/// @name Scroll and Page Events

// If you need more scroll events, subclass `PSPDFScrollView` and relay your custom scroll events. Don't forget calling super though.

/// Control scrolling to pages. Not implementing this will return YES.
/// @note Returning `NO` will not prevent the user from changing pages by scrolling. 
- (BOOL)pdfViewController:(PSPDFViewController *)pdfController shouldScrollToPage:(NSUInteger)page;

/// Controller did show/scrolled to a new page. (at least 51% of it is visible)
- (void)pdfViewController:(PSPDFViewController *)pdfController didShowPageView:(PSPDFPageView *)pageView;

/// Page was fully rendered at zoom level = 1.
- (void)pdfViewController:(PSPDFViewController *)pdfController didRenderPageView:(PSPDFPageView *)pageView;

/// Called after pdf page has been loaded and added to the `pagingScrollView`.
- (void)pdfViewController:(PSPDFViewController *)pdfController didLoadPageView:(PSPDFPageView *)pageView;

/// Called before a pdf page will be unloaded and removed from the `pagingScrollView`.
- (void)pdfViewController:(PSPDFViewController *)pdfController willUnloadPageView:(PSPDFPageView *)pageView;

/// Will be called before the page rect has been dragged.
- (void)pdfViewController:(PSPDFViewController *)pdfController didBeginPageDragging:(UIScrollView *)scrollView;

/// Will be called after the page rect has been dragged.
/// If decelerate is YES, this will be called again after deceleration is complete.
///
/// You can also change the target with changing `targetContentOffset`.
///
/// This delegate combines the following scrollViewDelegates:
/// - `scrollViewWillEndDragging:` / `scrollViewDidEndDragging:`
/// - `scrollViewDidEndDecelerating:`
///
/// @note Be careful to not dereference a nil pointer in `targetContentOffset`.
/// To get more delegate options, you can subclass `PSPDFScrollView` and use all available delegates of `UIScrollViewDelegate`. (don't forget calling super).
/// Depending on the configured `pageTransition`, this might be called for several distinct scroll views.
/// Ensure that `scrollView == self.pagingScrollView` if you are only interested in dragging between pages.
- (void)pdfViewController:(PSPDFViewController *)pdfController didEndPageDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate withVelocity:(CGPoint)velocity targetContentOffset:(nullable inout CGPoint *)targetContentOffset;

/// Will be called after the paging animation is complete. This method will be called when animated scrolling
/// ends (e.g. a call to `-[PSPDFViewController setPage:animated:]` with animation enabled or animated content
/// offset changes). Use `pdfViewController:didEndPageDragging:willDecelerate:withVelocity:targetContentOffset:`
/// to determine when gesture-based page navigation ends.
- (void)pdfViewController:(PSPDFViewController *)pdfController didEndPageScrollingAnimation:(UIScrollView *)scrollView;

/// Will be called before the zoom level starts to change.
- (void)pdfViewController:(PSPDFViewController *)pdfController didBeginPageZooming:(UIScrollView *)scrollView;

/// Will be called after the zoom level has been changed, either programmatically or manually.
- (void)pdfViewController:(PSPDFViewController *)pdfController didEndPageZooming:(UIScrollView *)scrollView atScale:(CGFloat)scale;

/// Return a PSPDFDocument for a relative path.
/// If this returns nil, we try to find the PDF ourselves with using the current document's `basePath`.
- (PSPDFDocument *)pdfViewController:(PSPDFViewController *)pdfController documentForRelativePath:(NSString *)relativePath;

/// `didTapOnPageView:` will be called if a user taps on the page view.
///
/// Taps that can't be associated to a specific `pageView` will still be reported, but `pageView` is nil and the point will be relative to the view of the `PSPDFViewController`.
///
/// Return YES if you want to set this touch as processed; this will disable automatic touch processing like showing/hiding the HUDView or scrolling to the next/previous page.
///
/// @note This will not send events when the controller is in thumbnail view.
///
/// PSPDFPageCoordinates has been replaced by just `CGPoint` `viewPoint`.
/// You can easily calculate other needed coordinates:
/// e.g. to get the pdfPoint:    `[pageView convertViewPointToPDFPoint:viewPoint]`
///                 screenPoint: `[pageView convertPoint:tapPosition fromView:pageView]`
///                 zoomScale:    `pageView.scrollView.zoomScale`
///                 pageInfo:     `pageView.pageInfo`
- (BOOL)pdfViewController:(PSPDFViewController *)pdfController didTapOnPageView:(PSPDFPageView *)pageView atPoint:(CGPoint)viewPoint;

/// Similar to `didTapOnPageView:` invoked after 0.35 sec of tap-holding. LongPress and tap are mutually exclusive. Return YES if you custom-process that event.
///
/// Default handling is (if available) text selection; showing the magnification-loupe.
/// The gestureRecognizer helps you evaluating the state; as this delegate is called on every touch-move.
///
/// Note that there may be unexpected results if you only capture *some* events (thus, return YES on some movements during the recognition state) as e.g. you might not give the system a chance to clean up the magnification loupe. Either consume all or no events for a recognition cycle.
- (BOOL)pdfViewController:(PSPDFViewController *)pdfController didLongPressOnPageView:(PSPDFPageView *)pageView atPoint:(CGPoint)viewPoint gestureRecognizer:(UILongPressGestureRecognizer *)gestureRecognizer;

/// @name Text Selection

/// Called when text is about to be selected. Return NO to disable text selection.
- (BOOL)pdfViewController:(PSPDFViewController *)pdfController shouldSelectText:(NSString *)text withGlyphs:(NSArray<PSPDFGlyph *> *)glyphs atRect:(CGRect)rect onPageView:(PSPDFPageView *)pageView;

/// Called after text has been selected.
/// Will also be called when text has been deselected. Deselection sometimes cannot be stopped, so the `shouldSelectText:` will be skipped.
- (void)pdfViewController:(PSPDFViewController *)pdfController didSelectText:(NSString *)text withGlyphs:(NSArray<PSPDFGlyph *> *)glyphs atRect:(CGRect)rect onPageView:(PSPDFPageView *)pageView;

/// @name Menu Handling

/// Called before the menu for text selection is displayed.
/// All coordinates are in view coordinate space.
///
/// Using `PSPDFMenuItem` will help with adding custom menu's w/o hacking the responder chain.
/// Default returns menuItems if not implemented. Return nil or an empty array to not show the menu.
///
/// Use `PSPDFMenuItem's` `identifier` property to check and modify the menu items. This string will not be translated. (vs the title property)
///
/// `rect` is in the coordinate space of the `pageView`.
/// `annotationRect` or `textRect` is in the PDF coordinate space of the current page.
- (NSArray<PSPDFMenuItem *> *)pdfViewController:(PSPDFViewController *)pdfController shouldShowMenuItems:(NSArray<PSPDFMenuItem *> *)menuItems atSuggestedTargetRect:(CGRect)rect forSelectedText:(NSString *)selectedText inRect:(CGRect)textRect onPageView:(PSPDFPageView *)pageView;

/// Called before the menu for a selected image is displayed.
- (NSArray<PSPDFMenuItem *> *)pdfViewController:(PSPDFViewController *)pdfController shouldShowMenuItems:(NSArray<PSPDFMenuItem *> *)menuItems atSuggestedTargetRect:(CGRect)rect forSelectedImage:(PSPDFImageInfo *)selectedImage inRect:(CGRect)textRect onPageView:(PSPDFPageView *)pageView;

/// Called before we're showing the menu for an annotation.
/// If annotation is nil, we show the menu to create *new* annotations (in that case annotationRect will also be nil)
/// This delegate is also called as you dig into sub-menus like the color options.
/// @note You should filter out unwanted menu items as a blacklist - if you try to whitelist menu items, you might break functionality,
/// unless you explore every annotation type and every sub-menu and very carefully allow all entries.
/// The `idenfifier` property of the `PSPDFMenuItem` object is not loacalized and perfect for comparison.
- (NSArray<PSPDFMenuItem *> *)pdfViewController:(PSPDFViewController *)pdfController shouldShowMenuItems:(NSArray<PSPDFMenuItem *> *)menuItems atSuggestedTargetRect:(CGRect)rect forAnnotations:(nullable NSArray<PSPDFAnnotation *> *)annotations inRect:(CGRect)annotationRect onPageView:(PSPDFPageView *)pageView;

/// @name Annotations

/// Called before a annotation view is created and added to a page. Defaults to YES if not implemented.
/// @warning This will only be called for annotations that render as an overlay (that return YES for isOverlay)
/// If NO is returned, viewForAnnotation will not be called.
- (BOOL)pdfViewController:(PSPDFViewController *)pdfController shouldDisplayAnnotation:(PSPDFAnnotation *)annotation onPageView:(PSPDFPageView *)pageView;

/// Delegate for tapping annotations. Will be called before the more general `didTapOnPageView:` if an annotationView is hit.
///
/// Return YES to override the default action and custom-handle this.
/// Default actions might be scroll to target page, open Safari, show a menu, ...
///
/// Some annotations might not have an `annotationView` attached. (because they are rendered with the page content, for example highlight annotations)
///
/// @param annotationPoint the point relative to the `PSPDFAnnotation`, in PDF coordinate space.
/// @param viewPoint the point relative to the `PSPDFPageView`.
- (BOOL)pdfViewController:(PSPDFViewController *)pdfController didTapOnAnnotation:(PSPDFAnnotation *)annotation annotationPoint:(CGPoint)annotationPoint annotationView:(nullable UIView <PSPDFAnnotationViewProtocol> *)annotationView pageView:(PSPDFPageView *)pageView viewPoint:(CGPoint)viewPoint;

/// Called before an annotation will be selected. (but after `didTapOnAnnotation:`)
- (NSArray<PSPDFAnnotation *> *)pdfViewController:(PSPDFViewController *)pdfController shouldSelectAnnotations:(NSArray<PSPDFAnnotation *> *)annotations onPageView:(PSPDFPageView *)pageView;

/// Called after an annotation has been selected.
- (void)pdfViewController:(PSPDFViewController *)pdfController didSelectAnnotations:(NSArray<PSPDFAnnotation *> *)annotations onPageView:(PSPDFPageView *)pageView;

/// Returns a pre-generated `annotationView` that can be modified before being added to the view.
/// If no generator for a custom annotation is found, `annotationView` will be nil (as a replacement to viewForAnnotation)
/// To get the targeted rect use `[annotation rectForPageRect:pageView.bounds]`;
- (UIView <PSPDFAnnotationViewProtocol> *)pdfViewController:(PSPDFViewController *)pdfController annotationView:(nullable UIView <PSPDFAnnotationViewProtocol> *)annotationView forAnnotation:(PSPDFAnnotation *)annotation onPageView:(PSPDFPageView *)pageView;

/// Invoked prior to the presentation of the annotation view: use this to configure actions etc
/// @warning This will only be called for annotations that render as an overlay (that return YES for `isOverlay`)
/// `PSPDFLinkAnnotations` are handled differently (they don't have a selected state) - delegate will not be called for those.
- (void)pdfViewController:(PSPDFViewController *)pdfController willShowAnnotationView:(UIView <PSPDFAnnotationViewProtocol> *)annotationView onPageView:(PSPDFPageView *)pageView;

/// Invoked after animation used to present the annotation view
/// @warning This will only be called for annotations that render as an overlay (that return YES for `isOverlay`)
/// `PSPDFLinkAnnotations` are handled differently (they don't have a selected state) - delegate will not be called for those.
- (void)pdfViewController:(PSPDFViewController *)pdfController didShowAnnotationView:(UIView <PSPDFAnnotationViewProtocol> *)annotationView onPageView:(PSPDFPageView *)pageView;

/// @name View Controller Management

/// Called before we show a internal controller (color picker, note editor, ...) modally or in a popover. Allows last minute modifications.
///
/// Return NO to process the displaying manually.
- (BOOL)pdfViewController:(PSPDFViewController *)pdfController shouldShowController:(UIViewController *)controller options:(nullable NSDictionary<NSString *, id> *)options animated:(BOOL)animated;

/// Called after the controller has been fully displayed.
- (void)pdfViewController:(PSPDFViewController *)pdfController didShowController:(UIViewController *)controller options:(nullable NSDictionary<NSString *, id> *)options animated:(BOOL)animated;

/// @name General View State

/// Will be called when `viewMode` changes.
- (void)pdfViewController:(PSPDFViewController *)pdfController didChangeViewMode:(PSPDFViewMode)viewMode;

/// Called before the view controller will be dismissed (either by modal dismissal, or popping from the navigation stack).
/// Called before PSPDFKit tries to save any dirty annotation.
/// @note If you use child view containment then the dismissal might not be properly detected.
- (void)pdfViewControllerWillDismiss:(PSPDFViewController *)pdfController;

/// Called after the view controller has been dismissed (either by modal dismissal, or popping from the navigation stack).
/// @note If you use child view containment then the dismissal might not be properly detected.
- (void)pdfViewControllerDidDismiss:(PSPDFViewController *)pdfController;

/// @name Display State 

/// Called after the view controller changed its controller state or its controller state error.
///
/// @param pdfController The controller that changed its state.
- (void)pdfViewControllerDidChangeControllerState:(PSPDFViewController *)pdfController;

/// @name HUD

/// Return NO to stop the HUD change event.
- (BOOL)pdfViewController:(PSPDFViewController *)pdfController shouldShowHUD:(BOOL)animated;

/// HUD was displayed (called after the animation finishes)
- (void)pdfViewController:(PSPDFViewController *)pdfController didShowHUD:(BOOL)animated;

/// Return NO to stop the HUD change event.
- (BOOL)pdfViewController:(PSPDFViewController *)pdfController shouldHideHUD:(BOOL)animated;

/// HUD was hidden (called after the animation finishes)
- (void)pdfViewController:(PSPDFViewController *)pdfController didHideHUD:(BOOL)animated;

/// @name Actions

/// Return NO to prevent the PDF action from being executed. Also queried when performing actions via the back / forward list.
- (BOOL)pdfViewController:(PSPDFViewController *)pdfController shouldExecuteAction:(PSPDFAction *)action;

@end

NS_ASSUME_NONNULL_END
