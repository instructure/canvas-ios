//
//  PSPDFSignaturePropBuildEntry.h
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

NS_ASSUME_NONNULL_BEGIN

/**
 Represents one entry in the signature properties.

 Signatures can have properties that describe how and when they were built.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFSignaturePropBuildEntry : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// (Optional; PDF 1.5) The name of the software module used to create the signature. When used as an entry in the data dictionary of the Filter attribute (Table 2.1), the value is the name of the signature handler. The value is normally equal to the value of the Filter attribute in the signature dictionary.
@property (nonatomic, copy, readonly, nullable) NSString *name;

/// (Optional; PDF 1.5) The software module build date. This string is normally produced by the compiler that is used to compile the software, for example using the Date and Time preprocessor flags. As such, this not likely to be in PDF Date format.
@property (nonatomic, copy, readonly, nullable) NSString *date;

/// (Optional; PDF 1.5) The software module revision number.
@property (nonatomic, readonly) NSInteger revisionNumber;

/// (Optional; PDF 1.5) Indicates the operating system
@property (nonatomic, copy, readonly, nullable) NSString *operatingSystem;

/// (Optional; PDF 1.5) A flag that can be used by the signature handler or software module to indicate that this signature was created with unreleased software.
@property (nonatomic, readonly) BOOL preRelease;

/// (Optional; PDF 1.5) If there is a Legal dictionary in the catalog of the PDF file, and the NonEmbeddedFonts attribute (which specifies the number of fonts not embedded) in that dictionary has a non-zero value, and the viewing application has a preference set to suppress the display of the warning about fonts not being embedded, then the value of this attribute will be set to true (meaning that no warning need be displayed)..
@property (nonatomic, readonly) BOOL nonEmbeddedFontNoWarning;

/// (Optional; PDF 1.5) If the value is true, the application was in trusted mode when signing took place. The default value is fa lse. A viewing application is in trusted mode when only reviewed code is executing, where reviewed code is code that does not affect the rendering of PDF files in ways that are not covered by the PDF Reference.
@property (nonatomic, readonly) BOOL trustedMode;

/// (Optional; PDF 1.5; Deprecated for PDF 1.7) Indicates the minimum version number of the software required to process the signature.
@property (nonatomic, readonly) NSInteger minimumVersion;

/// (Optional; PDF 1.6) A text string indicating the version of the application implementation, as described by the Name attribute in this dictionary.
@property (nonatomic, copy, readonly, nullable) NSString *textRevision;

@end

@interface PSPDFSignaturePropBuildEntry (Deprecated)

/// (Optional; PDF 1.5) The software module revision number.
@property (nonatomic, readonly) NSInteger R PSPDF_DEPRECATED(6.7.1, "Use revisionNumber instead.");

/// (Optional; PDF 1.5) Indicates the operating system
@property (nonatomic, copy, readonly, nullable) NSString *OS PSPDF_DEPRECATED(6.7.1, "Use operatingSystem instead.");

/// (Optional; PDF 1.5) If there is a Legal dictionary in the catalog of the PDF file, and the NonEmbeddedFonts attribute (which specifies the number of fonts not embedded) in that dictionary has a non-zero value, and the viewing application has a preference set to suppress the display of the warning about fonts not being embedded, then the value of this attribute will be set to true (meaning that no warning need be displayed)..
@property (nonatomic, readonly) BOOL nonEFontNoWarn PSPDF_DEPRECATED(6.7.1, "Use nonEmbeddedFontNoWarning instead.");

/// (Optional; PDF 1.5; Deprecated for PDF 1.7) Indicates the minimum version number of the software required to process the signature.
@property (nonatomic, readonly) NSInteger V PSPDF_DEPRECATED(6.7.1, "Use minimumVersion instead.");

/// (Optional; PDF 1.6) A text string indicating the version of the application implementation, as described by the Name attribute in this dictionary.
@property (nonatomic, copy, readonly, nullable) NSString *REx PSPDF_DEPRECATED(6.7.1, "Use textRevision instead.");

@end

NS_ASSUME_NONNULL_END
