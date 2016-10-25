//
//  PSPDFDocumentProvider.h
//  PSPDFKit
//
//  Copyright (c) 2011-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFDocumentProviderDelegate.h"

@class PSPDFFormParser, PSPDFEmbeddedFilesParser, PSPDFTextSearch, PSPDFTextParser, PSPDFOutlineParser, PSPDFAnnotationManager, PSPDFDocumentProvider, PSPDFLabelParser, PSPDFDocument, PSPDFPageInfo;
@protocol PSPDFDataProvider;

NS_ASSUME_NONNULL_BEGIN

/** A set of flags specifying which operations shall be permitted when the document is opened with user access. */
typedef NS_OPTIONS(NSUInteger, PSPDFDocumentPermissions) {
    PSPDFDocumentPermissionsNoFlags = 0,
    /** Print the document. See also print_high_quality (Security handlers of revision 3 or greater) */
    PSPDFDocumentPermissionsPrinting = 1 << 0,
    /** Modify the contents of the document */
    PSPDFDocumentPermissionsModification = 1 << 1,
    /**
     * (Security handlers of revision 2) Copy or otherwise extract text and graphics from the document, including extracting text and graphics (in support of accessibility to users with disabilities or for other purposes).
     * (Security handlers of revision 3 or greater) Copy or otherwise extract text and graphics from the document by operations other than that controlled by bit 10.
     */
    PSPDFDocumentPermissionsExtract = 1 << 2,
    /** Add or modify text annotations, fill in interactive form fields, and, if bit 4 is also set, create or modify interactive form fields (including signature fields). */
    PSPDFDocumentPermissionsAnnotationsAndForms = 1 << 3,
    /** (Security handlers of revision 3 or greater) Fill in existing interactive form fields (including signature fields), even if bit 6 is clear. */
    PSPDFDocumentPermissionsFillForms = 1 << 4,
    /** (Security handlers of revision 3 or greater) Extract text and graphics (in support of accessibility to users with disabilities or for other purposes). */
    PSPDFDocumentPermissionsExtractAccessibility = 1 << 5,
    /** (Security handlers of revision 3 or greater) Assemble the document (insert, rotate, or delete pages and create bookmarks or thumbnail images), even if bit 4 is clear. */
    PSPDFDocumentPermissionsAssemble = 1 << 6,
    /** (Security handlers of revision 3 or greater) Print the document to a representation from which a faithful digital copy of the PDF content could be generated. When this bit is clear (and `PDFCDocumentPermissionsPrinting` is set), printing is limited to a low-level representation of the appearance, possibly of degraded quality. */
    PSPDFDocumentPermissionsPrintHighQuality = 1 << 7,
};

/// A `PSPDFDocument` consists of one or multiple `PSPDFDocumentProvider`'s.
/// Each document provider has exactly one data source (file/data/dataProvider)
/// @note This class is used within `PSPDFDocument` and should not be instantiated externally.
PSPDF_CLASS_AVAILABLE @interface PSPDFDocumentProvider : NSObject

/// Referenced NSURL. If this is set, `dataProvider` is nil.
@property (nonatomic, readonly, nullable) NSURL *fileURL;

/// Referenced data provider.
@property (nonatomic, readonly, nullable) id<PSPDFDataProvider> dataProvider;

/// Returns a NSData representation, memory-maps files, copies a `PSPDFDataProvider`.
- (nullable NSData *)dataRepresentationWithError:(NSError **)error;

/// Returns the `fileSize` of this documentProvider.
@property (nonatomic, readonly) unsigned long long fileSize;

/// Accesses the parent document.
@property (nonatomic, weak, readonly) PSPDFDocument *document;

/// Delegate for writing annotations. Defaults to the current set document.
@property (atomic, weak) id<PSPDFDocumentProviderDelegate> delegate;

/// Cached rotation and aspect ratio data for specific page. Page starts at 0.
/// Unlike with `-[PSPDFDocument pageInfoForPage:]` here the returned `PSPDFPageInfo`'s
/// `page` property always equals the supplied `page` argument
- (nullable PSPDFPageInfo *)pageInfoForPage:(NSUInteger)page;

/// Number of pages in the PDF. 0 if source is invalid. Filtered by `pageRange`.
@property (nonatomic, readonly) NSUInteger pageCount;

/// Returns the page offset relative to the document.
@property (nonatomic, readonly) NSUInteger pageOffsetForDocument;

/// Set a password. Doesn't try to unlock the document.
@property (nonatomic, copy, readonly, nullable) NSString *password;

/// The attached content signature.
@property (nonatomic, copy, readonly, nullable) NSData *contentSignature;

/// A PDF flag that indicates whether printing is allowed.
/// @note This replaces `allowsCopying` and `allowsPrinting` from earlier versions of the SDK.
@property (nonatomic, readonly) PSPDFDocumentPermissions permissions;

/// Was the PDF file encrypted at file creation time?
@property (nonatomic, readonly) BOOL isEncrypted;

/// Has the PDF file been unlocked? (is it still locked?).
@property (nonatomic, readonly) BOOL isLocked;

/// Are we able to add/change annotations in this file?
/// Annotations can't be added to encrypted documents or if there are parsing errors.
/// @note If `PSPDFFeatureMaskAnnotationEditing` isn't available, this will return NO.
@property (nonatomic, readonly) BOOL canEmbedAnnotations;

/// A flag that indicates whether changing existing annotations or creating new annotations are allowed
/// @note Searches and checks the digital signatures on the first call (caches the result for subsequent calls)
@property (nonatomic, readonly) BOOL allowAnnotationChanges;

/// Access the PDF title. (".pdf" will be truncated)
/// @note If there's no title in the PDF metadata, the file name will be used.
@property (nonatomic, copy, readonly) NSString *title;

/// Return a textParser for the specific document page. Page starts at 0.
/// Will parse the page contents before returning. Might take a while.
- (nullable PSPDFTextParser *)textParserForPage:(NSUInteger)page;

/// Outline extraction class for current PDF.
/// Lazy initialized. Can be subclassed.
@property (nonatomic, readonly) PSPDFOutlineParser *outlineParser;

/// AcroForm parser.
@property (nonatomic, readonly) PSPDFFormParser *formParser;

/// Embedded files.
@property (nonatomic, readonly) PSPDFEmbeddedFilesParser *embeddedFilesParser;

/// Link annotation parser class for current PDF.
/// Lazy initialized. Can be subclassed.
@property (nonatomic, readonly) PSPDFAnnotationManager *annotationManager;

/// Page labels found in the current PDF.
/// Lazy initialized. Can be subclassed.
@property (nonatomic, readonly) PSPDFLabelParser *labelParser;

/// Access the PDF metadata.
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *metadata;

/// Get the XMP metadata in XML format, if there is any.
@property (nonatomic, readonly, nullable) NSString *XMPMetadata;

/// Allows to customize and override rotation for a page.
/// @note Valid rotation values are 0, 90, 180 and 270.
/// A call to `reloadData` is required if the document is currently displayed in a `PSPDFViewController`.
/// You might also want to clear existing cache, so you don't get a malformed image while re-rendering.
/// `[self.pspdfkit.cache invalidateImageFromDocument:self.document page:page];`
- (void)setRotation:(NSUInteger)rotation forPage:(NSUInteger)page;

@end

@interface PSPDFDocumentProvider (SubclassingHooks)

/// Saves changed annotations.
/// @warning You shouldn't call this method directly, use the high-level save method in `PSPDFDocument` instead.
- (BOOL)saveAnnotationsWithOptions:(nullable NSDictionary<NSString *, id> *)options error:(NSError **)error;

/// Resolves a path like `/localhost/Library/test.pdf` into a full path.
/// If either `alwaysLocal` is set or `localhost` is part of the path, we'll handle this as a local URL.
- (NSString *)resolveTokenizedPath:(NSString *)path alwaysLocal:(BOOL)alwaysLocal;

@end

NS_ASSUME_NONNULL_END
