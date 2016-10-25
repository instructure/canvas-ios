//
//  PSPDFPresentationActions.h
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

NS_ASSUME_NONNULL_BEGIN

@class PSPDFAlertController;

typedef NS_ENUM(NSUInteger, PSPDFPresentationStyle) {
    /// Present the view controller using the style in its `modalPresentationStyle`.
    PSPDFPresentationStyleNone,

    /// Present the view controller full-width anchored to the bottom of the screen if the width is horizontally compact, and as a popover otherwise.
    PSPDFPresentationStyleHalfModal,
} PSPDF_ENUM_AVAILABLE;

/// Presentation style.
PSPDF_EXPORT NSString *const PSPDFPresentationStyleKey;                  // See `PSPDFPresentationStyle`.

/// Set to YES to prevent the presentation from adapting to a different style.
/// This may be used to show popovers in horizontally compact environments.
/// The object stored with this key is expected to be an `NSNumber` wrapping a Boolean value.
PSPDF_EXPORT NSString *const PSPDFPresentationNonAdaptiveKey;

/// Specific for popovers:

/// A block than can be queried to get the current presentation source rectangle, used for popovers and half modal presentations.
/// This is interpreted relative to the source view controller’s view.
/// The type of the block is `CGRect (^)()`: it doesn’t take any arguments and return a `CGRect`.
/// This works if the container view resizes, so is preferred over the rectangle in `PSPDFPresentationRectKey`.
PSPDF_EXPORT NSString *const PSPDFPresentationRectBlockKey;

/// A convenience for setting the presented view controller’s `preferredContentSize` just before it is presented.
PSPDF_EXPORT NSString *const PSPDFPresentationContentSizeKey;

/// Navigation Controller and close button logic.

/// Set to YES to embed the controller in a navigation controller.
/// This is automatically inferred if a close button should be added.
PSPDF_EXPORT NSString *const PSPDFPresentationInNavigationControllerKey;

PSPDF_EXPORT NSString *const PSPDFPresentationCloseButtonKey;             // Set to YES to add a close button.
PSPDF_EXPORT NSString *const PSPDFPresentationPersistentCloseButtonKey;   // See `PSPDFPersistentCloseButtonMode`

/// If this is YES and there is an existing presentation in place that also set this to YES, and both presented view controllers are navigation controllers of the same class, then the existing presentation will be reused by setting the `viewControllers` of the existing navigation controller.
PSPDF_EXPORT NSString *const PSPDFPresentationReuseNavigationControllerKey;

/// Customize default arrow directions for popover.
PSPDF_EXPORT NSString *const PSPDFPresentationPopoverArrowDirectionsKey;

/// Customize the popover click-through views.
/// This is required as changing `passthroughViews` after the controller has been presented has no effect.
PSPDF_EXPORT NSString *const PSPDFPresentationPopoverPassthroughViewsKey;

/// Customize the popover backdrop view background color (includes the arrow color).
PSPDF_EXPORT NSString *const PSPDFPresentationPopoverBackgroundColorKey;

/// The presentation source rectangle, used for popovers and half modal presentations.
/// This is interpreted relative to the source view controller’s view.
/// `PSPDFPresentationRectBlockKey` is preferred.
PSPDF_EXPORT NSString *const PSPDFPresentationRectKey;

/// Methods to present/dismiss view controllers.
/// UIViewController doesn't expose enough to conveniently present/dismiss controllers, so this protocol extends it.
PSPDF_AVAILABLE_DECL @protocol PSPDFPresentationActions <NSObject>

/// Presents a view controller using the specified options.
/// @note If the presentation is blocked (e.g. return NO on the shouldShow delegate), the completion block will not be called.
/// @warning The presented view controller’s `presentationController` and `popoverPresentationController` should not be accessed before calling this method, because the presentation style or transitioning delegate may change.
/// If you need to configure the popover presentation, set values in the options with keys `PSPDFPresentationRectBlockKey`, `PSPDFPresentationPopoverArrowDirectionsKey`, and `PSPDFPresentationPopoverPassthroughViewsKey`.
- (BOOL)presentViewController:(UIViewController *)viewController options:(nullable NSDictionary<NSString *, id> *)options animated:(BOOL)animated sender:(nullable id)sender completion:(nullable void (^)(void))completion;

/// Dismisses a view controller of class `controllerClass`.
/// If `controllerClass` is nil, this is the same as `dismissViewControllerAnimated:completion:`.
- (BOOL)dismissViewControllerOfClass:(nullable Class)controllerClass animated:(BOOL)animated completion:(nullable void (^)(void))completion;

@end


NS_ASSUME_NONNULL_END
