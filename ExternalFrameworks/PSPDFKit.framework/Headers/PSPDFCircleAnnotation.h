//
//  PSPDFCircleAnnotation.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAbstractShapeAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

/// The PDF Circle annotations (PDF 1.3) shall display an ellipse on the page.
PSPDF_CLASS_AVAILABLE @interface PSPDFCircleAnnotation : PSPDFAbstractShapeAnnotation

/// The path that represents the circle.
@property (nonatomic, readonly) UIBezierPath *bezierPath;

@end

NS_ASSUME_NONNULL_END
