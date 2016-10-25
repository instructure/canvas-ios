//
//  PSPDFControllerState.h
//  PSPDFKit
//
//  Copyright (c) 2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

@class PSPDFDocument;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PSPDFControllerState) {
    /// No data is set or no data could be loaded.
    PSPDFControllerStateEmpty,

    /// Controller is querying data.
    PSPDFControllerStateLoading,

    /// Data is set. This is the state we want.
    PSPDFControllerStateDefault,

    /// Data is invalid.
    PSPDFControllerStateError,

    /// The data currently is locked.
    PSPDFControllerStateLocked,
} PSPDF_ENUM_AVAILABLE;

PSPDF_AVAILABLE_DECL @protocol PSPDFControllerStateHandling <NSObject>

/// The document that this controller state is about.
@property (nonatomic, nullable) PSPDFDocument *document;

/// Updates the controller state to the passed in one.
///
/// @param state    The state to update to.
/// @param error    If the state is `PSPDFControllerStateError`, this contains the underlying error.
/// @param animated If `YES` the controller state change should be animated in the UI.
- (void)setControllerState:(PSPDFControllerState)state error:(nullable NSError *)error animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
