//
//  PSPDFSignatureStatus.h
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

NS_ASSUME_NONNULL_BEGIN

typedef int OPENSSL_X509_ERR;

@class PSPDFSignatureFormElement;

typedef NS_ENUM(NSInteger, PSPDFSignatureStatusSeverity) {
    PSPDFSignatureStatusSeverityNone = 0,
    PSPDFSignatureStatusSeverityWarning,
    PSPDFSignatureStatusSeverityError
} PSPDF_ENUM_AVAILABLE;

PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFSignatureStatus : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Designated initializer.
- (instancetype)initWithSigner:(NSString *)signer signingDate:(NSDate *)date wasModified:(BOOL)wasModified NS_DESIGNATED_INITIALIZER;

/// Adds a signature problem report to the status summary and adjusts the
/// status severity if necessary.
- (void)reportSignatureProblem:(OPENSSL_X509_ERR)error;

/// The signer name
@property (nonatomic, copy, readonly) NSString *signer;

/// The signing date
@property (nonatomic, copy, readonly) NSDate *signingDate;

/// Returns YES if the signature was modified since the document was signed,
/// NO otherwise
@property (nonatomic, readonly) BOOL wasModified;

/// Returns an array of problems as text strings
@property (nonatomic, readonly) NSArray<NSString *> *problems;

/// The status severity
@property (nonatomic) PSPDFSignatureStatusSeverity severity;

/// Returns a status summary with the specified signer name and signing date
@property (nonatomic, readonly) NSString *summary;

@end

NS_ASSUME_NONNULL_END
