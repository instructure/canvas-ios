//
//  PSPDFSquareAnnotation.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAbstractShapeAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

/// The PDF Square annotations (PDF 1.3) shall display a rectangle on the page.
PSPDF_CLASS_AVAILABLE @interface PSPDFSquareAnnotation : PSPDFAbstractShapeAnnotation

/// The path that represents the square.
@property (nonatomic, readonly) UIBezierPath *bezierPath;

@end

NS_ASSUME_NONNULL_END
