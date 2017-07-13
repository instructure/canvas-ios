//
//  PSPDFPresentationContext.h
//  PSPDFKit
//
//  Copyright © 2014-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFConfiguration.h"
#import "PSPDFControlDelegate.h"
#import "PSPDFEnvironment.h"
#import "PSPDFOverridable.h"
#import "PSPDFVisiblePagesDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFKit, PSPDFConfiguration, PSPDFPageView, PSPDFDocument, PSPDFViewController, PSPDFAnnotationStateManager, PSPDFAnnotation, PSPDFAnnotationToolbarController;

/**
 The presentation context is used to provide several parts of the framework with
 information about what is currently presented in the corresponding `PSPDFViewController`.

 @note You should never implement `PSPDFPresentationContext` yourself, instead it
       is created by the framework and handed to you in several places when needed.
 */
PSPDF_AVAILABLE_DECL @protocol PSPDFPresentationContext<PSPDFOverridable, PSPDFVisiblePagesDataSource, PSPDFErrorHandler>

/// Accesses the configuration object.
@property (nonatomic, copy, readonly) PSPDFConfiguration *configuration;

/// Access the PSPDFKit singleton store.
@property (nonatomic, readonly) PSPDFKit *pspdfkit;

/// The displaying view controller and popover/half modal controllers.
@property (nonatomic, readonly) UIViewController *displayingViewController;

/// @name General State

/// The associated document.
@property (nonatomic, readonly, nullable) PSPDFDocument *document;

/// Current view mode;
@property (nonatomic, readonly) PSPDFViewMode viewMode;

/// Frame for the visible content, without navigation bar, status bar, side bar.
@property (nonatomic, readonly) CGRect contentRect;

/// Inset for the scroll view.
@property (nonatomic, readonly) UIEdgeInsets scrollViewInsets;

/// Inset for the scroll indicators.
@property (nonatomic, readonly) UIEdgeInsets scrollIndicatorInsets;

/// Defines if the frame shoulb be adjus
@property (nonatomic, readonly) BOOL shouldAdjustFrameWhenHUDIsPersistent;

/// @name varying State

/// Defines if we are currently in double page mode.
@property (nonatomic, getter=isDoublePageMode, readonly) BOOL doublePageMode;

/// Defines if scrolling is enabled.
@property (nonatomic, getter=isScrollingEnabled, readonly) BOOL scrollingEnabled;

/// Defines if the view is locked, therefore disabling all scrolling and zooming.
@property (nonatomic, getter=isViewLockEnabled, readonly) BOOL viewLockEnabled;

/// Defines if a rotation is currently happening.
@property (nonatomic, getter=isRotationActive, readonly) BOOL rotationActive;

/// Defines if the HUD is visible.
@property (nonatomic, getter=isHUDVisible, readonly) BOOL HUDVisible;

/// Defines if `viewWillAppear` is currently being called.
@property (nonatomic, getter=isViewWillAppearing, readonly) BOOL viewWillAppearing;

/// Defines if the view is currently reloading.
@property (nonatomic, getter=isReloading, readonly) BOOL reloading;

/// Defines if the view is loaded.
@property (nonatomic, getter=isViewLoaded, readonly) BOOL viewLoaded;

/// @name Page Views

/// Currently visible page views.
@property (nonatomic, readonly) NSArray<PSPDFPageView *> *visiblePageViews;

/// Returns the currently visible page views, while optionally laying them out.
- (NSArray<PSPDFPageView *> *)visiblePageViewsForcingLayout:(BOOL)forcingLayout;

/// Returns the page view for the given page index. Will return `nil` if the page view is not loaded.
- (nullable PSPDFPageView *)pageViewForPageAtIndex:(NSUInteger)pageIndex;

/// @name Page Numbers

/// Defines if the trailing page is in double page mode.
- (BOOL)isTrailingPageInDoublePageMode:(NSUInteger)pageIndex;
- (BOOL)isRightPageInDoublePageMode:(NSUInteger)pageIndex PSPDF_DEPRECATED_IOS(6.5.1, "This is no longer accurate with the introduction of RTL support.");

// Defines if pages should be shown in double page mode depending on the `viewSize`.
- (BOOL)isDoublePageModeForViewSize:(CGSize)viewSize;

/// Defines if the page at `pageIndex` is in double page mode.
- (BOOL)isDoublePageModeForPageAtIndex:(NSUInteger)pageIndex;

/// Returns the portait page spread for a given landscape page spread.
- (NSUInteger)portraitPageSpreadForLandscapePageSpread:(NSUInteger)pageSpread;
- (NSUInteger)portraitPageIndexForLandscapePageIndex:(NSUInteger)pageIndex PSPDF_DEPRECATED_IOS(6.5, "This has been renamed to portraitPageSpreadForLandscapePageSpread");

/// Returns the landscape page spread for a given portait page spread.
- (NSUInteger)landscapePageSpreadForPortraitPageSpread:(NSUInteger)pageSpread;
- (NSUInteger)landscapePageIndexForPortraitPageIndex:(NSUInteger)pageIndex PSPDF_DEPRECATED_IOS(6.5, "This has been renamed to landscapePageSpreadForPortraitPageSpread");

/// Scroll view used for scrolling through pages.
@property (nonatomic, readonly, nullable) UIScrollView *pagingScrollView;

/// Accesses the global annotation state manager.
@property (nonatomic, readonly) PSPDFAnnotationStateManager *annotationStateManager;

/// Annotation toolbar controller used for handling the annotation toolbar.
@property (nonatomic, readonly) PSPDFAnnotationToolbarController *annotationToolbarController;

/// Delegate for control handling.
@property (nonatomic, readonly) id<PSPDFControlDelegate> actionDelegate;

/// Direct access to the `PSPDFViewController` if required.
@property (nonatomic, readonly) PSPDFViewController *pdfController;

@end

NS_ASSUME_NONNULL_END
