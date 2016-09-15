//
//  PSPDFResetFormAction.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAbstractFormAction.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, PSPDFResetFormActionFlag) {
    PSPDFResetFormActionFlagIncludeExclude = 1 << (1-1)
} PSPDF_ENUM_AVAILABLE;

/// Reset Form Action.
PSPDF_CLASS_AVAILABLE @interface PSPDFResetFormAction : PSPDFAbstractFormAction

/// Designated initializer with reset form action `flags`.
- (instancetype)initWithFlags:(PSPDFResetFormActionFlag)flags;

/// The reset form action flags.
@property (nonatomic, readonly) PSPDFResetFormActionFlag flags;

@end

NS_ASSUME_NONNULL_END
