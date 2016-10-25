//
//  PSPDFBlurView.h
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

/// `PSPDFBlurView` allows you to get a blurred background.
PSPDF_CLASS_AVAILABLE @interface PSPDFBlurView : UIView

/// Controls if blurring is enabled. Defaults to `NO`.
/// @warning You cannot set the `backgroundColor` property if `blurEnabled` is set to `YES`!
@property (nonatomic, getter = isBlurEnabled) BOOL blurEnabled;

/// Everything from the `renderView` up the view hierarchy to this view is used to render the
/// background. Defaults to the view's `superview`.
@property (nonatomic, weak) UIView *renderView;

/// The `containerView` is hidden before rendering the background. This is useful because
/// you usually only want to blur the views below a given view. Defaults to the view itself.
@property (nonatomic, weak) UIView *containerView;

/// Wrapper for the `blurEnabled` property since UIAppearance can only handle object values.
@property (nonatomic, nullable) NSNumber *blurEnabledObject UI_APPEARANCE_SELECTOR;

@end

NS_ASSUME_NONNULL_END
