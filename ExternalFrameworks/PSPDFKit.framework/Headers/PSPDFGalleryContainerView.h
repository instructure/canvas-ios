//
//  PSPDFGalleryContainerView.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFBlurView.h"
#import "PSPDFOverridable.h"
#import "PSPDFGalleryContentViewProtocols.h"
#import "PSPDFMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// `PSPDFGalleryContainerViewContentState` controls which content view will be visible.
typedef NS_ENUM(NSUInteger, PSPDFGalleryContainerViewContentState) {
    /// The content is currently loading.
    PSPDFGalleryContainerViewContentStateLoading,

    /// The content is ready and presentable.
    PSPDFGalleryContainerViewContentStateReady,

    /// An error occurred.
    PSPDFGalleryContainerViewContentStateError
} PSPDF_ENUM_AVAILABLE;

/// `PSPDFGalleryContainerViewPresentationMode` controls which background view will be visible.
typedef NS_ENUM(NSUInteger, PSPDFGalleryContainerViewPresentationMode) {
    /// The embedded presentation mode.
    PSPDFGalleryContainerViewPresentationModeEmbedded,

    /// The fullscreen presentation mode.
    PSPDFGalleryContainerViewPresentationModeFullscreen
} PSPDF_ENUM_AVAILABLE;

@class PSPDFGalleryView, PSPDFCircularProgressView, PSPDFStatusHUDView;

// The following dummy classes are created to allow specific UIAppearance targeting.
// They do not have any functionality besides that.
PSPDF_CLASS_AVAILABLE @interface PSPDFGalleryEmbeddedBackgroundView : PSPDFBlurView @end
PSPDF_CLASS_AVAILABLE @interface PSPDFGalleryFullscreenBackgroundView : PSPDFBlurView @end

/// Used to group the error, loading and gallery view and to properly lay them out.
PSPDF_CLASS_AVAILABLE @interface PSPDFGalleryContainerView : UIView

/// Convenience initializer.
/// Initializes the `PSPDFGalleryContainerView` with a `frame` and an `overrideDelegate`.
/// The `overrideDelegate` is used to allow customization using the `PSPDFOverridable` protocol.
- (instancetype)initWithFrame:(CGRect)frame overrideDelegate:(nullable id<PSPDFOverridable>)overrideDelegate;

/// The override delegate, if set.
@property (nonatomic, weak, readonly) id<PSPDFOverridable> overrideDelegate;

/// @name State

/// The content state.
@property (nonatomic) PSPDFGalleryContainerViewContentState contentState;

/// The presentation mode.
@property (nonatomic) PSPDFGalleryContainerViewPresentationMode presentationMode;

/// @name Subviews

/// The gallery view.
@property (nonatomic) PSPDFGalleryView *galleryView;

/// The loading view.
@property (nonatomic) UIView <PSPDFGalleryContentViewLoading> *loadingView;

/// The background view.
@property (nonatomic) PSPDFGalleryEmbeddedBackgroundView *backgroundView;

/// The fullscreen background view.
@property (nonatomic) PSPDFGalleryFullscreenBackgroundView *fullscreenBackgroundView;

/// The status HUD view.
@property (nonatomic) PSPDFStatusHUDView *statusHUDView;

/// This view conveniently groups together the `galleryView`, `loadingView` and `statusHUDView`.
@property (nonatomic, readonly) UIView *contentContainerView;

/// @name HUD Presentation

/// Presents the HUD. After the given `timeout`, it will automatically be dismissed.
/// @note You can use a negative `timeout` to present the HUD indefinitely.
- (void)presentStatusHUDWithTimeout:(NSTimeInterval)timeout animated:(BOOL)animated;

/// Dismisses the HUD.
- (void)dismissStatusHUDAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
