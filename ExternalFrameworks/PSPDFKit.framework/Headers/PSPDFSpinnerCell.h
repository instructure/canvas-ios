//
//  PSPDFSpinnerCell.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFTableViewCell.h"

/// Base class that shows centered labels and a spinner label.
PSPDF_CLASS_AVAILABLE @interface PSPDFSpinnerCell : PSPDFTableViewCell
@end

@interface PSPDFSpinnerCell (SubclassingHooks)

/// Spinner that is displayed while search is in progress.
@property (nonatomic, readonly) UIActivityIndicatorView *spinner;

/// Re-align text.
- (void)alignTextLabel;

@end
