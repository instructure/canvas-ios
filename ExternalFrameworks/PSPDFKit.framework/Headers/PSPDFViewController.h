//
//  PSPDFViewController.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFBaseViewController.h"

#import "PSPDFAnnotation.h"
#import "PSPDFAnnotationTableViewController.h"
#import "PSPDFBackForwardActionList.h"
#import "PSPDFBookmarkViewController.h"
#import "PSPDFConfiguration.h"
#import "PSPDFDocumentActionExecutor.h"
#import "PSPDFControllerState.h"
#import "PSPDFEnvironment.h"
#import "PSPDFExternalURLHandler.h"
#import "PSPDFHUDView.h"
#import "PSPDFInlineSearchManager.h"
#import "PSPDFNavigationItem.h"
#import "PSPDFOutlineViewController.h"
#import "PSPDFPresentationContext.h"
#import "PSPDFSearchViewController.h"
#import "PSPDFTextSearch.h"
#import "PSPDFThumbnailBar.h"
#import "PSPDFWebViewController.h"
#import "PSPDFVersion.h"
#import "PSPDFFlexibleToolbarContainer.h"
#import <MessageUI/MessageUI.h>

@protocol PSPDFViewControllerDelegate, PSPDFAnnotationSetStore, PSPDFFormSubmissionDelegate;
@class PSPDFDocument, PSPDFScrollView, PSPDFScrubberBar, PSPDFPageView, PSPDFRelayTouchesView, PSPDFPageViewController, PSPDFSearchResult, PSPDFViewState, PSPDFPageLabelView, PSPDFDocumentLabelView, PSPDFAnnotationViewCache, PSPDFAnnotationStateManager, PSPDFSearchHighlightViewManager, PSPDFAction, PSPDFAnnotationToolbar, PSPDFThumbnailViewController, PSPDFAnnotationToolbarController, PSPDFDocumentInfoCoordinator, PSPDFAppearanceModeManager, PSPDFBrightnessManager, PSPDFDocumentEditorViewController;

NS_ASSUME_NONNULL_BEGIN

/// This is the main view controller to display PDFs. Can be displayed in full-screen or embedded. Everything in PSPDFKit is based around `PSPDFViewController`. This is the class you want to override and customize.
///
/// Make sure to correctly use view controller containment when adding this as a child view controller. If you override this class, ensure all `UIViewController` methods you're using do call super. (e.g. `viewWillAppear:`).
///
/// For subclassing, use `overrideClass:withClass:` to register your custom subclasses.
///
/// The best time for setting the properties is during initialization in `commonInitWithDocument:configuration:`. Some properties require a call to `reloadData` if they are changed after the controller has been displayed. Do not set properties during a rotation phase or view appearance (e.g. use `viewDidAppear:` instead of `viewWillAppear:`) since that could corrupt internal state, instead use `updateSettingsForBoundsChangeBlock`.
PSPDF_CLASS_AVAILABLE @interface PSPDFViewController : PSPDFBaseViewController <PSPDFPresentationContext, PSPDFControlDelegate, PSPDFOverridable, PSPDFTextSearchDelegate, PSPDFInlineSearchManagerDelegate, PSPDFErrorHandler, PSPDFExternalURLHandler, PSPDFOutlineViewControllerDelegate, PSPDFBookmarkViewControllerDelegate, PSPDFWebViewControllerDelegate, PSPDFSearchViewControllerDelegate, PSPDFAnnotationTableViewControllerDelegate, PSPDFBackForwardActionListDelegate, PSPDFFlexibleToolbarContainerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

/// @name Initialization and essential properties.

/// Initialize with a document.
/// @note Document can be nil. In this case, just the background is displayed and the HUD stays visible.
/// Also supports creation via `initWithCoder:` to allow usage in Storyboards.
- (instancetype)initWithDocument:(nullable PSPDFDocument *)document configuration:(nullable PSPDFConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

/// Convenience init for `initWithDocument:configuration:` that uses a default configuration set.
- (instancetype)initWithDocument:(nullable PSPDFDocument *)document;

/// Property for the currently displayed document.
/// @note To allow easier setup via Storyboards, this property also accepts `NSString`s. (The default bundle path will be used.)
@property (nonatomic, nullable) PSPDFDocument *document;

/// Register delegate to capture events, change properties.
@property (nonatomic, weak) IBOutlet id<PSPDFViewControllerDelegate> delegate;

/// Register to be informed of and direct form submissions.
@property (nonatomic, weak) IBOutlet id<PSPDFFormSubmissionDelegate> formSubmissionDelegate;

/// Reloads the view hierarchy. Required for most changes in the document and for configuration changes.
/// @note This is called implicitly with `updateConfigurationWithBuilder:`.
/// @warning Reloading the view hierarchy will reset the zoom level, but will maintain the current page.
- (IBAction)reloadData;

/// @name Page Scrolling

/// Set current page. Page starts at 0.
@property (nonatomic) NSUInteger page;

/// If we're in double page mode, this will return the current screen page, else it's equal to page.
/// e.g. if you have 50 pages, you get 25/26 "double pages" when in double page mode.
@property (nonatomic, readonly) NSUInteger screenPage;

/// Set current page, optionally animated. Page starts at `0`. Returns `NO` if page is invalid (e.g. out of bounds).
/// If the document is currently locked, this method returns `NO` and `page` property remains `0`. The set page
/// value is however preserved internally and restored when the controller reloads after the document is unlocked.
/// @note The transition will only be animated if the destination page is close to the current page
/// (less than 3 pages away), even if `animated` is set to `YES`.
- (BOOL)setPage:(NSUInteger)page animated:(BOOL)animated;

/// Scroll to next page. Will potentially advance two pages in dualPage mode.
- (BOOL)scrollToNextPageAnimated:(BOOL)animated;

/// Scroll to previous page. Will potentially decrease two pages in dualPage mode.
- (BOOL)scrollToPreviousPageAnimated:(BOOL)animated;

/// Enable/disable scrolling. Can be used in special cases where scrolling is turned off (temporarily). Defaults to YES.
@property (nonatomic, getter=isScrollingEnabled) BOOL scrollingEnabled;

/// Locks the view. Disables scrolling, zooming and gestures that would invoke scrolling/zooming. Also blocks programmatically calls to scrollToPage. This is useful if you want to invoke a "drawing mode". (e.g. Ink Annotation drawing)
/// @warning This might be disabled after a reloadData.
@property (nonatomic, getter=isViewLockEnabled) BOOL viewLockEnabled;

/// @name Zooming

/// Scrolls to a specific rect on the current page.
/// @note `rect` is in screen coordinate space. If you want to use PDF coordinates, convert them via:
/// `PSPDFConvertPDFRectToViewRect()` or `-convertPDFPointToViewPoint:` of `PSPDFPageView`.
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated;

/// Zooms to a specific view rect, optionally animated.
- (void)zoomToRect:(CGRect)rect page:(NSUInteger)page animated:(BOOL)animated;

/// Zoom to specific scale, optionally animated.
- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated;

/// @name View State Restoration
/// Captures the current view–state of the receiver as a serializable object.
/// @note There may not always be a view–state to capture.
/// Reasons for this include the view not being loaded yet, no document being set, etc.
/// As a rule of thumb, you should only expect to obtain a nonnull value after `viewDidAppear:` and before `viewWillDisappear:` has been called.
- (nullable PSPDFViewState *)captureCurrentViewState;

/// Applies a previously captured view state, optionally animated.
/// @param viewState The state to restore.
/// @param animateIfPossible A hint whether applying the state should be animated.
/// @discussion It is not always possible to animate application of a new view state:
/// Animation only ever happens if the view controller is currently on screen.
/// Therefore, a `YES` value _may_ be silently ignored.
/// A word on timing:
/// The most common use–case for this method is to seamlessly restore the reading position in a document when displaying the receiver.
/// However, since restoring a viewport requires a fairly complete view hierarchy, you should not try to call this method directly after init.
/// If you subclass PSPDFViewController, `viewWillAppear:` and `viewDidLayoutSubviews` (after calling `super`) are good times to do so.
/// @note For PSPDFPageTransitionCurl, only the _page_ is being restored.
- (void)applyViewState:(PSPDFViewState *)viewState animateIfPossible:(BOOL)animateIfPossible;

/// @name Searching

/// Search current page, but don't show any search UI.
/// Dictionary key, expects a boxed boolean as value.
PSPDF_EXPORT NSString *const PSPDFViewControllerSearchHeadlessKey;

/// Searches for `searchText` within the current document.
/// Opens the `PSPDFSearchViewController`, or presents inline search UI based `searchMode` in `PSPDFConfiguration`.
/// If `searchText` is nil, the UI is shown but no search is performed.
/// The only valid option is `PSPDFViewControllerSearchHeadlessKey` to disable the search UI.
/// `options` are also passed through to the `presentViewController:options:animated:sender:completion:` method.
/// `sender` is used to anchor the search popover, if one should be displayed (see `searchMode` in `PSPDFConfiguration`).
- (void)searchForString:(nullable NSString *)searchText options:(nullable NSDictionary<NSString *, id> *)options sender:(nullable id)sender animated:(BOOL)animated;

/// Cancels search and hides search UI.
- (void)cancelSearchAnimated:(BOOL)animated;

/// Returns YES if a search UI is currently being presented.
@property (nonatomic, getter=isSearchActive, readonly) BOOL searchActive;

/// The search view manager
@property (nonatomic, readonly) PSPDFSearchHighlightViewManager *searchHighlightViewManager;

/// The inline search manager used when `PSPDFSearchModeInline` is set.
@property (nonatomic, readonly) PSPDFInlineSearchManager *inlineSearchManager;

/// The appearance manager, responsible for the rendering style and app theme.
@property (nonatomic, readonly) PSPDFAppearanceModeManager *appearanceModeManager;

/// The brightness manager, responsible for controlling screen brightness.
@property (nonatomic, readonly) PSPDFBrightnessManager *brightnessManager;

/// Text extraction class for current document.
/// The delegate is set to this controller. Don't change but create your own text search class instead if you need a different delegate.
/// @note Will be recreated as the document changes. Returns nil if the document is nil. Thread safe.
@property (nonatomic, readonly) PSPDFTextSearch *textSearch;

/// @name Actions

/// Executes a PDF action.
/// `actionContainer` is the object that provides the action (usually an annotation). Can be nil.
- (BOOL)executePDFAction:(nullable PSPDFAction *)action targetRect:(CGRect)targetRect page:(NSUInteger)page animated:(BOOL)animated actionContainer:(nullable id)actionContainer;

/// Represents previously invoked PDF actions and allows navigation through the action history.
/// @note You need to manually update this list if you're executing actions outside of the controller
/// `executePDFAction:targetRect:page:page:actionContainer:` (i.e., using `PSPDFActionExecutor` directly).
@property (nonatomic, readonly) PSPDFBackForwardActionList *backForwardList;

/// @name HUD Controls

/// View that is displayed as HUD.
@property (nonatomic, readonly) PSPDFHUDView *HUDView;

/// Show or hide HUD controls, titlebar, status bar (depending on the appearance properties).
@property (nonatomic, getter=isHUDVisible) BOOL HUDVisible;

/// Show or hide HUD controls. optionally animated.
- (BOOL)setHUDVisible:(BOOL)show animated:(BOOL)animated;

/// Show the HUD. Respects `HUDViewMode`.
- (BOOL)showControlsAnimated:(BOOL)animated;

/// Hide the HUD. Respects `HUDViewMode`.
- (BOOL)hideControlsAnimated:(BOOL)animated;

/// Hide the HUD (respects `HUDViewMode`) and additional elements like page selection.
- (BOOL)hideControlsAndPageElementsAnimated:(BOOL)animated;

/// Toggles the HUD. Respects `HUDViewMode`.
- (BOOL)toggleControlsAnimated:(BOOL)animated;

/// Content view. Use this if you want to add any always-visible UI elements.
/// ContentView does NOT overlay the `navigationBar`/`statusBar`, even if that one is transparent.
@property (nonatomic, readonly) PSPDFRelayTouchesView *contentView;

/// Check this to determine the navigation bar visibility when it is managed by PSPDFKit.
/// Will return the same value as `navigationController.navigationBarHidden` if
/// `shouldHideNavigationBarWithHUD` is not set or HUDViewMode is set to `PSPDFHUDViewModeAlways`.
/// @note PSPDFKit always sets `navigationController.navigationBarHidden` to `NO` when managing
/// navigation bar visibility.
@property (nonatomic, getter=isNavigationBarHidden, readonly) BOOL navigationBarHidden;

/// @name Controller State

/// The controller state that this view controller is currently in.
@property (nonatomic, readonly) PSPDFControllerState controllerState;

/// If `controllerState` equals `PSPDFControllerStateError` or `PSPDFControllerStateLocked`, contains the underlying error.
@property (nonatomic, nullable, readonly) NSError *controllerStateError;

/// The view controller that is used to present the current controller state overlay of the `PSPDFViewController`.
///
/// Setting the overlay view controller makes it the child view controller of the receiver.
///
/// @note The default value for this property is an internal view controller that is used to visualize the state.
///       Only set this property if you want to take care of state handling yourself.
@property (nonatomic, nullable) UIViewController<PSPDFControllerStateHandling> *overlayViewController;

/// @name Class Accessors

/// Return the pageView for a given page. Returns nil if page is not Initialized (e.g. page is not visible.)
/// Usually, using the delegates is a better idea to get the current page.
- (nullable PSPDFPageView *)pageViewForPage:(NSUInteger)page;

/// Paging scroll view. (hosts scroll views for PDF)
/// If you want to customize this, override `reloadData` and set the properties after calling super.
@property (nonatomic, readonly, nullable) UIScrollView *pagingScrollView;

/// @name View Mode

/// Get or set the current view mode. (`PSPDFViewModeDocument` or `PSPDFViewModeThumbnails`)
@property (nonatomic) PSPDFViewMode viewMode;

/// Set the view mode, optionally animated.
- (void)setViewMode:(PSPDFViewMode)viewMode animated:(BOOL)animated;

/// The controller shown in the `PSPDFViewModeThumbnails` view mode. Contains a (grid) collectionView. Lazily created.
@property (nonatomic, readonly) PSPDFThumbnailViewController *thumbnailController;

/// The controller shown in the `PSPDFViewModeDocumentEditor` view mode. Lazily created.
/// @note Requires the Document Editor component to be enabled for your license.
@property (nonatomic, readonly) PSPDFDocumentEditorViewController *documentEditorController;

/// @name Helpers

/// Return an NSNumber-Array of currently visible page numbers.
/// @warning This might return more numbers than actually visible if it's queried during a scroll animation.
@property (nonatomic, readonly) NSOrderedSet<NSNumber *> *visiblePages;

/// Return array of all currently visible `PSPDFPageView` objects.
@property (nonatomic, readonly) NSArray<PSPDFPageView *> *visiblePageViews;

/// Depending on pageMode, this returns true if two pages are displayed.
@property (nonatomic, getter=isDoublePageMode, readonly) BOOL doublePageMode;

/// Returns YES if the document is at the last page.
@property (nonatomic, getter=isLastPage, readonly) BOOL lastPage;

/// Returns YES if the document is at the first page.
@property (nonatomic, getter=isFirstPage, readonly) BOOL firstPage;

@end

@interface PSPDFViewController (Configuration)

/// The configuration. Defaults to `+[PSPDFConfiguration defaultConfiguration]`.
/// @warning You cannot set this property to `nil` since the pdf controller must always have a configuration.
@property (nonatomic, copy, readonly) PSPDFConfiguration *configuration;

/// Allows to change any value within `PSPDFConfiguration` and correctly updates the state in the controller.
/// @note This will invoke `reloadData` to apply the changes, which will reset the zoom level back to 1.0.
- (void)updateConfigurationWithBuilder:(void (^)(PSPDFConfigurationBuilder *builder))builderBlock;

/// Allows to update the configuration without triggering a reload.
/// @warning You should know what you're doing with using this updater.
/// The `PSPDFViewController` will not be reloaded, which can bring it into a invalid state.
/// Use this for properties that don't require reloading such as `textSelectionEnabled` or `scrollOnTapPageEndEnabled`.
- (void)updateConfigurationWithoutReloadingWithBuilder:(void (^)(PSPDFConfigurationBuilder *builder))builderBlock;

@end

// See PSPDFPresentationActions.h for compatible keys for `options`.
@interface PSPDFViewController (Presentation)

/// Show a modal view controller or a popover with automatically added close button on the left side.
/// Use sender (`UIBarButtonItem` or `UIView`) OR rect in `options` (both only needed for the popover)
/// @note If this returns NO, the completion block won't be called and presentation was blocked.
- (BOOL)presentViewController:(UIViewController *)controller options:(nullable NSDictionary<NSString *, id> *)options animated:(BOOL)animated sender:(nullable id)sender completion:(nullable void (^)(void))completion;

/// Dismisses a view controller or popover controller, if class matches.
- (BOOL)dismissViewControllerOfClass:(nullable Class)controllerClass animated:(BOOL)animated completion:(nullable void (^)(void))completion;

// PSPDFActionExecutorDelegate

/// Invoked when a document action wants to present a new document modally. Can be subclassed to change behavior.
- (void)presentPDFViewControllerWithDocument:(PSPDFDocument *)document options:(nullable NSDictionary<NSString *, id> *)options sender:(nullable id)sender animated:(BOOL)animated configurationBlock:(nullable void (^)(PSPDFViewController *pdfController))configurationBlock completion:(nullable void (^)(void))completion;

/// Allows file preview using QuickLook. Will call `presentPDFViewControllerWithDocument:` if the pdf filetype is detected.
- (void)presentPreviewControllerForURL:(NSURL *)fileURL title:(nullable NSString *)title options:(nullable NSDictionary<NSString *, id> *)options sender:(nullable id)sender animated:(BOOL)animated completion:(nullable void (^)(void))completion;

/**
*  Preconfigures the activity view controller for a certain sender.
*
*  @param sender can be a bar button item, a view or a boxed rect.
*
*  @return A preconfigured activity view controller subclass or nil if the document is nil.
*/
- (nullable UIActivityViewController *)activityViewControllerWithSender:(id)sender;

@end

@interface PSPDFViewController (Annotations)

/// A convenience accessor for a pre-configured, persistent, annotation state manager for the controller.
@property (nonatomic, readonly) PSPDFAnnotationStateManager *annotationStateManager;

@end

@interface PSPDFViewController (Toolbar)

/// @name Toolbar button items

/// Use this if you want to customize the navigation bar appearance of a `PSPDFViewController`.
/// @note This creates a `navigationItem` on demand, only call this method if you need it.
@property (nonatomic, readonly) PSPDFNavigationItem *navigationItem;

/// Default button in leftBarButtonItems if view is presented modally.
@property (nonatomic, readonly) UIBarButtonItem *closeButtonItem;

/// Presents the `PSPDFOutlineViewController` if there is an outline defined in the PDF.
/// @note Also available as activity via `PSPDFActivityTypeOutline`.
@property (nonatomic, readonly) UIBarButtonItem *outlineButtonItem;

/// Presents the `PSPDFSearchViewController` or the `PSPDFInlineSearchManager` for searching text in the current `document`.
/// @see `PSPDFSearchMode` in `PSPDFConfiguration` to configure this.
/// @note Also available as activity via `PSPDFActivityTypeSearch`.
@property (nonatomic, readonly) UIBarButtonItem *searchButtonItem;

/// Toggles between the document and the thumbnails view state (`PSPDFViewModeThumbnails`).
/// @see `PSPDFViewMode`
/// @see `setViewMode:animated:`
@property (nonatomic, readonly) UIBarButtonItem *thumbnailsButtonItem;

/// Toggles between the document and the document editor view state (`PSPDFViewModeDocumentEditor`).
/// @note Requires the Document Editor component to be enabled for your license.
/// @see `PSPDFViewMode`
/// @see `setViewMode:animated:`
@property (nonatomic, readonly) UIBarButtonItem *documentEditorButtonItem;

/// Presents the `UIPrintInteractionController` for document printing.
/// @note Only displayed if document is allowed to be printed (see `allowsPrinting` in `PSPDFDocument`)
/// @note You should use the `activityButtonItem` instead (`UIActivityTypePrint`).
@property (nonatomic, readonly) UIBarButtonItem *printButtonItem;

/// Presents the `UIDocumentInteractionController` controller to open documents in other apps.
/// @note You should use the `activityButtonItem` instead (`PSPDFActivityTypeOpenIn`).
@property (nonatomic, readonly) UIBarButtonItem *openInButtonItem;

/// Presents the `MFMailComposeViewController` to send the document via email.
/// @note Will only work when sending emails is configured on the device.
/// @note You should use the `activityButtonItem` instead (`UIActivityTypeMail`).
@property (nonatomic, readonly) UIBarButtonItem *emailButtonItem;

/// Presents the `MFMessageComposeViewController` to send the document via SMS/iMessage.
/// @note Will only work if iMessage or SMS is configured on the device.
/// @note You should use the `activityButtonItem` instead (`UIActivityTypeMessage`).
@property (nonatomic, readonly) UIBarButtonItem *messageButtonItem;

/// Shows and hides the `PSPDFAnnotationToolbar` toolbar for creating annotations.
/// @note Requires the `PSPDFFeatureMaskAnnotationEditing` feature flag.
@property (nonatomic, readonly) UIBarButtonItem *annotationButtonItem;

/// Presents the `PSPDFBookmarkViewController` for creating/editing/viewing bookmarks.
/// @note Also available as activity via `PSPDFActivityTypeBookmarks`.
@property (nonatomic, readonly) UIBarButtonItem *bookmarkButtonItem;

/// Presents the `PSPDFBrightnessViewController` to control screen brightness.
/// @note iOS has a similar feature in the control center, but PSPDFKit brightness includes an additional software brightener.
@property (nonatomic, readonly) UIBarButtonItem *brightnessButtonItem;

/// Presents the `UIActivityViewController` for various actions, including many of the above button items.
@property (nonatomic, readonly) UIBarButtonItem *activityButtonItem;

/// Presents the `PSPDFSettingsViewContoller` to control some aspects of PSPDFViewController UX.
@property (nonatomic, readonly) UIBarButtonItem *settingsButtonItem;

/// Add your custom `UIBarButtonItems` so that they won't be automatically enabled/disabled.
/// @warning This needs to be set before setting `left/rightBarButtonItems`.
@property (nonatomic, copy) NSArray<UIBarButtonItem *> *barButtonItemsAlwaysEnabled;

/// Handler for all document related actions.
@property (nonatomic, readonly) PSPDFDocumentActionExecutor *documentActionExecutor;

/// Handles the controllers for metadata infos (outline, annotations, bookmarks, embedded files)
@property (nonatomic, readonly) PSPDFDocumentInfoCoordinator *documentInfoCoordinator;

/// Accesses and manages the annotation toolbar.
/// To check if the toolbar is visible, check if a window is set on the toolbar.
@property (nonatomic, readonly, nullable) PSPDFAnnotationToolbarController *annotationToolbarController;

@end

@interface PSPDFViewController (SubclassingHooks)

/// Override this initializer to allow all use cases (storyboard loading, etc)
/// @warning Do not call this method directly, except for calling super when overriding it.
- (void)commonInitWithDocument:(nullable PSPDFDocument *)document configuration:(PSPDFConfiguration *)configuration NS_REQUIRES_SUPER;

/// Override if you're changing the toolbar to your own.
/// The toolbar is only displayed, if `PSPDFViewController` is inside a `UINavigationController`.
- (void)updateToolbarAnimated:(BOOL)animated;

/// Called when `viewWillLayoutSubviews` is triggered.
/// @note You can use this to adapt to view frame changes (i.e., add or remove toolbar items). Check `pdfController.traitCollection` and act accordingly.
- (void)setUpdateSettingsForBoundsChangeBlock:(void (^)(PSPDFViewController *pdfController))block;

/// Return rect of the content view area excluding translucent toolbar/status bar.
/// @note This method does not compensate for the navigation bar alone. Returns the view bounds when the view controller is not visible. 
@property (nonatomic, readonly) CGRect contentRect;

/// Reload a specific page.
- (void)updatePage:(NSUInteger)page animated:(BOOL)animated;

/// Bar Button Actions
- (void)annotationButtonPressed:(nullable id)sender;

@end

@interface PSPDFViewController (Deprecated)

@property (nonatomic, readonly) UIBarButtonItem *viewModeButtonItem PSPDF_DEPRECATED(5.3, "Use thumbnailsButtonItem instead.");

/// Bar button items displayed at the left of the toolbar. Must be `UIBarButtonItem` instances.
/// Defaults to `[closeButtonItem]` if view is presented modally.
/// @note UIKit limits the left toolbar size if space is low in the toolbar, potentially cutting off buttons in those toolbars if the title is also too long. You can either reduce the number of buttons, cut down the text or use a `titleView` to fix this problem. It also appears that UIKit focuses on the leftToolbar, the right one is cut off much later. This problem only appears on the iPad in portrait mode. You can also use `updateSettingsForBoundsChangeBlock` to adapt the toolbar for portrait/landscape mode.
/// @warning If you use any of the provided bar button items in a custom toolbar, make sure to set `leftBarButtonItems` and `rightBarButtonItems` to nil - an `UIBarButtonItem` can only ever have one parent, else some icons might "vanish" from your toolbar.
@property (nonatomic, copy, null_resettable) NSArray<UIBarButtonItem *> *leftBarButtonItems PSPDF_DEPRECATED(5.3, "Use the appropriate methods on navigationItem instead.");

/// Bar button items displayed at the right of the toolbar. Must be `UIBarButtonItem` instances.
/// Defaults to `@[self.searchButtonItem, self.outlineButtonItem, self.thumbnailsButtonItem]`;
/// @warning If you use any of the provided bar button items in a custom toolbar, make sure to set `leftBarButtonItems` and `rightBarButtonItems` to nil - an `UIBarButtonItem` can only ever have one parent, else some icons might "vanish" from your toolbar.
@property (nonatomic, copy, null_resettable) NSArray<UIBarButtonItem *> *rightBarButtonItems PSPDF_DEPRECATED(5.3, "Use the appropriate methods on navigationItem instead. Note that the order of items will need to be reversed.");

/// Saves the view state into a serializable object. (`page`/`zoom`/`position`)
/// @note For PSPDFPageTransitionCurl, only the _page_ is being restored.
@property (nullable, nonatomic) PSPDFViewState *viewState PSPDF_DEPRECATED(5.2, "Please use captureCurrentViewState or applyViewState:animateIdPossible: instead");

/// Restores the view state, optionally animated. (`page`/`zoom`/`position`)
/// @param viewState The state to restore.
/// @param animateIfPossible A hint whether applying the state should be animated.
/// @discussion It is not always possible to animate setting a new view state:
/// Animation only ever happens if the view controller is currently on screen.
/// Therefore, a `YES` value _may_ be silently ignored.
/// @note For PSPDFPageTransitionCurl, only the _page_ is being restored.
- (void)setViewState:(PSPDFViewState *)viewState animated:(BOOL)animateIfPossible PSPDF_DEPRECATED(5.2, "Please use applyViewState:animateIdPossible: instead");

@end

NS_ASSUME_NONNULL_END
