//
//  PSPDFNamedAction.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAction.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument;

typedef NS_ENUM(NSUInteger, PSPDFNamedActionType) {
    PSPDFNamedActionTypeNone,
    PSPDFNamedActionTypeNextPage,
    PSPDFNamedActionTypePreviousPage,
    PSPDFNamedActionTypeFirstPage,
    PSPDFNamedActionTypeLastPage,
    PSPDFNamedActionTypeGoBack,
    PSPDFNamedActionTypeGoForward,
    PSPDFNamedActionTypeGoToPage,
    PSPDFNamedActionTypeFind,
    PSPDFNamedActionTypePrint,
    PSPDFNamedActionTypeOutline,
    PSPDFNamedActionTypeSearch,
    PSPDFNamedActionTypeBrightness,
    /// not implemented
    PSPDFNamedActionTypeZoomIn,
    /// not implemented
    PSPDFNamedActionTypeZoomOut,
    /// Triggers `[document saveChangedAnnotationsWithError:]`
    PSPDFNamedActionTypeSaveAs,
    PSPDFNamedActionTypeInfo,
    PSPDFNamedActionTypeUnknown = NSUIntegerMax
} PSPDF_ENUM_AVAILABLE;

/// Transforms named actions to enum type and back.
PSPDF_EXPORT NSString *const PSPDFNamedActionTypeTransformerName;

/// Defines methods used to work with actions in PDF documents, some of which are named in the Adobe PDF Specification.
PSPDF_CLASS_AVAILABLE @interface PSPDFNamedAction : PSPDFAction

/// Initialize with string. Will parse action, set to `PSPDFNamedActionTypeUnknown` if not recognized or nil.
- (instancetype)initWithActionNamedString:(NSString * _Nullable)actionNameString;

/// The type of the named action.
/// @note Will update `namedAction` if set.
@property (nonatomic, readonly) PSPDFNamedActionType namedActionType;

/// The string of the named action.
/// @note Will update `namedActionType` if set.
@property (nonatomic, copy, readonly, nullable) NSString *namedAction;

/// Certain action types (`PSPDFActionTypeNamed`) calculate the target page dynamically from the current page.
/// @return The calculated page or `NSNotFound` if action doesn't specify page manipulation (like `PSPDFNamedActionTypeFind`)
- (NSUInteger)pageIndexWithCurrentPage:(NSUInteger)currentPage fromDocument:(PSPDFDocument *)document;

@end

NS_ASSUME_NONNULL_END
