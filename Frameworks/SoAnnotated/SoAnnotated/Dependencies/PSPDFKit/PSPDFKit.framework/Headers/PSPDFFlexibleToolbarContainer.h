//
//  PSPDFFlexibleToolbarContainer.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFFlexibleToolbar.h"

@class PSPDFFlexibleToolbar, PSPDFFlexibleToolbarContainer;

NS_ASSUME_NONNULL_BEGIN

PSPDF_AVAILABLE_DECL @protocol PSPDFFlexibleToolbarContainerDelegate <NSObject>

@optional

/// The toolbar container will be displayed (called before `showAnimated:completion:` is performed).
- (void)flexibleToolbarContainerWillShow:(PSPDFFlexibleToolbarContainer *)container;

/// The toolbar container has been displayed (called after `showAnimated:completion:` is performed).
- (void)flexibleToolbarContainerDidShow:(PSPDFFlexibleToolbarContainer *)container;

/// The toolbar container will be hidden (called before `hideAnimated:completion:` is performed).
/// Will also be called in response to a flick to close gesture.
- (void)flexibleToolbarContainerWillHide:(PSPDFFlexibleToolbarContainer *)container;

/// The toolbar container has ben hidden (called after `hideAnimated:completion:` is performed).
/// Will also be called in response to a flick to close gesture.
/// Use this callback to perform any additional cleanup on the toolbar presenter side.
- (void)flexibleToolbarContainerDidHide:(PSPDFFlexibleToolbarContainer *)container;

/// Use this method to prove a more appropriate display area for the toolbar.
/// @note The provided `CGRect` should be in the containers coordinate system.
/// Used during toolbar and anchor placeholder positioning. Defaults to self.bounds` if not implemented.
- (CGRect)flexibleToolbarContainerContentRect:(PSPDFFlexibleToolbarContainer *)container forToolbarPosition:(PSPDFFlexibleToolbarPosition)position;

/// The toolbar is dragged and might change position.
- (void)flexibleToolbarContainerWillStartDragging:(PSPDFFlexibleToolbarContainer *)container;

/// The toolbar has been dragged and might have updated the position.
- (void)flexibleToolbarContainerDidEndDragging:(PSPDFFlexibleToolbarContainer *)container withPosition:(PSPDFFlexibleToolbarPosition)position;

@end

/// Designates common `UIToolbar` or `UINavigationBar` functionality.
PSPDF_AVAILABLE_DECL @protocol PSPDFSystemBar <NSObject> @end
@interface UIToolbar (PSPDFSystemBar) <PSPDFSystemBar> @end
@interface UINavigationBar (PSPDFSystemBar) <PSPDFSystemBar> @end

// Searches the responder chain for the closest system bar (toolbar/navigation bar).
PSPDF_EXPORT UIView<PSPDFSystemBar> *_Nullable PSPDFSystemBarForResponder(UIResponder *responder);

/// The flexible toolbar container holds and manages a `PSPDFFlexibleToolbar` instance.
/// Its main responsibilities include toolbar anchoring and drag & drop handling.
/// Add this view to your view hierarchy (a good candidate might be the UINavigationController's view).
/// @see `PSPDFFlexibleToolbar`
PSPDF_CLASS_AVAILABLE @interface PSPDFFlexibleToolbarContainer : UIView

/// Attached flexible toolbar.
@property (nonatomic, nullable) PSPDFFlexibleToolbar *flexibleToolbar;

/// A `UINavigationBar` or `UIToolbar` instance, that should be automatically hidden
/// when the `flexibleToolbar` is in the `PSPDFFlexibleToolbarPositionInTopBar` position.
@property (nonatomic, weak) UIView<PSPDFSystemBar> *overlaidBar;

/// `YES` when a toolbar drag is in progress, `NO` otherwise.
/// Only relevant if  dragging is enabled on the flexibleToolbar`.
/// KVO observable.
@property (nonatomic, readonly) BOOL dragging;

/// When enabled, it allows the toolbar to be dismissed by flicking it downwards during a drag & drop operation.
@property (nonatomic, getter = isFlickToCloseEnabled) BOOL flickToCloseEnabled;

/// Container delegate. (Can be freely set to any receiver)
@property (nonatomic, weak) IBOutlet id<PSPDFFlexibleToolbarContainerDelegate> containerDelegate;

/// @name Appearance

/// The background color used for anchor view.
/// If not explicitly set the color defaults to the toolbar barTintColor,
/// toolbar tintColor or default PSPDFKit color (first one that is set).
@property (nonatomic) UIColor *anchorViewBackgroundColor UI_APPEARANCE_SELECTOR;

/// @name Presentation

/// Shows the container, than calls through to the corresponding `PSPDFFlexibleToolbar`
/// method (`showToolbarAnimated:completion:`).
/// Also hide the overlaidBar if needed (depending on the toolbar position).
- (void)showAnimated:(BOOL)animated completion:(nullable void (^)(BOOL finished))completionBlock;

/// Calls through to the corresponding `PSPDFFlexibleToolbar` method (`hideToolbarAnimated:completion:`)
// and hides the container.
/// Also shows the overlaidBar if it was previously hidden by the toolbar container.
- (void)hideAnimated:(BOOL)animated completion:(nullable void (^)(BOOL finished))completionBlock;

/// Hides the container and toolbar using hideAnimated:completion: and than removes the container from its superview.
/// Internally used by the flick to close gesture. Should also be used by done / close buttons added to the toolbar.
- (void)hideAndRemoveAnimated:(BOOL)animated completion:(nullable void (^)(BOOL finished))completionBlock;

@end

@interface PSPDFFlexibleToolbarContainer (SubclassingHooks)

/// Override this method to customize exact toolbar and anchor view placement.
- (CGRect)rectForToolbarPosition:(PSPDFFlexibleToolbarPosition)toolbarPosition;

/// Possible override point for custom toolbar position change animations.
/// Use [self layoutIfNeeded]; in an animation block to apply the new toolbar position.
- (void)animateToolbarPositionChangeFrom:(PSPDFFlexibleToolbarPosition)currentPosition to:(PSPDFFlexibleToolbarPosition)newPosition;

@end

NS_ASSUME_NONNULL_END
