//
//  PSPDFSignatureFormElement.h
//  PSPDFKit
//
//  Copyright © 2013-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFFormElement.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFInkAnnotation, PSPDFSignatureInfo, PSPDFSignatureStatus;

/// Signature Form Element.
PSPDF_CLASS_AVAILABLE @interface PSPDFSignatureFormElement : PSPDFFormElement

/**
 Returns YES if the signature field is digitally signed.
 @note This does not mean that the signature is valid.
 */
@property (nonatomic, readonly) BOOL isSigned;

/// Signature information.
@property (nonatomic, readonly, nullable) PSPDFSignatureInfo *signatureInfo;

/**
 Searches the document for an ink signature that overlaps the form element.
 @note This can be used as a replacement for a digital signature.
 */
@property (nonatomic, readonly, nullable) PSPDFInkAnnotation *overlappingInkSignature;

@end

@interface PSPDFSignatureFormElement (SubclassingHooks)

/**
 Customize the arrow drawing.
 Used for the "Sign" arrow in unsigned signature form elements.
 */
- (void)drawArrowWithText:(NSString *)text andColor:(UIColor *)color inContext:(CGContextRef)context;

@end

NS_ASSUME_NONNULL_END
