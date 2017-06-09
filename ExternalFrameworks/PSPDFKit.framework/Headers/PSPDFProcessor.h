//
//  PSPDFProcessor.h
//  PSPDFKit
//
//  Copyright © 2012-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFDataSink.h"
#import "PSPDFEnvironment.h"
#import "PSPDFMacros.h"
#import "PSPDFProcessorConfiguration.h"
#import "PSPDFProcessorSaveOptions.h"
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument, PSPDFConversionOperation;

/**
 Available keys for options. `PSPDFProcessorAnnotationDictKey` in form of pageIndex -> annotations.
 Annotations will be flattened when type is set, unless `PSPDFProcessorAnnotationAsDictionaryKey` is also set.
 Don't forget to also define the types of annotations that should be processed:
 `PSPDFProcessorAnnotationTypesKey: @(PSPDFAnnotationTypeAll)`.
 */
PSPDF_EXPORT NSString *const PSPDFProcessorAnnotationTypesKey;
PSPDF_EXPORT NSString *const PSPDFProcessorAnnotationDictKey;

/// Set to `@YES` to add annotations as dictionary and don't flatten them. Dictionary keys are the *original* page indexes.
PSPDF_EXPORT NSString *const PSPDFProcessorAnnotationAsDictionaryKey;

/// Specifies the user password that should be set on the generated PDF.
PSPDF_EXPORT NSString *const PSPDFProcessorUserPasswordKey;

/// Specifies the owner password that should be set on the generated PDF.
PSPDF_EXPORT NSString *const PSPDFProcessorOwnerPasswordKey;

/**
 Specifies the key length that should be used to encrypt the PDF. Value must be
 divisible by 8 and in the range of 40 to 128.
 */
PSPDF_EXPORT NSString *const PSPDFProcessorKeyLengthKey;

/// Settings for the string/URL -> PDF generators.

/// Defaults to `PSPDFPaperSizeA4`
PSPDF_EXPORT NSString *const PSPDFProcessorPageRectKey;

/// Defaults to 10. Set lower to optimize, higher if you have a lot of content.
PSPDF_EXPORT NSString *const PSPDFProcessorNumberOfPagesKey;

/// Defines the page margin. Defaults to `UIEdgeInsetsMake(5, 5, 5, 5)`.
PSPDF_EXPORT NSString *const PSPDFProcessorPageBorderMarginKey;

/**
 If you print web pages, they might load async content which can't be reliably detected.
 Defaults to 0.05 seconds. Set higher if you get blank pages.
 */
PSPDF_EXPORT NSString *const PSPDFProcessorAdditionalDelayKey;

/// Defaults to NO. Adds an additional step to strip white pages if you're getting any at the end.
PSPDF_EXPORT NSString *const PSPDFProcessorStripEmptyPagesKey;

/// Defaults to NO. Will assume output is already a valid PDF and just perform annotation saving.
PSPDF_EXPORT NSString *const PSPDFProcessorSkipPDFCreationKey;

/// Common page sizes. Use for `PSPDFProcessorPageRectKey`.
PSPDF_EXPORT const CGRect PSPDFPaperSizeA4;
PSPDF_EXPORT const CGRect PSPDFPaperSizeLetter;

/**
 common options
 Will override any defaults if set.
 */
PSPDF_EXPORT NSString *const PSPDFProcessorDocumentTitleKey;

/// 1st argument: current page, 2nd argument: total pages
typedef void (^PSPDFProgressBlock)(NSUInteger currentPage, NSUInteger totalPages);

/// Create, merge or modify PDF documents. Also allows to flatten annotation data.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFProcessor : NSObject

/**
 Generates a new document based on `PSPDFProcessorConfiguration` and stores it
 to `fileURL`.

 @param configuration The configuration you want to use for the processing.
 @param saveOptions   The save options to use or `nil` if you want to keep the ones from the original document.
 @param fileURL       The URL to save the generated document to. Needs to be a fileURL.
 @param progressBlock The progress block to monitor progress on the generation process. Can be `NULL`. The progress block is called on an arbitrary queue.
 @param error         On return, contains an error if one occured while generating the document.

 @return `YES` if generation was successful, `NO` otherwise.
 */
+ (BOOL)generatePDFFromConfiguration:(PSPDFProcessorConfiguration *)configuration saveOptions:(nullable PSPDFProcessorSaveOptions *)saveOptions outputFileURL:(NSURL *)fileURL progressBlock:(nullable PSPDFProgressBlock)progressBlock error:(NSError **)error;

/**
 Generates a new document based on `PSPDFProcessorConfiguration` and returns it.

 @note The data object will be memory-mapped if possible, however we encourage you to use the file url based variant instead.

 @see +generatePDFFromConfiguration:saveOptions:outputFileURL:progressBlock:error:

 @param configuration The configuration you want to use for the processing.
 @param saveOptions   The save options to use or `nil` if you want to keep the ones from the original document.
 @param progressBlock The progress block to monitor progress on the generation process. Can be `NULL`. The progress block is called on an arbitrary queue.
 @param error         On return, contains an error if one occured while generating the document.

 @return An `NSData` object containing the generated document. If possible, this object is memory-mapped.
 */
+ (nullable NSData *)generatePDFFromConfiguration:(PSPDFProcessorConfiguration *)configuration saveOptions:(nullable PSPDFProcessorSaveOptions *)saveOptions progressBlock:(nullable PSPDFProgressBlock)progressBlock error:(NSError **)error;

/**
 Generates a new document based on `PSPDFProcessorConfiguration` and returns it.

 @param configuration   The configuration you want to use for the processing.
 @param saveOptions     The save options to use or `nil` if you want to keep the ones from the original document.
 @param outputDataSink  The generated document will be written into `outputDataSink`.
 @param progressBlock   The progress block to monitor progress on the generation process. Can be `NULL`. The progress block is called on an arbitrary queue.
 @param error           On return, contains an error if one occured while generating the document.

 @return `YES` if generation was successful, `NO` otherwise.
 */
+ (BOOL)generatePDFFromConfiguration:(PSPDFProcessorConfiguration *)configuration saveOptions:(nullable PSPDFProcessorSaveOptions *)saveOptions outputDataSink:(id<PSPDFDataSink>)outputDataSink progressBlock:(nullable PSPDFProgressBlock)progressBlock error:(NSError **)error;

#if TARGET_OS_IOS

/**
 Generates a PDF from a string. Does allow simple html tags.
 @note Will not work with complex HTML pages.
 e.g. `@"This is a <b>test</b>` in `<span style='color:red'>color.</span>`
 */
+ (void)generatePDFFromHTMLString:(NSString *)HTML outputFileURL:(NSURL *)fileURL options:(nullable NSDictionary<NSString *, id> *)options completionBlock:(nullable void (^)(NSError *_Nullable error))completionBlock;

/// Like the above, but create a temporary PDF in memory.
+ (void)generatePDFFromHTMLString:(NSString *)HTML options:(nullable NSDictionary<NSString *, id> *)options completionBlock:(nullable void (^)(NSData *outputData, NSError *_Nullable error))completionBlock;

/**
 Renders a PDF from an `URL` (web or `fileURL`).
 Upon completion, the `completionBlock` will be called.

 Loading the URL is non-blocking, however the conversion uses the iOS printing infrastructure and only works on the main thread. Larger documents might stall your application for a while. Download the document to a temporary folder and show a blocking progress HUD while the conversion is running to mitigate the blocking.

 Supported are web pages and certain file types like pages, keynote, word, powerpoint, excel, rtf, jpg, png, ...
 See https://developer.apple.com/library/ios/#qa/qa2008/qa1630.html for the full list.

 @note FILE/OFFICE CONVERSION IS AN EXPERIMENTAL FEATURE AND WE CAN'T OFFER SUPPORT FOR CONVERSION ISSUES.
 If you require a 1:1 conversion, you need to convert those files on a server with a product that is specialized for this task.

 Certain documents might not have the correct pagination.
 (Try to manually define `PSPDFProcessorPageRectKey` to fine-tune this.)

 `options` can contain both the PSPDF constants listed above and any `kCGPDFContext` constants.
 For example, to password protect the PDF, you can use:
 `@{(id)kCGPDFContextUserPassword: password,
 (id)kCGPDFContextOwnerPassword: password,
 (id)kCGPDFContextEncryptionKeyLength: @128}`

 Other useful properties are:
 - `kCGPDFContextAllowsCopying`
 - `kCGPDFContextAllowsPrinting`
 - `kCGPDFContextKeywords`
 - `kCGPDFContextAuthor`

 @note Requires the `PSPDFFeatureMaskPDFCreation` feature flag.

 @warning
 Don't manually override NSOperation's `completionBlock`.
 If this helper is used, operation will be automatically queued in `conversionOperationQueue`.
 When a password is set, only link annotations can be added as dictionary (this does not affect flattening)

 Don't use this for PDF files!
 */
+ (nullable PSPDFConversionOperation *)generatePDFFromURL:(NSURL *)inputURL outputFileURL:(NSURL *)outputURL options:(nullable NSDictionary<NSString *, id> *)options completionBlock:(nullable void (^)(NSURL *fileURL, NSError *_Nullable error))completionBlock;

/// Will create a PDF in-memory.
+ (PSPDFConversionOperation *)generatePDFFromURL:(NSURL *)inputURL options:(nullable NSDictionary<NSString *, id> *)options completionBlock:(nullable void (^)(NSData *fileData, NSError *_Nullable error))completionBlock;

#endif

@end

#if TARGET_OS_IOS

/**
 Operation that converts many file formats to PDF.
 Needs to be executed from a thread. Requires the `PSPDFFeatureMaskPDFCreation` feature flag.
 */
PSPDF_CLASS_AVAILABLE @interface PSPDFConversionOperation : NSOperation

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Input. Needs to be a file URL.
@property (nonatomic, copy, readonly) NSURL *inputURL;

/// Output. Needs to be a file URL.
@property (nonatomic, copy, readonly, nullable) NSURL *outputURL;

/// Output data, if data constructor was used.
@property (nonatomic, readonly, nullable) NSData *outputData;

/**
 Options set for conversion.
 @see `generatePDFFromURL:outputFileURL:options:completionBlock:` for a list of options.
 */
@property (nonatomic, copy, readonly, nullable) NSDictionary<NSString *, id> *options;

/// Error if something went wrong.
@property (nonatomic, readonly, nullable) NSError *error;

@end

#endif

NS_ASSUME_NONNULL_END
