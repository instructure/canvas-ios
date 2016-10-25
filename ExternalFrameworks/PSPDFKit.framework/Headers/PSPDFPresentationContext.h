//
//  PSPDFPresentationContext.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"
#import "PSPDFOverridable.h"
#import "PSPDFConfiguration.h"
#import "PSPDFControlDelegate.h"
#import "PSPDFVisiblePagesDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFKit, PSPDFConfiguration, PSPDFPageView, PSPDFDocument, PSPDFViewController, PSPDFAnnotationStateManager, PSPDFAnnotation, PSPDFAnnotationToolbarController;

/// The presentation context (usually defined by `PSPDFViewController`).
PSPDF_AVAILABLE_DECL @protocol PSPDFPresentationContext <PSPDFOverridable, PSPDFVisiblePagesDataSource, PSPDFErrorHandler>

/// Accesses the configuration object.
@property (nonatomic, copy, readonly) PSPDFConfiguration *configuration;

/// Access the PSPDFKit singleton store.
@property (nonatomic, readonly) PSPDFKit *pspdfkit;

/// The displaying view controller and popover/half modal controllers.
@property (nonatomic, readonly) UIViewController *displayingViewController;

/// General state.
@property (nonatomic, readonly, nullable) PSPDFDocument *document;
@property (nonatomic, readonly) PSPDFViewMode viewMode;

@property (nonatomic, readonly) CGRect contentRect;
@property (nonatomic, readonly) UIEdgeInsets scrollViewInsets;
@property (nonatomic, readonly) UIEdgeInsets scrollIndicatorInsets;
@property (nonatomic, readonly) BOOL shouldAdjustFrameWhenHUDIsPersistent;

/// Various state.
@property (nonatomic, getter = isDoublePageMode, readonly) BOOL doublePageMode;
@property (nonatomic, getter = isScrollingEnabled, readonly) BOOL scrollingEnabled;
@property (nonatomic, getter = isViewLockEnabled, readonly) BOOL viewLockEnabled;
@property (nonatomic, getter = isRotationActive, readonly) BOOL rotationActive;
@property (nonatomic, getter = isHUDVisible, readonly) BOOL HUDVisible;
@property (nonatomic, getter = isViewWillAppearing, readonly) BOOL viewWillAppearing;
@property (nonatomic, getter = isReloading, readonly) BOOL reloading;

/// Page views
@property (nonatomic, readonly) NSArray<PSPDFPageView *> *visiblePageViews;
- (NSArray<PSPDFPageView *> *)visiblePageViewsForcingLayout:(BOOL)forcingLayout;
- (nullable PSPDFPageView *)pageViewForPage:(NSUInteger)page;

/// Page numbers
- (BOOL)isRightPageInDoublePageMode:(NSUInteger)page;
- (BOOL)isDoublePageModeForViewSize:(CGSize)viewSize;
- (BOOL)isDoublePageModeForPage:(NSUInteger)page;
- (NSUInteger)portraitPageForLandscapePage:(NSUInteger)page;
- (NSUInteger)landscapePageForPage:(NSUInteger)aPage;

@property (nonatomic, readonly, nullable) UIScrollView *pagingScrollView;

/// Accesses the global annotation state manager.
@property (nonatomic, readonly) PSPDFAnnotationStateManager *annotationStateManager;

@property (nonatomic, readonly) PSPDFAnnotationToolbarController *annotationToolbarController;

// TODO: Should be a delegate instead.
@property (nonatomic, readonly) id <PSPDFControlDelegate> actionDelegate;

/// Direct access to the `PSPDFViewController` if required.
@property (nonatomic, readonly) PSPDFViewController *pdfController;

@end

NS_ASSUME_NONNULL_END
