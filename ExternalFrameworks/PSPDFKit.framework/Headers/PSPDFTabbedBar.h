//
//  PSPDFTabbedBar.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PSPDFTabbedBarStyle) {
    PSPDFTabbedBarStyleLight,
    PSPDFTabbedBarStyleDark,
} PSPDF_ENUM_AVAILABLE;

/// Show the overflow button only when the number of tabs and minimum tab width result in the tabbed bar scrolling.
static const NSInteger PSPDFTabbedBarOverflowThresholdAutomatic = -1;
/// Never show the overflow button.
static const NSInteger PSPDFTabbedBarOverflowThresholdNever = NSIntegerMax;

/// A bar that shows tabs for switching between documents, used by `PSPDFTabbedViewController`.
PSPDF_CLASS_AVAILABLE @interface PSPDFTabbedBar : UIView

/// The height of the tabbed bar in points.
/// The default is 33 points.
/// If the height is less than 44 points, the hit area used for passing touch events to the tabbed bar extends below the visible bar to keep the hit target 44 points high.
@property (nonatomic) CGFloat barHeight;

/// The visual style of the tabbed bar. The default is `PSPDFTabbedBarStyleLight`.
@property (nonatomic) PSPDFTabbedBarStyle tabbedBarStyle UI_APPEARANCE_SELECTOR;

/// The minimum tab width in points. The tab bar will allow horizontal scrolling rather than making tabs narrower than this width.
/// The default is 100 points.
@property (nonatomic) CGFloat minTabWidth;

/// The font used for each tab’s title label.
/// The default is the bold system font in a size that scales with the iOS Text Size setting; the default may be restored by setting this property to `nil`.
@property (nonatomic, null_resettable) UIFont *tabTitleFont;

/// The image used for the button shown on the selected tab that closes that tab.
/// The image is aligned with the left end of the tab.
/// To hide the close button, set `allowsClosingDocuments` to `NO` on the parent `PSPDFTabbedViewController`.
/// The default is a cross in a circle that scales with `barHeight`; the default may be restored by setting this property to `nil`.
@property (nonatomic, null_resettable) UIImage *closeButtonImage;

/// The view that provides the bar background appearance.
/// The view in this property is positioned underneath all other tabbed bar content and is sized automatically to fill the bar.
/// The default is a view that blurs the content behind the tabbed bar; the default may be restored by setting this property to `nil`.
@property (nonatomic, null_resettable) UIView *backgroundView;

/// A button shown in the tabbed bar that may be tapped to show a picker to open new documents.
/// This button will be hidden if the owning `PSPDFTabbedViewController` does not have a `documentPickerController`.
@property (nonatomic, readonly) UIButton *documentPickerButton;

/// A button shown in the tabbed bar that may be tapped to show an overview of all loaded documents.
@property (nonatomic, readonly) UIButton *overviewButton;

/// The minimum number of tabs for which to show `overviewButton`.
/// The default is `PSPDFTabbedBarOverflowThresholdAutomatic`.
@property (nonatomic) NSInteger overviewThreshold;

/// An array of views placed at the left end of the tabbed bar.
/// The views are ordered left-to-right, with the first view in the array on the far left.
/// The default is an array containing only `documentPickerButton`.
@property (nonatomic, copy) NSArray<UIView *> *leftViews;

/// An array of views placed at the right end of the tabbed bar.
/// The views are ordered right-to-left, with the first view in the array on the far right.
/// The default is an array containing only `overviewButton`.
@property (nonatomic, copy) NSArray<UIView *> *rightViews;

/// The gesture recognizer used to allow the user to change the order of tabs by dragging.
/// @note This feature is not available on iOS 8, in which case the value of this property is `nil`.
@property (nonatomic, nullable, readonly) UILongPressGestureRecognizer *interactiveReorderingGestureRecognizer;

@end

NS_ASSUME_NONNULL_END
