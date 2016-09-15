//
//  PSPDFError.h
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

NS_ASSUME_NONNULL_BEGIN

/// The PSPDFKit Error Domain.
PSPDF_EXPORT NSString *const PSPDFErrorDomain;

/// List of documented errors within the PSPDFErrorDomain.
/// @note Various PSPDFKit method can also returns errors from Apple-internal error domains.
typedef NS_ENUM(NSInteger, PSPDFErrorCode) {
    PSPDFErrorCodeOutOfMemory = 10,
    PSPDFErrorCodePageInvalid = 100,
    PSPDFErrorCodeDocumentContainsNoPages = 101,
    PSPDFErrorCodeDocumentNotValid = 102,
    PSPDFErrorCodeDocumentLocked = 103,
    PSPDFErrorCodeDocumentInvalidFormat = 104,
    PSPDFErrorCodeUnableToOpenPDF = 200,
    PSPDFErrorCodeUnableToGetPageReference = 210,
    PSPDFErrorCodeUnableToGetStream = 211,
    PSPDFErrorCodeDocumentNotSet = 212,
    PSPDFErrorCodeDocumentProviderNotSet = 213,
    PSPDFErrorCodeStreamPathNotSet = 214,
    PSPDFErrorCodeAssetNameNotSet = 215,
    PSPDFErrorCodeCantCreateStreamFile = 216,
    PSPDFErrorCodeCantCreateStream = 217,
    PSPDFErrorCodePageRenderSizeIsEmpty = 220,
    PSPDFErrorCodePageRenderClipRectTooLarge = 230,
    PSPDFErrorCodePageRenderGraphicsContextNil = 240,
    PSPDFErrorCodeDocumentUnsupportedSecurityScheme = 302,
    PSPDFErrorCodeFailedToLoadAnnotations = 400,
    PSPDFErrorCodeFailedToWriteAnnotations = 410,
    PSPDFErrorCodeWriteAnnotationsCancelled = 411,
    PSPDFErrorCodeCannotEmbedAnnotations = 420,
    PSPDFErrorCodeFailedToLoadBookmarks = 450,
    PSPDFErrorCodeFailedToSaveBookmarks = 460,
    PSPDFErrorCodeOutlineParser = 500,
    PSPDFErrorCodeUnableToConvertToDataRepresentation = 600,
    PSPDFErrorCodeRemoveCacheError = 700,
    PSPDFErrorCodeFailedToConvertToPDF = 800,
    PSPDFErrorCodeFailedToGeneratePDFInvalidArguments = 810,
    PSPDFErrorCodeFailedToGeneratePDFDocumentInvalid = 820,
    PSPDFErrorCodeFailedToGeneratePDFCouldNotCreateContext = 830,
    PSPDFErrorCodeFailedToCopyPages = 840,
    PSPDFErrorCodeFailedToUpdatePageObject = 850,
    PSPDFErrorCodeFailedToMemoryMapFile = 860,
    PSPDFErrorCodeMicPermissionNotGranted = 900,
    PSPDFErrorCodeXFDFParserLackingInputStream = 1000,
    PSPDFErrorCodeXFDFParserAlreadyCompleted = 1010,
    PSPDFErrorCodeXFDFParserAlreadyStarted = 1020,
    PSPDFErrorCodeXMLParserError = 1100,
    PSPDFErrorCodeDigitalSignatureVerificationFailed = 1150,
    PSPDFErrorCodeXFDFWriterCannotWriteToStream = 1200,
    PSPDFErrorCodeFDFWriterCannotWriteToStream = 1250,
    PSPDFErrorCodeSoundEncoderInvalidInput = 1300,
    PSPDFErrorCodeGalleryInvalidManifest = 1400,
    PSPDFErrorCodeGalleryUnknownItem = 1450,
    PSPDFErrorCodeInvalidRemoteContent = 1500,
    PSPDFErrorCodeFailedToSendStatistics = 1600,
    PSPDFErrorCodeLibraryFailedToInitialize = 1700,
    PSPDFErrorCodeFormValidationError = 5000,
    PSPDFErrorCodeImageProcessorInvalidImage = 6000,
    PSPDFErrorCodeOpenInNoApplicationsFound = 7000,
    PSPDFErrorCodeMessageNotSent = 7100,
    PSPDFErrorCodeEmailNotConfigured = 7200,
    PSPDFErrorCodeProcessorAnnotationModificationError = 7300,
    PSPDFErrorCodeProcessorUnableToInsertPage = 7301,
    PSPDFErrorCodeProcessorUnableToFlattenAnnotation = 7302,
    PSPDFErrorCodeProcessorUnableToRemoveAnnotation = 7304,
    PSPDFErrorCodeProcessorUnableToIncludeDrawingBlock = 7305,
    PSPDFErrorCodeProcessorUnableToAddItem = 7306,
    PSPDFErrorCodeProcessorUnableToWriteFile = 7307,
    PSPDFErrorCodeProcessorMiscError = 7308,
    PSPDFErrorCodeDocumentEditorUnableToWriteFile = 7400,
    PSPDFErrorCodeDocumentEditorInvalidDocument = 7401,
    PSPDFErrorCodeFailedToFetchResource = 8000,
    PSPDFErrorCodeFeatureNotEnabled = 100000,
    PSPDFErrorCodeSecurityNoPermission = 200000,
    PSPDFErrorCodeUnknown = NSIntegerMax
} PSPDF_ENUM_AVAILABLE;

NS_ASSUME_NONNULL_END
