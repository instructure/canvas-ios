//
//  PSPDFEditingChange.h
//  PSPDFKit
//
//  Copyright (c) 2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import "PSPDFMacros.h"
#import "PSPDFModel.h"

typedef NS_ENUM(NSUInteger, PSPDFEditingOperation) {
    /// One page was removed. `affectedPageIndex` specifies which index.
    PSPDFEditingOperationRemove,
    /// The page at `affectedPageIndex` was moved to `pageIndexDestination`.
    PSPDFEditingOperationMove,
    /// One page was inserted at `affectedPageIndex`.
    PSPDFEditingOperationInsert,
    /// The page at `affectedPageIndex` was rotated.
    PSPDFEditingOperationRotate
} PSPDF_ENUM_AVAILABLE;

NS_ASSUME_NONNULL_BEGIN

/// Represents a change that was performed by `PSPDFDocumentEditor`.
/// @see PSPDFDocumentEditor
PSPDF_CLASS_AVAILABLE @interface PSPDFEditingChange : PSPDFModel

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Initializes the editing change and sets all data values.
- (instancetype)initWithOperation:(PSPDFEditingOperation)operation affectedPageIndex:(NSUInteger)affectedPageIndex destinationPageIndex:(NSUInteger)destinationPageIndex NS_DESIGNATED_INITIALIZER;

/// The operation type.
@property (nonatomic, readonly) PSPDFEditingOperation operation;

/// Which page index was affected.
@property (nonatomic, readonly) NSUInteger affectedPageIndex;

/// The destination page index, if a move was performed.
@property (nonatomic, readonly) NSUInteger destinationPageIndex;

@end

NS_ASSUME_NONNULL_END
