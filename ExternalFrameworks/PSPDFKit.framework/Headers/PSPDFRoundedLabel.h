//
//  PSPDFRoundedLabel.h
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

/// Simple rounded label.
PSPDF_CLASS_AVAILABLE @interface PSPDFRoundedLabel : UILabel

/// Corner radius. Defaults to 5.f.
@property (nonatomic) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;

/// Label background. Defaults to `[UIColor colorWithWhite:0.f alpha:0.6f]`.
@property (nonatomic, nullable) UIColor *rectColor UI_APPEARANCE_SELECTOR;

@end
