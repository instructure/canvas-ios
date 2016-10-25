//
//  PSPDFFlexibleToolbar.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFToolbar.h"

@protocol PSPDFSystemBar;
@class PSPDFFlexibleToolbarDragView, PSPDFFlexibleToolbar, PSPDFToolbarCollapsedButton, PSPDFMenuItem;

typedef NS_OPTIONS(NSUInteger, PSPDFFlexibleToolbarPosition) {
    PSPDFFlexibleToolbarPositionNone      = 0,
    PSPDFFlexibleToolbarPositionInTopBar  = 1 << 0,
    PSPDFFlexibleToolbarPositionLeft      = 1 << 1,
    PSPDFFlexibleToolbarPositionRight     = 1 << 2,
    PSPDFFlexibleToolbarPositionsVertical = PSPDFFlexibleToolbarPositionLeft | PSPDFFlexibleToolbarPositionRight,
    PSPDFFlexibleToolbarPositionsAll      = PSPDFFlexibleToolbarPositionInTopBar | PSPDFFlexibleToolbarPositionsVertical
} PSPDF_ENUM_AVAILABLE;

typedef NS_ENUM(NSInteger, PSPDFToolbarGroupButtonIndicatorPosition) {
    PSPDFToolbarGroupButtonIndicatorPositionNone = 0,
    PSPDFToolbarGroupButtonIndicatorPositionBottomLeft,
    PSPDFToolbarGroupButtonIndicatorPositionBottomRight
} PSPDF_ENUM_AVAILABLE;

PSPDF_EXPORT const CGFloat PSPDFFlexibleToolbarHeight;
PSPDF_EXPORT const CGFloat PSPDFFlexibleToolbarHeightCompact; // PhoneLandscape, usually
PSPDF_EXPORT const CGFloat PSPDFFlexibleToolbarTopAttachedExtensionHeight;

#define PSPDFFlexibleToolbarGroupIndicatorPositionForToolbarPosition(position) ((position == PSPDFFlexibleToolbarPositionRight) ? PSPDFToolbarGroupButtonIndicatorPositionBottomLeft : PSPDFToolbarGroupButtonIndicatorPositionBottomRight)

#define PSPDFFlexibleToolbarPositionIsHorizontal(position) ((position) == PSPDFFlexibleToolbarPositionInTopBar)
#define PSPDFFlexibleToolbarPositionIsVertical(position) ((position) == PSPDFFlexibleToolbarPositionLeft || (position) == PSPDFFlexibleToolbarPositionRight)

NS_ASSUME_NONNULL_BEGIN

PSPDF_AVAILABLE_DECL @protocol PSPDFFlexibleToolbarDelegate <NSObject>

@optional

/// The toolbar container will be displayed (called before `showToolbarAnimated:completion:` is performed).
- (void)flexibleToolbarWillShow:(PSPDFFlexibleToolbar *)toolbar;

/// The toolbar container has been displayed (called after `showToolbarAnimated:completion:` is performed).
- (void)flexibleToolbarDidShow:(PSPDFFlexibleToolbar *)toolbar;

/// The toolbar container will be hidden (called before `hideToolbarAnimated:completion:` is performed).
- (void)flexibleToolbarWillHide:(PSPDFFlexibleToolbar *)toolbar;

/// The toolbar container has ben hidden (called after `hideToolbarAnimated:completion:` is performed).
- (void)flexibleToolbarDidHide:(PSPDFFlexibleToolbar *)toolbar;

/// Called whenever the flexible toolbar changes position in response to a user drag & drop action
- (void)flexibleToolbar:(PSPDFFlexibleToolbar *)toolbar didChangePosition:(PSPDFFlexibleToolbarPosition)position;

@end

/// A custom toolbar, that can dragged around the screen and anchored to different positions.
///
/// This class holds an array of `UIButton` objects. For best results use `PSPDFToolbarButton` or one of its subclasses.
/// PSPDFFlexibleToolbar should be used in combination with a `PSPDFFlexibleToolbarContainer` instance.
/// The bar's visual appearance can be customized using UIAppearance compliant properties.
///
/// @see `PSPDFFlexibleToolbarContainer`
PSPDF_CLASS_AVAILABLE @interface PSPDFFlexibleToolbar : PSPDFToolbar

/// A list of valid toolbar positions.
/// Defaults to `PSPDFFlexibleToolbarPositionsAll`.
@property (nonatomic) PSPDFFlexibleToolbarPosition supportedToolbarPositions;

/// Current toolbar position (limited to `supportedToolbarPositions`).
@property (nonatomic) PSPDFFlexibleToolbarPosition toolbarPosition;

/// Sets the toolbar position and optionally animates the change (move or fade, depending on whether the orientation changes)
- (void)setToolbarPosition:(PSPDFFlexibleToolbarPosition)toolbarPosition animated:(BOOL)animated;

/// Toolbar delegate. (Can be freely set to any receiver)
@property (nonatomic, weak) id<PSPDFFlexibleToolbarDelegate> toolbarDelegate;

/// Enables or disables toolbar dragging (hides the `dragView` when disabled).
/// Defaults to YES.
@property (nonatomic, getter = isDragEnabled) BOOL dragEnabled;

/// The currently selected button. The selected button is indicated by a selection bezel behind the button.
/// The selected button's tint color gets automatically adjusted to `selectedTintColor` as well.
@property (nonatomic, nullable) UIButton *selectedButton;

/// Sets the selection button and optionally fades the selection view.
- (void)setSelectedButton:(nullable UIButton *)button animated:(BOOL)animated;

/// @name Presentation

/// Shows the toolbar (optionally by fading it in).
- (void)showToolbarAnimated:(BOOL)animated completion:(nullable void (^)(BOOL finished))completionBlock;

/// Hides the toolbar (optionally by fading it out).
- (void)hideToolbarAnimated:(BOOL)animated completion:(nullable void (^)(BOOL finished))completionBlock;

/// @name Styling

/// Drag indicator view, positioned on the right or bottom of the toolbar (depending on the toolbar orientation).
/// Drag & drop gesture recognizers (UIPanGestureRecognizer) should be added to this view.
/// Visible only if `dragEnabled` is set to YES.
@property (nonatomic, readonly) PSPDFFlexibleToolbarDragView *dragView;

/// The tint color for selected buttons.
/// Defaults to `barTintColor` if available, otherwise an attempt is made to select an appropriate color
/// based on the `backgroundView` appearance.
@property (nonatomic) UIColor *selectedTintColor UI_APPEARANCE_SELECTOR;

/// The selection bezel color.
/// Defaults to self.tintColor.
@property (nonatomic) UIColor *selectedBackgroundColor UI_APPEARANCE_SELECTOR;

/// Toolbar positions that draw a thin border around the toolbar.
/// Defaults to `PSPDFFlexibleToolbarPositionsAll`.
@property (nonatomic) PSPDFFlexibleToolbarPosition borderedToolbarPositions UI_APPEARANCE_SELECTOR;

/// Toolbar positions that draw a faint shadow around the toolbar.
/// Defaults to `PSPDFFlexibleToolbarPositionsVertical`.
@property (nonatomic) PSPDFFlexibleToolbarPosition shadowedToolbarPositions UI_APPEARANCE_SELECTOR;

/// Matches the toolbar appearance to the provided UINavigationBar or UIToolbar.
/// Includes `barTintColor`, `tintColor`, `barStyle` and `translucency`.
/// The `barTintColor` and `tintColor` are only matched if the haven't been already explicitly set (using properties or UIAppearance).
- (void)matchUIBarAppearance:(UIView<PSPDFSystemBar> *)navigationBarOrToolbar;

/// @name Metrics

/// Returns the toolbars native size for the provided position, bound to the `availableSize`.
/// Internally used by the container view to correctly position the toolbar and anchor views during drag & drop.
/// The toolbar height will be increased when docked underneath the status bar by `PSPDFFlexibleToolbarContainer`.
/// @see -[PSPDFFlexibleToolbarContainer rectForToolbarPosition:]
- (CGSize)preferredSizeFitting:(CGSize)availableSize forToolbarPosition:(PSPDFFlexibleToolbarPosition)position;

/// @name Menu

/// Shows a menu (UIMenuController) for a specific button.
/// @param menuItems An array of PSPDFMenuItem objects.
/// @param target The target view (most commonly on of the buttons) used to anchor the menu arrow.
/// @param animated Whether to animate the menu presentation or not.
- (void)showMenuWithItems:(NSArray<PSPDFMenuItem *> *)menuItems target:(UIView *)target animated:(BOOL)animated;

/// Called when the `collapsedButton` menu action is invoked.
/// The default implementation uses `menuItemForButton:` to convert buttons into menu items
/// and than calls through to `showMenuWithItems:target:animated:`.
- (void)showMenuForCollapsedButtons:(NSArray<__kindof UIButton *> *)buttons fromButton:(UIButton *)sourceButton animated:(BOOL)animated;

/// Converts buttons into similarly styled menu items
- (PSPDFMenuItem *)menuItemForButton:(UIButton *)button;

@end

/// Toolbar drag & drop indicator view.
PSPDF_CLASS_AVAILABLE @interface PSPDFFlexibleToolbarDragView : UIView

/// Color used for the bar indicators or as the background color in inverted mode.
/// Defaults to `tintColor` in UIKit.
@property (nonatomic) UIColor *barColor;

/// Inverts the bar and background color (can be used to indicate selection).
@property (nonatomic) BOOL inverted;

/// Inverts the bar and background color and optionally fades the transition.
- (void)setInverted:(BOOL)inverted animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
