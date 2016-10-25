//
//  PSPDFSignatureFormElement.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
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

/// Returns YES if the signature field is digitally signed.
/// @note This does not mean that the signature is valid.
@property (nonatomic, readonly) BOOL isSigned;

/// Signature information.
@property (nonatomic, nullable) PSPDFSignatureInfo *signatureInfo;

/// Searches the document for an ink signature that overlaps the form element.
/// @note This can be used as a replacement for a digital signature.
@property (nonatomic, readonly, nullable) PSPDFInkAnnotation *overlappingInkSignature;

@end

@interface PSPDFSignatureFormElement (SubclassingHooks)

- (void)drawArrowWithText:(NSString *)text andColor:(UIColor *)color inContext:(CGContextRef)context;

@end

PSPDF_CLASS_AVAILABLE @interface PSPDFSignaturePropBuildEntry : PSPDFModel

@property (nonatomic, copy, readonly, nullable) NSString *name;
@property (nonatomic, copy, readonly, nullable) NSString *date;
@property (nonatomic, readonly) NSInteger R;
@property (nonatomic, copy, readonly, nullable) NSString *OS;
@property (nonatomic, readonly, nullable) NSNumber *preRelease;     // BOOL
@property (nonatomic, readonly, nullable) NSNumber *nonEFontNoWarn; // BOOL
@property (nonatomic, readonly, nullable) NSNumber *trustedMode;    // BOOL
@property (nonatomic, readonly) NSInteger V;
@property (nonatomic, copy, readonly, nullable) NSString *REx;

@end

PSPDF_CLASS_AVAILABLE @interface PSPDFSignaturePropBuild : PSPDFModel

@property (nonatomic, copy, readonly, nullable) PSPDFSignaturePropBuildEntry *filter;
@property (nonatomic, copy, readonly, nullable) PSPDFSignaturePropBuildEntry *pubSec;
@property (nonatomic, copy, readonly, nullable) PSPDFSignaturePropBuildEntry *app;
@property (nonatomic, copy, readonly, nullable) PSPDFSignaturePropBuildEntry *sigQ;

@end

PSPDF_CLASS_AVAILABLE @interface PSPDFSignatureInfo : PSPDFModel

@property (nonatomic, readonly) NSUInteger placeholderBytes;
@property (nonatomic, copy, readonly, nullable) NSData *contents;
@property (nonatomic, copy, readonly, nullable) NSArray *byteRange;
@property (nonatomic, copy, readonly, nullable) NSString *filter;
@property (nonatomic, copy, readonly, nullable) NSString *subFilter;
@property (nonatomic, copy, readonly, nullable) NSString *name;
@property (nonatomic, copy, readonly, nullable) NSDate *creationDate;
@property (nonatomic, copy, readonly, nullable) NSString *reason;
@property (nonatomic, copy, readonly, nullable) PSPDFSignaturePropBuild *propBuild;

/// (Optional; PDF 1.5) An array of signature reference dictionaries.
@property (nonatomic, copy, readonly, nullable) NSArray *references;

@end

NS_ASSUME_NONNULL_END
