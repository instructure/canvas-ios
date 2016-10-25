//
//  PSPDFColorButton.h
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
#import "PSPDFButton.h"

NS_ASSUME_NONNULL_BEGIN

/// Button that shows a selected color. Highlightable.
PSPDF_CLASS_AVAILABLE @interface PSPDFColorButton : PSPDFButton

/// Current color.
@property (nonatomic) UIColor *color;

/// Drawing mode.
@property (nonatomic) BOOL displayAsEllipse;

/// Border width. Defaults to 3.0
@property (nonatomic) CGFloat borderWidth;

/// Indicator size. Defaults to the bounds size
@property (nonatomic) CGSize indicatorSize;

@end

NS_ASSUME_NONNULL_END
