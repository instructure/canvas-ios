//
//  PSPDFFormRequest.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

typedef NS_OPTIONS(NSUInteger, PSPDFSubmitFormActionFormat) {
    PSPDFSubmitFormActionFormatFDF,
    PSPDFSubmitFormActionFormatXFDF,
    PSPDFSubmitFormActionFormatHTML,
    PSPDFSubmitFormActionFormatPDF
} PSPDF_ENUM_AVAILABLE;

NS_ASSUME_NONNULL_BEGIN

PSPDF_CLASS_AVAILABLE @interface PSPDFFormRequest : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

- (instancetype)initWithFormat:(PSPDFSubmitFormActionFormat)format values:(NSDictionary<NSString *, id> *)values request:(NSURLRequest *)request NS_DESIGNATED_INITIALIZER;

/// How the form data is to be encoded in the submission.
@property (nonatomic, readonly) PSPDFSubmitFormActionFormat submissionFormat;

/// Keys and values of the data to be submitted.
@property (nonatomic, readonly) NSDictionary<NSString *, id> *formValues;

/// The URL request that will be used to fulfill the submission.
@property (nonatomic, readonly) NSURLRequest *request;

@end

NS_ASSUME_NONNULL_END
