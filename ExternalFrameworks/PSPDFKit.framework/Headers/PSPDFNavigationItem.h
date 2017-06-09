//
//  PSPDFNavigationItem.h
//  PSPDFKit
//
//  Copyright © 2016-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFConfiguration.h"
#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

/// `PSPDFNavigationItem` handles the left and right bar button items for different view modes.
///
/// This type of navigation item enables you to assign left and right bar button items based on the view mode,
/// so that every view mode can have different bar button items displayed in the navigation bar.
///
/// The navigation item and the corresponding view controller ensure that displayed bar button items are are
/// updated correctly when the view mode changes.
PSPDF_CLASS_AVAILABLE @interface PSPDFNavigationItem : UINavigationItem

/**
 The button that is used as the close button in presentation contexts.

 This property should always be set. The managing view controller takes care about
 showing or hiding this button as necessary.

 If you set this property to `nil`, you need to take care of the cases where the
 related view controller may be presented modally yourself.

 @note The close button may be included in the array returned by `leftBarButtonItems`
       depending on whether the close button is currently visible or not. You should
       not call this method but instead call `leftBarButtonItemsForViewMode:` which
       will not return this button either way.
 */
@property (nonatomic, nullable) UIBarButtonItem *closeBarButtonItem;

/// Gets the left bar button items that are assigned to passed in view mode.
///
/// @param viewMode The view mode that you are interested in.
///
/// @return The bar button items assigned to the view mode.
- (nullable NSArray<UIBarButtonItem *> *)leftBarButtonItemsForViewMode:(PSPDFViewMode)viewMode;

/// Sets the left bar button items for a specific view mode, eiter animated or not.
///
/// @note This does not change the view mode, this only associated the passed in items with the passed in view mode.
///
/// @param barButtonItems The items to associate with `viewMode`.
/// @param viewMode       The view mode to associate with `items`.
/// @param animated       `YES` if you want to animate the change. This value is only of relevance if the passed in `viewMode` is the current view mode.
- (void)setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)barButtonItems forViewMode:(PSPDFViewMode)viewMode animated:(BOOL)animated;

/// Sets the left bar button items for all view modes.
///
/// @param items    The items to associate with all view modes.
/// @param animated `YES` if you want the change for the current view mode to be animated.
- (void)setLeftBarButtonItems:(nullable NSArray<UIBarButtonItem *> *)items animated:(BOOL)animated;

/// Gets the right bar button items that are assigned to passed in view mode.
///
/// @param viewMode The view mode that you are interested in.
///
/// @return The bar button items assigned to the view mode.
- (nullable NSArray<UIBarButtonItem *> *)rightBarButtonItemsForViewMode:(PSPDFViewMode)viewMode;

/// Sets the right bar button items for a specific view mode, eiter animated or not.
///
/// @note This does not change the view mode, this only associated the passed in items with the passed in view mode.
///
/// @param barButtonItems The items to associate with `viewMode`.
/// @param viewMode       The view mode to associate with `items`.
/// @param animated       `YES` if you want to animate the change. This value is only of relevance if the passed in `viewMode` is the current view mode.
- (void)setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)barButtonItems forViewMode:(PSPDFViewMode)viewMode animated:(BOOL)animated;

/// Sets the right bar button items for all view modes.
///
/// @param items    The items to associate with all view modes.
/// @param animated `YES` if you want the change for the current view mode to be animated.
- (void)setRightBarButtonItems:(nullable NSArray<UIBarButtonItem *> *)items animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
