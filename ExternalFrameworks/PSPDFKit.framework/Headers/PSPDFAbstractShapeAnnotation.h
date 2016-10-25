//
//  PSPDFAbstractShapeAnnotation.h
//  PSPDFKit
//
//  Copyright (c) 2015-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

PSPDF_CLASS_AVAILABLE @interface PSPDFAbstractShapeAnnotation : PSPDFAnnotation

/// The annotation data in a format suitable for display in PSPDFDrawLayer.
/// Modifies the annotation content when set. The values should be boxed `PSPDFDrawingPoint` structs.
@property (nonatomic, strong) NSArray<NSArray<NSValue *> *> *pointSequences;

@end

NS_ASSUME_NONNULL_END
