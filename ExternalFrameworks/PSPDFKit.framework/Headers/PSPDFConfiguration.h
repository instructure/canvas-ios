//
//  PSPDFConfiguration.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import "PSPDFMacros.h"
#import "PSPDFVersion.h"
#import "PSPDFOverridable.h"
#import "PSPDFModel.h"
#import "PSPDFBookmark.h"
#import "PSPDFDocumentSharingViewController.h"
#import "PSPDFAnnotation.h"
#import "PSPDFAppearanceModeManager.h"
#import "PSPDFSettingsViewController.h"

@protocol PSPDFSignatureStore;

/// Page Transition. Can be scrolling or something more fancy.
typedef NS_ENUM(NSUInteger, PSPDFPageTransition) {
    /// One scroll view per page.
    PSPDFPageTransitionScrollPerPage,
    /// Similar to `UIWebView`. Ignores `PSPDFPageModeDouble`.
    PSPDFPageTransitionScrollContinuous,
    /// Page curl mode, similar to iBooks. Not supported with variable sized PDFs.
    PSPDFPageTransitionCurl
} PSPDF_ENUM_AVAILABLE;

/// Active page mode.
typedef NS_ENUM(NSUInteger, PSPDFPageMode) {
    /// Always show a single page.
    PSPDFPageModeSingle,
    /// Always show two pages side-by-side.
    PSPDFPageModeDouble,
    /// Show two pages only when the view is sufficiently large and two pages can be shown without too much shrinking. This is the default.
    PSPDFPageModeAutomatic
} PSPDF_ENUM_AVAILABLE;

/// Active scrolling direction. Only relevant for scrolling page transitions.
typedef NS_ENUM(NSUInteger, PSPDFScrollDirection) {
    /// Default horizontal scrolling.
    PSPDFScrollDirectionHorizontal,
    /// Vertical scrolling.
    PSPDFScrollDirectionVertical
} PSPDF_ENUM_AVAILABLE;

/// Current active view mode.
typedef NS_ENUM(NSUInteger, PSPDFViewMode) {
    /// Document is visible.
    PSPDFViewModeDocument,
    /// Thumbnails are visible.
    PSPDFViewModeThumbnails,
    /// Shows thumbnails and page editing options.
    PSPDFViewModeDocumentEditor
} PSPDF_ENUM_AVAILABLE;

/// Default action for PDF link annotations.
typedef NS_ENUM(NSUInteger, PSPDFLinkAction) {
    /// Link actions are ignored.
    PSPDFLinkActionNone,
    /// Link actions open an `UIAlertView`.
    PSPDFLinkActionAlertView,
    /// Link actions directly open Safari.
    PSPDFLinkActionOpenSafari,
    /// Link actions open in an inline browser (`SFSafariViewController` if available, falling back on `PSPDFWebViewController`).
    PSPDFLinkActionInlineBrowser,

    /// Always uses `PSPDFWebViewController`, even when `SFSafariViewController` is available.
    /// Not generally recommended but might be required in certain settings for more control.
    PSPDFLinkActionInlineBrowserLegacy
} PSPDF_ENUM_AVAILABLE;

/// Defines the text selection mode in `PSPDFTextSelectionView`.
/// Requires `PSPDFFeatureMaskTextSelection` to be enabled and `textSelectionEnabled` set to YES.
typedef NS_ENUM(NSUInteger, PSPDFTextSelectionMode) {
    /// Regular text selection mode is similar to Mobile Safari, using two different loupes.
    /// A word will be selected on touch up.
    PSPDFTextSelectionModeRegular,

    /// In simple selection mode, the selection behavior starts immediately on touch down.
    /// This is similar to iBooks and useful for applications where highlighting is a main feature.
    PSPDFTextSelectionModeSimple
} PSPDF_ENUM_AVAILABLE;

/// Customize how a single page should be displayed.
typedef NS_ENUM(NSUInteger, PSPDFPageRenderingMode) {
    /// Load cached page async.
    PSPDFPageRenderingModeThumbnailThenFullPage,
    /// Load cached page async. Thumbnail only if in memory.
    PSPDFPageRenderingModeThumbnailIfInMemoryThenFullPage,
    /// Load cached page async, no upscaled thumb.
    PSPDFPageRenderingModeFullPage,
    /// Load cached page directly.
    PSPDFPageRenderingModeFullPageBlocking,
    /// Don't use cached page but thumb.
    PSPDFPageRenderingModeThumbnailThenRender,
    /// Don't use cached page nor thumb.
    PSPDFPageRenderingModeRender
} PSPDF_ENUM_AVAILABLE;

/// Menu options when text is selected on this document.
typedef NS_OPTIONS(NSUInteger, PSPDFTextSelectionMenuAction) {
    /// No text selection actions.
    PSPDFTextSelectionMenuActionNone      = 0,
    /// Allow search from selected text.
    PSPDFTextSelectionMenuActionSearch    = 1 << 0,
    /// Offers to show "Define" on selected text.
    PSPDFTextSelectionMenuActionDefine    = 1 << 1,
    /// Offers a toggle for Wikipedia.
    PSPDFTextSelectionMenuActionWikipedia = 1 << 2,
    /// Allows text-to-speech.
    PSPDFTextSelectionMenuActionSpeak     = 1 << 3,
    PSPDFTextSelectionMenuActionAll       = NSUIntegerMax
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSUInteger, PSPDFThumbnailBarMode) {
    /// Don't show thumbnail bottom bar.
    PSPDFThumbnailBarModeNone,
    /// Show scrubber bar (like iBooks, `PSPDFScrubberBar`)
    PSPDFThumbnailBarModeScrubberBar,
    /// Show scrollable thumbnail bar (`PSPDFThumbnailBar`)
    PSPDFThumbnailBarModeScrollable
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSUInteger, PSPDFScrubberBarType) {
    /// The default style: A scrubber bar that lays out its thumbnails along its width.
    PSPDFScrubberBarTypeHorizontal,
    /// Style for a scrubber bar that lays out its thumbnails along its height and sits along the left edge of its container.
    /// (I.e. it draws a border on its _right–hand_ side.)
    PSPDFScrubberBarTypeVerticalLeft,
    /// Style for a scrubber bar that lays out its thumbnails along its height and sits along the right edge of its container view.
    /// (I.e. it draws a border on its _left–hand_ side.)
    PSPDFScrubberBarTypeVerticalRight,
} PSPDF_ENUM_AVAILABLE;

/// Thumbnail grouping setting for `PSPDFThumbnailBarModeScrollable` and the `PSPDFThumbnailViewController`.
typedef NS_ENUM(NSUInteger, PSPDFThumbnailGrouping) {
    /// Group double pages when `PSPDFPageModeDouble` is enabled.
    PSPDFThumbnailGroupingAutomatic,
    /// Never group double pages for thumbnails.
    PSPDFThumbnailGroupingNever,
    /// Always group double pages for thumbnails.
    PSPDFThumbnailGroupingAlways
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSUInteger, PSPDFHUDViewMode) {
    /// Always show the HUD.
    PSPDFHUDViewModeAlways,
    /// Show HUD on touch and first/last page.
    PSPDFHUDViewModeAutomatic,
    /// Show HUD on touch.
    PSPDFHUDViewModeAutomaticNoFirstLastPage,
    /// Never show the HUD.
    PSPDFHUDViewModeNever
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSUInteger, PSPDFHUDViewAnimation) {
    /// Don't animate HUD appearance.
    PSPDFHUDViewAnimationNone,
    /// Fade HUD in/out.
    PSPDFHUDViewAnimationFade,
    /// Slide HUD.
    PSPDFHUDViewAnimationSlide
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSUInteger, PSPDFSearchMode) {
    /// Display search results in a modal view.
    PSPDFSearchModeModal,
    /// Display search results inline.
    PSPDFSearchModeInline
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSUInteger, PSPDFRenderStatusViewPosition) {
    /// Display render status view at the top.
    PSPDFRenderStatusViewPositionTop,
    /// Display render status view at the center.
    PSPDFRenderStatusViewPositionCentered
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSUInteger, PSPDFTapAction) {
    /// Nothing happens.
    PSPDFTapActionNone,
    /// Zoom to the center of the user's tap.
    PSPDFTapActionZoom,
    /// Detect text blocks and zoom to the tapped text block.
    PSPDFTapActionSmartZoom,
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSUInteger, PSPDFAdaptiveConditional) {
    /// Same as BOOL `NO`.
    PSPDFAdaptiveConditionalNO,
    /// Same as BOOL `YES`.
    PSPDFAdaptiveConditionalYES,
    /// Adaptive, the value is determinate based on the current app state (e.g., current size classes).
    PSPDFAdaptiveConditionalAdaptive
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSUInteger, PSPDFScrollInsetAdjustment) {
    /// Never adjust scroll view insets.
    PSPDFScrollInsetAdjustmentNone,
    /// Adjust scroll view insets if the HUD elements are always visible
    /// (e.g., `PSPDFHUDViewModeAlways`, or disabled `shouldHideNavigationBarWithHUD`).
    PSPDFScrollInsetAdjustmentFixedElements,
    /// Adjust scrooll view insets whenever HUD elements are visible.
    PSPDFScrollInsetAdjustmentAllElements
} PSPDF_ENUM_AVAILABLE;

@class PSPDFAnnotationGroup, PSPDFConfigurationBuilder, PSPDFGalleryConfiguration;

NS_ASSUME_NONNULL_BEGIN

/// A `PSPDFConfiguration` defines the behavior of a `PSPDFViewController`.
/// It uses the builder pattern via `PSPDFConfigurationBuilder` to create an immutable copy via a block.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFConfiguration : PSPDFModel <PSPDFOverridable>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Returns a copy with the default configuration.
+ (PSPDFConfiguration *)defaultConfiguration;

/// Returns a copy of the default configuration.
/// Provide a `builderBlock` to change the value of properties.
+ (PSPDFConfiguration *)configurationWithBuilder:(nullable void (^)(PSPDFConfigurationBuilder *builder))builderBlock;

/// Modifies an existing configuration with new changes.
- (PSPDFConfiguration *)configurationUpdatedWithBuilder:(void (^)(PSPDFConfigurationBuilder *builder))builderBlock;


/// @name Appearance Properties

/// Set a PageMode defined in the enum. (Single/Double Pages)
/// Reloads the view, unless it is set while rotation is active. Thus, one can customize the size change behavior by setting this within a size transition animation block. Defaults to `PSPDFPageModeAutomatic`.
/// Ignored when `pageTransition` is set to `PSPDFPageTransitionScrollContinuous`.
@property (nonatomic, readonly) PSPDFPageMode pageMode;


/// Defines the page transition.
/// @warning If you change the property dynamically in `viewWillTransitionToSize:withTransitionCoordinator:`, wait for the transition to finish using the coordinator’s completion block, otherwise the controller will get in an invalid state. Child view controllers get rotation events AFTER the parent view controller, so if you're changing this from a parent viewController, for PSPDFKit the rotation hasn't been completed yet, and your app will eventually crash. In that case, use a `dispatch_async(dispatch_get_main_queue(), ^{ ... });` to set. You might just want to set `updateSettingsForBoundsChangeBlock` and set your properties there.
/// @note , we enable the `automaticallyAdjustsScrollViewInsets` by default. If you don't want this behavior, subclass `reloadData` and set this property to NO.
@property (nonatomic, readonly) PSPDFPageTransition pageTransition;

/// Shows first document page alone. Not relevant in `PSPDFPageModeSingle`. Defaults to NO.
@property (nonatomic, getter=isDoublePageModeOnFirstPage, readonly) BOOL doublePageModeOnFirstPage;

/// Allow zooming of small documents to screen width/height. Defaults to YES.
@property (nonatomic, getter=isZoomingSmallDocumentsEnabled, readonly) BOOL zoomingSmallDocumentsEnabled;

/// For Left-To-Right documents, this sets the page curl to go backwards. Defaults to NO.
/// @note Doesn't re-order document pages. There's currently no real LTR support in PSPDFKit.
@property (nonatomic, getter=isPageCurlDirectionLeftToRight, readonly) BOOL pageCurlDirectionLeftToRight;

/// If true, pages are fit to screen width, not to either height or width (which one is larger - usually height.) Defaults to NO.
/// iPhone switches to yes on rotation - reset back to no if you don't want this.
/// @note `fitToWidthEnabled` is not supported for `PSPDFPageTransitionCurl` and might produce suboptimal results with `PSPDFPageTransitionScrollContinuous` + `PSPDFScrollDirectionHorizontal`.
@property (nonatomic, getter=isFitToWidthEnabled, readonly) BOOL fitToWidthEnabled;

/// If this is set to YES, the page remembers its vertical position if `fitToWidthEnabled` is enabled.
/// If NO, new pages will start at the page top position. Defaults to NO.
@property (nonatomic, readonly) BOOL fixedVerticalPositionForFitToWidthEnabledMode;

/// Only useful for `PSPDFPageTransitionCurl`. Clips the page to its boundaries, not showing a pageCurl on empty background. Defaults to YES. Set to NO if your document is variably sized.
@property (nonatomic, readonly) BOOL clipToPageBoundaries;

/// Enable/disable page shadow. Defaults NO.
@property (nonatomic, getter=isShadowEnabled, readonly) BOOL shadowEnabled;

/// Set default shadowOpacity. Defaults to 0.7f.
@property (nonatomic, readonly) CGFloat shadowOpacity;

/// Defaults to a dark gray color.
@property (nonatomic, readonly) UIColor *backgroundColor;

/// Allowed appearance modes for `PSPDFBrightnessViewController`. Defaults to PSPDFAppearanceModeAll.
/// `PSPDFAppearanceModeDefault` is always assumed to be available. Set to only `PSPDFAppearanceModeDefault`
/// to disable appearance mode picker UI. This needs to be set before `PSPDFBrightnessViewController` is presented.
@property (nonatomic, readonly) PSPDFAppearanceMode allowedAppearanceModes;


/// @name Scroll View Configuration

/// Page scrolling direction. Defaults to `PSPDFScrollDirectionHorizontal`. Only relevant for scrolling page transitions.
@property (nonatomic, readonly) PSPDFScrollDirection scrollDirection;

/// Sets the scroll view inset adjustment mode. Defaults to `PSPDFScrollInsetAdjustmentFixedElements`.
/// This is only evaluated for `PSPDFPageTransitionScrollContinuous` & `PSPDFScrollDirectionVertical`.
/// @note This is similar to `automaticallyAdjustsScrollViewInsets` but more tailored to PSPDFKit's use case.
/// @warning `UIViewController's` `automaticallyAdjustsScrollViewInsets` will always be disabled. Don't enable this property.
@property (nonatomic, readonly) PSPDFScrollInsetAdjustment scrollViewInsetAdjustment;

/// Always bounces pages in the set scroll direction.
/// Defaults to NO. If set, pages with only one page will still bounce left/right or up/down instead of being fixed. Corresponds to `UIScrollView's` `alwaysBounceHorizontal` or `alwaysBounceVertical` of the pagingScrollView.
/// @note Only valid for `PSPDFPageTransitionScrollPerPage` or `PSPDFPageTransitionScrollContinuous`.
@property (nonatomic, readonly) BOOL alwaysBouncePages;

/// Controls if the horizontal scroll indicator is displayed. Defaults to YES.
/// @note Indicators are displayed for page zooming in `PSPDFPageTransitionScrollPerPage` and
/// always when in `PSPDFPageTransitionScrollContinuous` mode.
@property (nonatomic, readonly) BOOL showsHorizontalScrollIndicator;

/// Controls if the vertical scroll indicator is displayed. Defaults to YES.
/// @note Indicators are displayed for page zooming in `PSPDFPageTransitionScrollPerPage` and
/// always when in `PSPDFPageTransitionScrollContinuous` mode.
@property (nonatomic, readonly) BOOL showsVerticalScrollIndicator;

/// Minimum zoom scale. Defaults to 1. You usually don't want to change this.
/// @warning This might break certain pageTransitions if not set to 1.
@property (nonatomic, readonly) float minimumZoomScale;

/// Maximum zoom scale for the scrollview. Defaults to 10. Set before creating the view.
@property (nonatomic, readonly) float maximumZoomScale;


/// @name Page Border and Rendering

/// Set margin for document pages. Defaults to `UIEdgeInsetsZero`.
/// The margin can be used to provide extra space for your (always visible) UI elements. The content view will
/// be moved accordingly. Note that if you are adding your UI elements to the `hudView` and have HUD auto hiding
/// enabled, your views will be hidden with the HUD, however the margins will stay the same. In this case it might
/// work best, if you don't add any margins at all. If you do, you will potentially have to adjust them manually.
/// In vertical continuous mode, the margins do not affect the content view in the direction off scrolling.
/// Instead the scroll view insets are modified. Note also that the area outside margin does not receive any touch
/// events, or is shown while zooming.
/// @note You need to call `reloadData` after changing this property.
@property (nonatomic, readonly) UIEdgeInsets margin;

/// Padding for document pages. Defaults to `CGSizeZero`.
/// For `PSPDFPageTransitionScrollPerPage`, padding is space that is displayed around the document. (In fact, the minimum zoom is adapted; thus you can only modify `width`/`height` here (left+right/top+bottom))
/// For `PSPDFPageTransitionScrollContinuous`, top/bottom is used to allow additional space before/after the first/last document
/// When changing padding; the touch area is still fully active.
/// @note You need to call `reloadData` after changing this property.
@property (nonatomic, readonly) UIEdgeInsets padding;

/// Page padding width between single/double pages or between pages for continuous scrolling. Defaults to 20.f.
@property (nonatomic, readonly) CGFloat pagePadding;

/// This manages how the PDF image cache (thumbnail, full page) is used. Defaults to `PSPDFPageRenderingModeThumbnailIfInMemoryThenFullPage`.
/// `PSPDFPageRenderingModeFullPageBlocking` is a great option for `PSPDFPageTransitionCurl`.
/// @warning `PSPDFPageRenderingModeFullPageBlocking` will disable certain page scroll animations.
@property (nonatomic, readonly) PSPDFPageRenderingMode renderingMode;

/// If YES, shows an `UIActivityIndicatorView` on the top right while page is rendering. Defaults to YES.
@property (nonatomic, getter=isRenderAnimationEnabled, readonly) BOOL renderAnimationEnabled;

/// Position of render status view. Defaults to `PSPDFRenderStatusViewPositionTop`.
@property (nonatomic, readonly) PSPDFRenderStatusViewPosition renderStatusViewPosition;

/// @name Page Behavior

/// The action that happens when the user double taps somewhere in the document. Defaults to `PSPDFTapActionSmartZoom`.
@property (nonatomic, readonly) PSPDFTapAction doubleTapAction;

/// If set to YES, automatically focuses on selected form elements. Defaults to NO.
@property (nonatomic, getter=isFormElementZoomEnabled, readonly) BOOL formElementZoomEnabled;

/// Tap on begin/end of page scrolls to previous/next page. Defaults to YES.
@property (nonatomic, getter=isScrollOnTapPageEndEnabled, readonly) BOOL scrollOnTapPageEndEnabled;

/// Page transition to next or previous page via `scrollOnTapPageEndEnabled` is enabled. Defaults to YES.
/// @warning Only effective if `scrollOnTapPageEndEnabled` is set to YES.
@property (nonatomic, getter=isScrollOnTapPageEndAnimationEnabled, readonly) BOOL scrollOnTapPageEndAnimationEnabled;

/// Margin at which the scroll to next/previous tap should be invoked. Defaults to 60.
@property (nonatomic, readonly) CGFloat scrollOnTapPageEndMargin;


/// @name Page Actions

/// Set the default link action for pressing on `PSPDFLinkAnnotations`. Default is `PSPDFLinkActionInlineBrowser`.
/// @note If modal is set in the link, this property has no effect.
@property (nonatomic, readonly) PSPDFLinkAction linkAction;

/// Allows to customize other displayed menu actions when text is selected.
/// Defaults to `PSPDFTextSelectionMenuActionSearch|PSPDFTextSelectionMenuActionDefine`.
@property (nonatomic, readonly) PSPDFTextSelectionMenuAction allowedMenuActions;


/// @name Features

/// Allows text selection. Defaults to YES.
/// @note Requires the `PSPDFFeatureMaskTextSelection` feature flag.
/// This implies that the PDF file actually contains text glyphs.
/// Sometimes text is represented via embedded images or vectors, in that case PSPDFKit can't select it.
@property (nonatomic, getter=isTextSelectionEnabled, readonly) BOOL textSelectionEnabled;

/// Allows image selection. Defaults to NO.
/// @note Requires the `PSPDFFeatureMaskTextSelection` feature flag.
/// This implies that the image is not in vector format. Only supports a subset of all possible image types in PDF.
/// @warning Will only work if `textSelectionEnabled` is also set to YES.
@property (nonatomic, getter=isImageSelectionEnabled, readonly) BOOL imageSelectionEnabled;

/// Defines how the text is selected. Defaults to `PSPDFTextSelectionModeRegular`.
@property (nonatomic, readonly) PSPDFTextSelectionMode textSelectionMode;

/// Enable to always try to snap to words when selecting text. Defaults to NO.
@property (nonatomic, readonly) BOOL textSelectionShouldSnapToWord;

/// Modify what annotations are editable and can be created. Set to nil to completely disable annotation editing/creation.
/// Defaults to all available annotation string constants with the exception of `PSPDFAnnotationStringLink`.
///
/// @warning Some annotation types are only behaviorally different in PSPDFKit but are mapped to basic annotation types,
/// so adding those will only change the creation of those types, not editing.
/// Example: If you add `PSPDFAnnotationStringInk` but not `PSPDFAnnotationStringSignature`,
/// signatures added in previous session will still be editable (since they are Ink annotations).
/// On the other hand, if you set `PSPDFAnnotationStringSignature` but not `PSPDFAnnotationStringInk`,
/// then your newly created signatures will not be movable. See `PSPDFAnnotation.h` for additional comments.
@property (nonatomic, readonly) NSSet<NSString *> *editableAnnotationTypes;

/// Shows a custom cell with configurable color presets for the provided annotation types.
/// Defaults to `PSPDFAnnotationTypeAll`. Set to `PSPDFAnnotationTypeNone` to completely disable color presets.
/// @note The presets are only displayed if the PSPDFStyleManager returns  supported annotation types only.
@property (nonatomic, readonly) PSPDFAnnotationType typesShowingColorPresets;

/// Customize the inspector items globally. This currently affects `PSPDFAnnotationStyleViewController` and `PSPDFFreeTextAccessoryView`.
/// Dictionary in format annotation type string : array of arrays of property strings (`NSArray<NSArray<NSString *> *> *`) OR a block that returns this and takes `annotations` as argument (`NSArray<NSArray<NSString *> *> *(^block)(PSPDFAnnotation *annotation)`).
/// The following properties are currently supported:
/// `color`, `fillColor`, `alpha`,
/// `lineWidth`, `lineEnd1`, `lineEnd2`,
/// `fontName`, `fontSize`, `textAlignment`, `lineEnd`.
/// @note If you want to disable all color editing, be sure to also remove the relevant type from `typesShowingColorPresets` (also available in `PSPDFConfiguration`).
@property (nonatomic, readonly) NSDictionary<NSString *, id> *propertiesForAnnotations;

/// Shows a toolbar with text editing options (`PSPDFFreeTextAccessoryView`) above the keyboard, while editing
/// free text annotations. You need to set this property before the text annotation is edited. Defaults to `YES`.
@property (nonatomic, getter=isFreeTextAccessoryViewEnabled, readonly) BOOL freeTextAccessoryViewEnabled;

/// Controls how bookmarks are displayed and managed.
/// While bookmarks have a custom order, the default is set to `PSPDFSortOrderPageBased`.
@property (nonatomic, readonly) PSPDFSortOrder bookmarkSortOrder;

/// @name HUD Settings

/// Manages the show/hide mode of the HUD view. Defaults to `PSPDFHUDViewModeAutomatic`.
/// @note The HUD consists of the thumbnail view at the bottom and the page/document label.
/// The visibility of the navigation bar of the parent navigation controller can be linked to the HUD via enabling `shouldHideNavigationBarWithHUD`.
/// @warning HUD will not change when changing this mode after controller is visible. Use `setHUDVisible:animated:` instead.
/// Does not affect manual calls to `setHUDVisible`.
@property (nonatomic, readonly) PSPDFHUDViewMode HUDViewMode;

/// Sets the way the HUD will be animated. Defaults to `PSPDFHUDViewAnimationFade`.
@property (nonatomic, readonly) PSPDFHUDViewAnimation HUDViewAnimation;

/// Enables/Disables the bottom document site position overlay.
/// Defaults to YES. Animatable. Will be added to the HUDView.
/// @note Requires a `setNeedsLayout` on `PSPDFHUDView` to update if there's no full reload.
@property (nonatomic, getter=isPageLabelEnabled, readonly) BOOL pageLabelEnabled;

/// Enable/disable the top document label overlay. Defaults to PSPDFAdaptiveConditionalAdaptive -
/// the document label is shown if there's not enough space to set the navigation bar title instead.
/// @note Requires a `setNeedsLayout` on the `PSPDFViewController` view to update if there's no full reload.
@property (nonatomic, readonly) PSPDFAdaptiveConditional documentLabelEnabled;

/// Automatically hides the HUD when the user starts scrolling to different pages in the document. Defaults to YES.
@property (nonatomic, readonly) BOOL shouldHideHUDOnPageChange;

/// Should show the HUD on `viewWillAppear:`, unless the HUD is disabled. Defaults to YES.
@property (nonatomic, readonly) BOOL shouldShowHUDOnViewWillAppear;

/// Allow PSPDFKit to change the title of this view controller.
/// If `YES`, the controller title will be set to the document title or `nil`, depending on whether the
/// document label is visible or not. Set to `NO`, to manage the viewController title manually. Defaults to YES.
@property (nonatomic, readonly) BOOL allowToolbarTitleChange;

/// If YES, the navigation bar will be hidden when the HUD is hidden. If NO, the navigation will stay
/// shown or hidden depending on the value of `[UINavigationController navigationBarHidden]`. Defaults to YES.
@property (nonatomic, readonly) BOOL shouldHideNavigationBarWithHUD;

/// If YES, the status bar will always remain hidden (regardless of the `shouldHideStatusBarWithHUD` setting).
/// The setting is also passed on to internally created sub-controllers. Defaults to NO.
@property (nonatomic, readonly) BOOL shouldHideStatusBar;

/// If YES, the status bar will be hidden when the HUD is hidden. Defaults to YES.
/// @note Needs to be set before the view is loaded.
/// @note This setting is ignored when the navigation bar is always visible (`shouldHideNavigationBarWithHUD`
/// and `[UINavigationController navigationBarHidden]` both set to `NO`).
@property (nonatomic, readonly) BOOL shouldHideStatusBarWithHUD;


/// @name Action navigation

/// Shows a floating back button in the lower part of the screen.
/// Used to navigate back to the origin page when navigating via PDF actions.
/// Defaults to `YES`.
@property (nonatomic, readonly) BOOL showBackActionButton;

/// Shows a floating forward button in the lower part of the screen.
/// Used to revert the back button navigation action.
/// Defaults to `YES`.
@property (nonatomic, readonly) BOOL showForwardActionButton;

/// Adds text labels representing the destination name to the back and forward buttons.
/// Defaults to `YES` on iPad and `NO` otherwise.
@property (nonatomic, readonly) BOOL showBackForwardActionButtonLabels;


/// @name Thumbnail Settings

/// Sets the thumbnail bar mode. Defaults to `PSPDFThumbnailBarModeScrubberBar`.
/// @note Requires a `setNeedsLayout` on `PSPDFHUDView` to update if there's no full reload.
@property (nonatomic, readonly) PSPDFThumbnailBarMode thumbnailBarMode;

/// Controls the placement of the scrubber bar.
@property (nonatomic, readonly) PSPDFScrubberBarType scrubberBarType;

/// Controls the thumbnail grouping. Defaults to `PSPDFThumbnailGroupingAutomatic`
@property (nonatomic, readonly) PSPDFThumbnailGrouping thumbnailGrouping;

/// The thumbnail size for `PSPDFThumbnailViewController`.
/// If one of the width or height is zero, this dimension will be determined from the page aspect ratio.
/// If both the width and height are zero (the default) then the size is automatic and adaptive, based on the page sizes and view size.
@property (nonatomic, readonly) CGSize thumbnailSize;

/// The minimum internal horizontal space between thumbnails in `PSPDFThumbnailViewController`.
/// The default depends on the screen size, and is the same as `thumbnailLineSpacing` and each element in `thumbnailMargin`.
@property (nonatomic, readonly) CGFloat thumbnailInteritemSpacing;

/// The minimum internal vertical space between thumbnails in `PSPDFThumbnailViewController`.
/// The default depends on the screen size, and is the same as `thumbnailInteritemSpacing` and each element in `thumbnailMargin`.
@property (nonatomic, readonly) CGFloat thumbnailLineSpacing;

/// The external margin around the grid of thumbnails in thumbnail view mode.
/// The default depends on the screen size, with all elements the same as `thumbnailInteritemSpacing` and `thumbnailLineSpacing`.
@property (nonatomic, readonly) UIEdgeInsets thumbnailMargin;


/// @name Annotation Settings

/// Overlay annotations are faded in. Set global duration for this fade here. Defaults to 0.25f.
@property (nonatomic, readonly) CGFloat annotationAnimationDuration;

/// If set to YES, you can group/ungroup annotations with the multi-select tool.
/// Defaults to YES.
@property (nonatomic, readonly) BOOL annotationGroupingEnabled;

/// If set to YES, a long-tap that ends on a page area that is not a text/image will show a new menu to create annotations. Defaults to YES.
/// If set to NO, there's no menu displayed and the loupe is simply hidden.
/// Menu can be intercepted and customized with the `shouldShowMenuItems:atSuggestedTargetRect:forAnnotation:inRect:onPageView:` delegate. (when annotation is nil)
/// @note Requires the `PSPDFFeatureMaskAnnotationEditing` feature flag.
@property (nonatomic, getter=isCreateAnnotationMenuEnabled, readonly) BOOL createAnnotationMenuEnabled;

/// Types allowed in the create annotations menu. Defaults to the most common annotation types. (strings)
/// Contains a list of `PSPDFAnnotationGroup` and `PSPDFAnnotationGroupItem` items.
/// @note There is no visual separation for different groups.
/// Types that are not listed in `editableAnnotationTypes` will be ignored.
@property (nonatomic, copy, readonly) NSArray<PSPDFAnnotationGroup *> *createAnnotationMenuGroups;

/// Enables natural drawing for ink annotations.
@property (nonatomic, readonly) BOOL naturalDrawingAnnotationEnabled;

/// If YES, the annotation menu will be displayed after an annotation has been created. Defaults to NO.
@property (nonatomic, readonly) BOOL showAnnotationMenuAfterCreation;

/// If YES, asks the user to specify a custom annotation username when first creating a new annotation
/// (triggered by the `PSPDFAnnotationStateManager` changing its state).
/// A default name will already be suggested based on the device name.
/// You can change the default username by setting `-[PSPDFDocument defaultAnnotationUsername]`.
/// Defaults to YES.
@property (nonatomic, readonly) BOOL shouldAskForAnnotationUsername;

/// Controls if a second tap to an annotation that allows inline editing enters edit mode. Defaults to YES.
/// (The most probable candidate for this is `PSPDFFreeTextAnnotation`)
@property (nonatomic, readonly) BOOL annotationEntersEditModeAfterSecondTapEnabled;

/// Scrolls to affected page during an undo/redo operation. Defaults to YES.
@property (nonatomic, readonly) BOOL shouldScrollToChangedPage;


/// @name Annotation Saving

/// Controls if PSPDFKit should save at specific points, like when the app enters background or when the view controller disappears.
/// Defaults to YES. Implement `PSPDFDocumentDelegate` to be notified of those saving actions.
@property (nonatomic, getter=isAutosaveEnabled, readonly) BOOL autosaveEnabled;

/// The save method will be invoked when the view controller is dismissed. This increases controller dismissal if enabled.
/// @note Make sure that you don't re-create the `PSPDFDocument` object if you enable background saving, else you might run into race conditions where the old object is still saving and the new one might load outdated/corrupted data.
/// Defaults to NO.
@property (nonatomic, readonly) BOOL allowBackgroundSaving;

/// Describes the time limit for recording sound annotations in seconds. After
/// this time has been reached, the recording will stop.
///
/// Default to 300 (= 5 minutes).
@property (nonatomic, readonly) NSTimeInterval soundAnnotationTimeLimit;


/// @name Search

/// Controls whether to display search results directly in a PDF, or as a list in a modal.
/// The default is `PSPDFSearchModeModal`.
@property (nonatomic, readonly) PSPDFSearchMode searchMode;

/// If a search result is selected, we scroll to the page to make it visible.
/// By default this is set to `1`, which means no zooming is performed.
/// Increase this to zoom to the search result.
/// This value will be clamped by `maximumZoomScale` and should be set below.
/// Values smaller than 1 will be clamped to 1 as well.
///
/// @note This value will be used as a guidance. In case the zoom would be too large,
/// we reduce the scale to ensure the object fits the screen.
@property (nonatomic, readonly) CGFloat searchResultZoomScale;


/// @name Signatures

/// If this is set to NO, PSPDFKit will not differentiate between My Signature/Customer signature.
/// Defaults to YES.
@property (nonatomic, readonly) BOOL signatureSavingEnabled;

/// If enabled, the signature feature will show a menu with a customer signature. (will not be saved)
/// Defaults to YES.
@property (nonatomic, readonly) BOOL customerSignatureFeatureEnabled;

/// Enables natural drawing for signatures. Defaults to YES.
@property (nonatomic, readonly) BOOL naturalSignatureDrawingEnabled;

/// The default signature store implementation.
@property (nonatomic, readonly) id <PSPDFSignatureStore> signatureStore;


/// @name Sharing

/// Pre-provided activity that opens a dialog to go to a specific page.
PSPDF_EXPORT NSString *const PSPDFActivityTypeGoToPage;

/// Pre-provided activity that invokes text search.
PSPDF_EXPORT NSString *const PSPDFActivityTypeSearch;

/// Pre-provided activity that shows the outline view controller.
PSPDF_EXPORT NSString *const PSPDFActivityTypeOutline;

/// Pre-provided activity that shows the bookmark view controller.
PSPDF_EXPORT NSString *const PSPDFActivityTypeBookmarks;

/// Pre-provided activity that shows the open in view controller.
PSPDF_EXPORT NSString *const PSPDFActivityTypeOpenIn;

/// Used for the activity action when the `UIActivityViewController` is displayed.
/// Defaults to `PSPDFActivityTypeOpenIn, PSPDFActivityTypeBookmarks, PSPDFActivityTypeGoToPage`.
/// Accepts both preprovided types as `NSString` and `UIActivity` subclasses.
@property (nonatomic, copy, readonly) NSArray* /* <NSString/UIActivity> */ applicationActivities;

/// Used for the activity action when the `UIActivityViewController` is displayed.
/// Defaults to `UIActivityTypeCopyToPasteboard`, `UIActivityTypeAssignToContact`,
/// `UIActivityTypePostToFacebook`, `UIActivityTypePostToTwitter`, `UIActivityTypePostToWeibo`.
@property (nonatomic, copy, readonly) NSArray<NSString *> *excludedActivityTypes;

/// The default sharing options for the print action.
@property (nonatomic, readonly) PSPDFDocumentSharingOptions printSharingOptions;

/// The default sharing options for the open in action.
@property (nonatomic, readonly) PSPDFDocumentSharingOptions openInSharingOptions;

/// The default sharing options for the email action.
@property (nonatomic, readonly) PSPDFDocumentSharingOptions mailSharingOptions;

/// The default sharing options for the message action.
@property (nonatomic, readonly) PSPDFDocumentSharingOptions messageSharingOptions;

/// Options that will be presented by `PSPDFSettingsViewController`. 
@property (nonatomic, readonly) PSPDFSettingsOptions settingsOptions;

/// @name Advanced Properties

/// Enable/Disable all internal gesture recognizers. Defaults to YES.
/// Can be useful if you're doing custom drawing on the `PSPDFPageView`.
@property (nonatomic, readonly) BOOL internalTapGesturesEnabled;

/// Set this to true to allow this controller to access the parent `navigationBar`/`navigationController` to add custom buttons.
/// Has no effect if there's no `parentViewController`. Defaults to NO.
/// @note When using this feature, you should also implement both `childViewControllerForStatusBarHidden`
/// and `childViewControllerForStatusBarStyle` to return the `PSPDFViewController` instance that is embedded.
@property (nonatomic, readonly) BOOL useParentNavigationBar;

/// If enabled, will request that all thumbnails are pre-cached in `viewDidAppear:`. Defaults to YES.
/// Set this to NO if you are not using thumbnails to improve speed.
/// @warning Does not delete any cache and doesn't change if set after the controller has been presented.
@property (nonatomic, readonly) BOOL shouldCacheThumbnails;

/// @name Gallery Configuration

/// The configuration used for the gallery system. Defaults to `PSPDFGalleryConfiguration.defaultConfiguration`.
@property (nonatomic, readonly) PSPDFGalleryConfiguration *galleryConfiguration;

@end


/// The configuration builder object offers all properties of `PSPDFConfiguration`
/// in a writable version, in order to build an immutable `PSPDFConfiguration` object.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFConfigurationBuilder : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Use this to use specific subclasses instead of the default PSPDF* classes.
/// This works across the whole framework and allows you to subclass all usages of a class. For example add an entry of `PSPDFPageView.class` / `MyCustomPageView.class` to use the custom subclass. (`MyCustomPageView` must be a subclass of `PSPDFPageView`)
/// @throws an exception if the overriding class is not a subclass of the overridden class.
/// @note Only set from the main thread, before you first use the object.
/// Model objects will use the overrideClass entries from the set document instead.
- (void)overrideClass:(Class)builtinClass withClass:(nullable Class)subclass;

@property (nonatomic) UIEdgeInsets margin;
@property (nonatomic) UIEdgeInsets padding;
@property (nonatomic) CGFloat pagePadding;
@property (nonatomic) PSPDFPageRenderingMode renderingMode;
@property (nonatomic) PSPDFTapAction doubleTapAction;
@property (nonatomic, getter=isFormElementZoomEnabled) BOOL formElementZoomEnabled;
@property (nonatomic, getter=isScrollOnTapPageEndEnabled) BOOL scrollOnTapPageEndEnabled;
@property (nonatomic, getter=isScrollOnTapPageEndAnimationEnabled) BOOL scrollOnTapPageEndAnimationEnabled;
@property (nonatomic) CGFloat scrollOnTapPageEndMargin;
@property (nonatomic, getter=isTextSelectionEnabled) BOOL textSelectionEnabled;
@property (nonatomic, getter=isImageSelectionEnabled) BOOL imageSelectionEnabled;
@property (nonatomic) PSPDFTextSelectionMode textSelectionMode;
@property (nonatomic) BOOL textSelectionShouldSnapToWord;
@property (nonatomic) PSPDFAnnotationType typesShowingColorPresets;
@property (nonatomic, copy) NSDictionary<NSString *, id> *propertiesForAnnotations;
@property (nonatomic) BOOL freeTextAccessoryViewEnabled;
@property (nonatomic) PSPDFSortOrder bookmarkSortOrder;
@property (nonatomic) BOOL internalTapGesturesEnabled;
@property (nonatomic) BOOL useParentNavigationBar;
@property (nonatomic) BOOL shouldRestoreNavigationBarStyle;
@property (nonatomic) PSPDFLinkAction linkAction;
@property (nonatomic) PSPDFTextSelectionMenuAction allowedMenuActions;
@property (nonatomic) PSPDFHUDViewMode HUDViewMode;
@property (nonatomic) PSPDFHUDViewAnimation HUDViewAnimation;
@property (nonatomic) PSPDFThumbnailBarMode thumbnailBarMode;
@property (nonatomic, getter=isPageLabelEnabled) BOOL pageLabelEnabled;
@property (nonatomic) PSPDFAdaptiveConditional documentLabelEnabled;
@property (nonatomic) BOOL shouldHideHUDOnPageChange;
@property (nonatomic) BOOL shouldShowHUDOnViewWillAppear;
@property (nonatomic) BOOL allowToolbarTitleChange;
@property (nonatomic, getter=isRenderAnimationEnabled) BOOL renderAnimationEnabled;
@property (nonatomic) PSPDFRenderStatusViewPosition renderStatusViewPosition;
@property (nonatomic) PSPDFPageMode pageMode;
@property (nonatomic) PSPDFScrubberBarType scrubberBarType;
@property (nonatomic) PSPDFThumbnailGrouping thumbnailGrouping;
@property (nonatomic) PSPDFPageTransition pageTransition;
@property (nonatomic) PSPDFScrollDirection scrollDirection;
@property (nonatomic) PSPDFScrollInsetAdjustment scrollViewInsetAdjustment;
@property (nonatomic, getter=isDoublePageModeOnFirstPage) BOOL doublePageModeOnFirstPage;
@property (nonatomic, getter=isZoomingSmallDocumentsEnabled) BOOL zoomingSmallDocumentsEnabled;
@property (nonatomic, getter=isPageCurlDirectionLeftToRight) BOOL pageCurlDirectionLeftToRight;
@property (nonatomic, getter=isFitToWidthEnabled) BOOL fitToWidthEnabled;
@property (nonatomic) BOOL showsHorizontalScrollIndicator;
@property (nonatomic) BOOL showsVerticalScrollIndicator;
@property (nonatomic) BOOL alwaysBouncePages;
@property (nonatomic) BOOL fixedVerticalPositionForFitToWidthEnabledMode;
@property (nonatomic) BOOL clipToPageBoundaries;
@property (nonatomic) float minimumZoomScale;
@property (nonatomic) float maximumZoomScale;
@property (nonatomic, getter=isShadowEnabled) BOOL shadowEnabled;
@property (nonatomic) CGFloat shadowOpacity;
@property (nonatomic) BOOL shouldHideNavigationBarWithHUD;
@property (nonatomic) BOOL shouldHideStatusBar;
@property (nonatomic) BOOL shouldHideStatusBarWithHUD;
@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) PSPDFAppearanceMode allowedAppearanceModes;
@property (nonatomic) CGSize thumbnailSize;
@property (nonatomic) CGFloat thumbnailInteritemSpacing;
@property (nonatomic) CGFloat thumbnailLineSpacing;
@property (nonatomic) UIEdgeInsets thumbnailMargin;
@property (nonatomic) CGFloat annotationAnimationDuration;
@property (nonatomic) BOOL annotationGroupingEnabled;
@property (nonatomic, getter=isCreateAnnotationMenuEnabled) BOOL createAnnotationMenuEnabled;
@property (nonatomic, copy) NSArray<PSPDFAnnotationGroup *> *createAnnotationMenuGroups;
@property (nonatomic) BOOL naturalDrawingAnnotationEnabled;
@property (nonatomic) BOOL showAnnotationMenuAfterCreation;
@property (nonatomic) BOOL shouldAskForAnnotationUsername;
@property (nonatomic) BOOL annotationEntersEditModeAfterSecondTapEnabled;
@property (nonatomic, copy, nullable) NSSet<NSString *> *editableAnnotationTypes;
@property (nonatomic, getter=isAutosaveEnabled) BOOL autosaveEnabled;
@property (nonatomic) BOOL allowBackgroundSaving;
@property (nonatomic) NSTimeInterval soundAnnotationTimeLimit;
@property (nonatomic) BOOL shouldCacheThumbnails;
@property (nonatomic) BOOL shouldScrollToChangedPage;
@property (nonatomic) PSPDFSearchMode searchMode;
@property (nonatomic) CGFloat searchResultZoomScale;
@property (nonatomic) BOOL signatureSavingEnabled;
@property (nonatomic) BOOL customerSignatureFeatureEnabled;
@property (nonatomic) BOOL naturalSignatureDrawingEnabled;
@property (nonatomic) id <PSPDFSignatureStore> signatureStore;
@property (nonatomic) PSPDFGalleryConfiguration *galleryConfiguration;
@property (nonatomic) BOOL showBackActionButton;
@property (nonatomic) BOOL showForwardActionButton;
@property (nonatomic) BOOL showBackForwardActionButtonLabels;

@property (nonatomic, copy) NSArray *applicationActivities;
@property (nonatomic, copy) NSArray<NSString *> *excludedActivityTypes;
@property (nonatomic) PSPDFDocumentSharingOptions printSharingOptions;
@property (nonatomic) PSPDFDocumentSharingOptions openInSharingOptions;
@property (nonatomic) PSPDFDocumentSharingOptions mailSharingOptions;
@property (nonatomic) PSPDFDocumentSharingOptions messageSharingOptions;
@property (nonatomic) PSPDFSettingsOptions settingsOptions;

@end


@interface PSPDFConfiguration (Deprecated)

/// If set to YES, tries to find the text blocks on the page and zooms into the tapped block.
/// NO will perform a generic zoom into the tap area. Defaults to YES.
@property (nonatomic, getter=isSmartZoomEnabled, readonly) BOOL smartZoomEnabled PSPDF_DEPRECATED(5.3, "Use `doubleTapAction` instead.");

@end


@interface PSPDFConfigurationBuilder (Deprecated)

@property (nonatomic, getter=isSmartZoomEnabled) BOOL smartZoomEnabled PSPDF_DEPRECATED(5.3, "Use `doubleTapAction` instead.");

@end

NS_ASSUME_NONNULL_END
