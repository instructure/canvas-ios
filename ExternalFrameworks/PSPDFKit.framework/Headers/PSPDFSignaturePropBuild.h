//
//  PSPDFSignaturePropBuild.h
//  PSPDFModel
//
//  Copyright © 2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

@class PSPDFSignaturePropBuildEntry;

NS_ASSUME_NONNULL_BEGIN

/**
 Represents entries in the signature properties.
 Signatures can have properties that describe how and when they were built.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFSignaturePropBuild : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// (Optional; PDF 1.5) A build data dictionary (Table 2.2) for the signature handler that was used to create the parent signature. This entry is optional but highly recommended for all signatures.
@property (nonatomic, copy, readonly, nullable) PSPDFSignaturePropBuildEntry *filter;

/// (Optional; PDF 1.5) A build data dictionary (Table 2.2) for the PubSec software module that was used to create the parent signature.
@property (nonatomic, copy, readonly, nullable) PSPDFSignaturePropBuildEntry *pubSec;

/// (Optional; PDF 1.5) A build data dictionary (Table 2.2) for the PDF/ SigQ Conformance Checker that was used to create the parent signature.
@property (nonatomic, copy, readonly, nullable) PSPDFSignaturePropBuildEntry *app;

/// (Optional; PDF 1.7) A build data dictionary (Table 2.2) for the PDF/ SigQ Specification and Conformance Checker that was used to create the parent signature. This entry is present only if the document conforms to the version of the PDF/SigQ specification indicated by the upper 16 bits of the R entry in this dictionary.
@property (nonatomic, copy, readonly, nullable) PSPDFSignaturePropBuildEntry *sigQ;

@end

NS_ASSUME_NONNULL_END
