//
//  PSPDFBookmark.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFModel.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFAction;

/// The sort order is currently used for bookmarks.
typedef NS_ENUM(NSUInteger, PSPDFSortOrder) {
    /// Custom sort order, based on creation, but reorderable.
    PSPDFSortOrderCustom,

    /// Sort based on pages.
    PSPDFSortOrderPageBased
} PSPDF_ENUM_AVAILABLE;

/// A bookmark is a encapsulates a PDF action and a name.
/// @warning: Bookmarks don't have any representation in the PDF standard, thus they are saved in an external file.
PSPDF_CLASS_AVAILABLE @interface PSPDFBookmark : PSPDFModel

/// Initialize with page. Convenience initialization that will create a `PSPDFGoToAction`.
- (instancetype)initWithPage:(NSUInteger)page;

/// Initialize with an action object.
- (instancetype)initWithAction:(nullable PSPDFAction *)action;

/// The PDF action. Usually this will be of type `PSPDFGoToAction`, but all action types are possible.
@property (nonatomic, readonly, nullable) PSPDFAction *action;

/// Convenience shortcut for self.action.pageIndex (if action is of type `PSPDFGoToAction`)
/// Page is set to `NSNotFound` if action is nil or a different type.
@property (nonatomic, readonly) NSUInteger page;

/// A bookmark can have a name. This is optional.
@property (nonatomic, copy, nullable) NSString *name;

/// Returns "Page X" or name.
@property (nonatomic, readonly, nullable) NSString *pageOrNameString;

@end

NS_ASSUME_NONNULL_END
