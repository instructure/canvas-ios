//
//  PSPDFAvoidingScrollView.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFAvoidingScrollView;

/// Custom sub-protocol of `UIScrollViewDelegate` with additional optional callbacks.
PSPDF_AVAILABLE_DECL @protocol PSPDFAvoidingScrollViewDelegate <UIScrollViewDelegate>

@optional

/// Allows to fine-tune when the keyboard should be avoided.
/// If this method is not implemented, we assume YES.
- (BOOL)scrollViewShouldAvoidKeyboard:(PSPDFAvoidingScrollView *)scrollView;

@end

/// ScrollView subclass that listens to keyboard and half modal events and moves itself up accordingly.
/// @note `delegate also queries methods listed in `PSPDFAvoidingScrollViewDelegate`.
PSPDF_CLASS_AVAILABLE @interface PSPDFAvoidingScrollView : UIScrollView

/// YES if currently avoiding the keyboard or half modal.
@property (nonatomic, readonly, getter=isAvoidingKeyboard) BOOL avoidingKeyboard;

/// YES if a half modal view controller is currently visible.
@property (nonatomic, readonly) BOOL isHalfModalVisible;

/// Return YES if we have a first responder inside the `scrollView` that is a text input.
@property (nonatomic, readonly) BOOL firstResponderIsTextInput;

/// Enable/Disable avoidance features. Defaults to YES.
/// @warning Don't change this while `isAvoiding` is YES.
@property (nonatomic) BOOL enableAvoidance;

@end

NS_ASSUME_NONNULL_END
