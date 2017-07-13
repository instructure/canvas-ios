//
//  PSPDFSignatureStatus.h
//  PSPDFKit
//
//  Copyright © 2013-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFSignatureFormElement;

/// Severity of a signature validation problem
typedef NS_ENUM(NSInteger, PSPDFSignatureStatusSeverity) {
    /// The validation status does not contain any problem.
    PSPDFSignatureStatusSeverityNone = 0,
    /// The validation status has some important but not blocker problems (ie. signed with a self-signed certificate).
    PSPDFSignatureStatusSeverityWarning,
    /// The validation status has some blocker problems. The signature should not be trusted.
    PSPDFSignatureStatusSeverityError,
} PSPDF_ENUM_AVAILABLE;


/// Represents the status of a digital signature after it has been validated.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFSignatureStatus : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Designated initializer. Initializes a signature status from a given signer name, a signing date, and whether the signature was modified or not.
- (instancetype)initWithSigner:(nullable NSString *)signer signingDate:(nullable NSDate *)date wasModified:(BOOL)wasModified NS_DESIGNATED_INITIALIZER;

/// The signer name
@property (nonatomic, copy, nullable, readonly) NSString *signer;

/// The signing date
@property (nonatomic, copy, nullable, readonly) NSDate *signingDate;

/// Returns YES if the signature was modified since the document was signed, NO otherwise
@property (nonatomic, readonly) BOOL wasModified;

/// Returns an array of problems as text strings
@property (nonatomic, readonly) NSArray<NSString *> *problems;

/// The status severity
@property (nonatomic) PSPDFSignatureStatusSeverity severity;

/// Returns a status summary with the specified signer name and signing date
@property (nonatomic, readonly) NSString *summary;

@end

NS_ASSUME_NONNULL_END
