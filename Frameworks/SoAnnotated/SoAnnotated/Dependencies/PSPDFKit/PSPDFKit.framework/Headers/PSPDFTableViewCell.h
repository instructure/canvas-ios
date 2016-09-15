//
//  PSPDFTableViewCell.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

/// Base class for table views in PSPDFKit with various helpers.
PSPDF_CLASS_AVAILABLE @interface PSPDFTableViewCell : UITableViewCell
@end

/// Simple subclass that disables animations during `layoutSubviews` if the popover is being resized.
/// This fixes an unexpected animation when the tableView is updated while a popover resizes.
PSPDF_CLASS_AVAILABLE @interface PSPDFNonAnimatingTableViewCell : PSPDFTableViewCell
@end

/// Never allows animations during `layoutSubviews`.
PSPDF_CLASS_AVAILABLE @interface PSPDFNeverAnimatingTableViewCell : PSPDFTableViewCell
@end
