//
//  PSPDFFlexibleToolbarController.h
//  PSPDFKit
//
//  Copyright (c) 2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import "PSPDFMacros.h"
#import "PSPDFFlexibleToolbarContainer.h"

@class PSPDFFlexibleToolbar;

NS_ASSUME_NONNULL_BEGIN

PSPDF_CLASS_AVAILABLE @interface PSPDFFlexibleToolbarController : NSObject <PSPDFFlexibleToolbarContainerDelegate>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Initialize with toolbar. Required.
- (instancetype)initWithToolbar:(PSPDFFlexibleToolbar *)toolbar NS_DESIGNATED_INITIALIZER;

/// Displayed toolbar.
@property (nonatomic, readonly) PSPDFFlexibleToolbar *toolbar;

/// The flexible toolbar container. Set to `nil` when the toolbar is not visible.
@property (nonatomic, readonly, nullable) PSPDFFlexibleToolbarContainer *flexibleToolbarContainer;

/// Returns YES whenever the toolbar is visible. If the toolbar is currently animating out, this will be already set to NO.
@property (nonatomic, getter=isToolbarVisible, readonly) BOOL toolbarVisible;

/// Shows or hides the toolbar (animated).
- (void)toggleToolbarAnimated:(BOOL)animated;

/// Show the toolbar, if not currently visible.
/// @return Whether the toolbar was actually shown.
/// @note Configure the `hostView` before first showing the toolbar.
- (BOOL)showToolbarAnimated:(BOOL)animated;

/// Hide the toolbar, if currently shown.
/// @return Whether the toolbar was actually hidden.
- (BOOL)hideToolbarAnimated:(BOOL)animated;

/// Configures the `hostView`, `hostToolbar` and `hostViewController` for your setup.
/// @property hostView Can be nil unless it's an unusual setup. When `nil`, `viewController` or `container` are used to determine an appropriate host view.
/// @property container Might be a `UIBarButtonItem` or a `UIView` class that sits on the `hostToolbar`. If `nil`, the parent bar will be inferred from the `viewController`.
/// @property viewController A hook will be installed, if non-nil, to auto-hide the toolbar as the controller disappears.
- (void)updateHostView:(nullable UIView *)hostView container:(nullable id)container viewController:(nullable UIViewController *)viewController;

/// The host view for the `PSPDFFlexibleToolbarContainer`.
/// @see `updateHostView:container:viewController:`
@property (nonatomic, readonly, nullable) UIView *hostView;

/// The UIToolbar / UINavigationBar that is used to anchor the toolbar.
/// @see `updateHostView:container:viewController:`
@property (nonatomic, readonly, nullable) UIView<PSPDFSystemBar> *hostToolbar;

/// The view controller that is presenting the toolbar.
/// @see `updateHostView:container:viewController:`
@property (nonatomic, weak, readonly) UIViewController *hostViewController;

@end

NS_ASSUME_NONNULL_END
