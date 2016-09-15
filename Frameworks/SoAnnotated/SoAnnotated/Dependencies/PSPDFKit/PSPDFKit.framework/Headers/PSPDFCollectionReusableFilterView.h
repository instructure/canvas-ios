//
//  PSPDFCollectionReusableFilterView.h
//  PSPDFKit
//
//  Copyright (c) 2015-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h" 

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PSPDFCollectionReusableFilterViewStyle) {
    /// Standard view.
    PSPDFCollectionReusableFilterViewStyleNone,
     /// Use a blur effect that composes well with light colors, like plain UIKit bars.
    PSPDFCollectionReusableFilterViewStyleLightBlur,
     /// Use a blur effect that is suitable for composes well with dark colors, like in the demo app.
    PSPDFCollectionReusableFilterViewStyleDarkBlur,
     /// Use a blur effect that’s tinted even lighter than the lightBlur style.
    PSPDFCollectionReusableFilterViewStyleExtraLightBlur,
} PSPDF_ENUM_AVAILABLE;

/// The priority with which the filterElement is centered inside the filter view.
static const UILayoutPriority PSPDFCollectionReusableFilterViewCenterPriority = UILayoutPriorityDefaultHigh - 10;
/// The default minimum margin of the filterElement
static const CGFloat PSPDFCollectionReusableFilterViewDefaultMargin = 8;

/// A view that is suitable to display a (sticky) filtering interface for a collection view.
PSPDF_CLASS_AVAILABLE @interface PSPDFCollectionReusableFilterView : UICollectionReusableView

/// The active UI element. Setting this property to a new value inserts it to the view hierarchy and takes care of positioning it neatly.
@property (nullable, nonatomic) UISegmentedControl *filterElement;

/// The offset of the filter element from being centered.
@property (nonatomic) CGPoint filterElementOffset UI_APPEARANCE_SELECTOR;

/// The minimum amount of space between the filterElement’s alignment rectangle and bounds of the receiver — defaults to `PSPDFCollectionReusableFilterViewDefaultMargin` on all edges.
/// @note The priority of this minimum margin is `UILayoutPriorityRequired`.
/// Therefore, if you want the alignment rect of the filterElement to extend beyonds the bounds of this view, you have to set a negative value for that edge.
@property (nonatomic) UIEdgeInsets minimumFilterMargin UI_APPEARANCE_SELECTOR;

/// The background style of this view.
@property (nonatomic) PSPDFCollectionReusableFilterViewStyle backgroundStyle UI_APPEARANCE_SELECTOR;

@end

NS_ASSUME_NONNULL_END
