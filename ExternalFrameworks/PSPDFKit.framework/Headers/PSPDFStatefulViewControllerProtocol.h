//
//  PSPDFStatefulViewControllerProtocol.h
//  PSPDFKit
//
//  Copyright © 2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PSPDFStatefulViewState) {
    /// Controller is querying data.
    PSPDFStatefulViewStateLoading,
    /// Controller finished loading, has no data.
    PSPDFStatefulViewStateEmpty,
    /// Controller has data.
    PSPDFStatefulViewStateFinished
} PSPDF_ENUM_AVAILABLE;

/// Shows a message when the controller is empty.
PSPDF_AVAILABLE_DECL @protocol PSPDFStatefulViewControllerProtocol<UIContentContainer>

/// Empty view.
@property (nonatomic, nullable) UIView *emptyView;

/// Loading view.
@property (nonatomic, nullable) UIView *loadingView;

/// Receives the current controller state.
/// @note This is KVO observable.
@property (nonatomic) PSPDFStatefulViewState controllerState;

@optional

/// Sets the controller state and shows/hides the `emptyView`/`loadingView` depending on the state.
- (void)setControllerState:(PSPDFStatefulViewState)controllerState animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
