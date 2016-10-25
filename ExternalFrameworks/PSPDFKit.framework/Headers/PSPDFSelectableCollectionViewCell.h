//
//  PSPDFSelectableCollectionViewCell.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

typedef NS_ENUM(NSUInteger, PSPDFSelectableCollectionViewCellStyle) {
    PSPDFSelectableCollectionViewCellStyleNone,
    PSPDFSelectableCollectionViewCellStyleCheckmark,
    PSPDFSelectableCollectionViewCellStyleBorder
} PSPDF_ENUM_AVAILABLE;

/// Cell that shows a selection status.
PSPDF_CLASS_AVAILABLE @interface PSPDFSelectableCollectionViewCell : UICollectionViewCell

/// Shows overlay when selected. Defaults to `PSPDFSelectableCollectionViewCellStyleCheckmark`.
@property (nonatomic) PSPDFSelectableCollectionViewCellStyle selectableCellStyle;

/// Allows setting a custom selection tint color. Only relevant for `PSPDFSelectableCollectionViewCellStyleBorder`.
@property (nonatomic, nullable) UIColor *selectableCellColor UI_APPEARANCE_SELECTOR;

@end
