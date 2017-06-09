//
//  PSPDFSignatureInfo.h
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

@class PSPDFSignaturePropBuild, PSPDFDigitalSignatureReference;

NS_ASSUME_NONNULL_BEGIN

/**
 Signature info for signature form fields.
 @see `PSPDFSignatureFormElement`
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFSignatureInfo : NSObject

/// Specifies how many placeholder bytes will be reserved for the signature.
@property (nonatomic, readonly) NSUInteger placeholderBytes;

/// The signature data.
@property (nonatomic, copy, readonly, nullable) NSData *contents;

/// The byte range of the data being signed.
@property (nonatomic, copy, readonly, nullable) NSArray *byteRange;

/// The filter name.
@property (nonatomic, copy, readonly, nullable) NSString *filter;

/// The sub filter name.
@property (nonatomic, copy, readonly, nullable) NSString *subFilter;

/// The name.
@property (nonatomic, copy, readonly, nullable) NSString *name;

/// The creation date of the signature.
@property (nonatomic, copy, readonly, nullable) NSDate *creationDate;

/// The reason.
@property (nonatomic, copy, readonly, nullable) NSString *reason;

/// The build properties of the signature.
@property (nonatomic, copy, readonly, nullable) PSPDFSignaturePropBuild *propBuild;

/// (Optional; PDF 1.5) An array of signature reference dictionaries.
@property (nonatomic, copy, readonly, nullable) NSArray<PSPDFDigitalSignatureReference *> *references;

@end

NS_ASSUME_NONNULL_END
