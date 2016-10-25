//
//  PSPDFStatefulTableViewController.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFBaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PSPDFStatefulTableViewState) {
    /// Controller is querying data.
    PSPDFStatefulTableViewStateLoading,
    /// Controller finished loading, has no data.
    PSPDFStatefulTableViewStateEmpty,
    /// Controller has data.
    PSPDFStatefulTableViewStateFinished
} PSPDF_ENUM_AVAILABLE;

/// Shows a message when the controller is empty.
PSPDF_CLASS_AVAILABLE @interface PSPDFStatefulTableViewController : PSPDFBaseTableViewController

/// Empty view.
@property (nonatomic, nullable) UIView *emptyView;

/// Loading view.
@property (nonatomic, nullable) UIView *loadingView;

/// Receives the current controller state.
/// @note This is KVO observable.
@property (nonatomic) PSPDFStatefulTableViewState controllerState;

/// Sets the controller state and shows/hides the `emptyView`/`loadingView` depending on the state.
- (void)setControllerState:(PSPDFStatefulTableViewState)controllerState animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
