//
//  PSPDFSearchStatusCell.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFSearchViewController.h"
#import "PSPDFSpinnerCell.h"

NS_ASSUME_NONNULL_BEGIN

/// Cell that is used to display the search status.
PSPDF_CLASS_AVAILABLE @interface PSPDFSearchStatusCell : PSPDFSpinnerCell

/// Returns the required cell height.
+ (CGFloat)cellHeight;

/// Updates the cell with the number of new search results.
- (void)updateCellWithSearchStatus:(PSPDFSearchStatus)searchStatus results:(NSUInteger)results page:(NSUInteger)page pageCount:(NSUInteger)pageCount;

@end

NS_ASSUME_NONNULL_END
