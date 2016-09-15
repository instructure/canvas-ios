//
//  PSPDFProcessorConfiguration.h
//  PSPDFModel
//
//  Copyright (c) 2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>

#import "PSPDFMacros.h"
#import "PSPDFRenderManager.h"
#import "PSPDFAnnotation.h"
#import "PSPDFProcessorItem.h"

@class PSPDFDocument;
@class PSPDFNewPageConfiguration;

/// Specifies how a annotation should be included in the resulting document.
/// See `modifyAnnotationsOfType:change:` and `modifyAnnotations:change:error:`.
typedef NS_ENUM(NSInteger, PSPDFAnnotationChange) {
    /// The annotation will be flattened. It can no longer be modified in the resulting document.
    PSPDFAnnotationChangeFlatten,

    /// The annotation will be removed.
    PSPDFAnnotationChangeRemove,

    /// The annotation will be embedded into the resulting document, allowing it to still be modified.
    PSPDFAnnotationChangeEmbed
} PSPDF_ENUM_AVAILABLE;

NS_ASSUME_NONNULL_BEGIN

/// Container for various settings for manipulating documents with `PSPDFProcessor`.
/// @note Some basic options are available without the Document Processor component,
/// however most options do require this component to be licensed.
/// Learn more at https://pspdfkit.com/features/document-editor/ios
PSPDF_CLASS_AVAILABLE @interface PSPDFProcessorConfiguration : NSObject <NSCopying>

 /**
 *  Designated initializer
 *
 *  @param document The document that the configuration is based on.
 *  If a document is given, it needs to be valid, else we return nil.
 *
 *  @return The processor configuration or nil in case the document
 *  cannot be processed or is not valid.
 */
- (nullable instancetype)initWithDocument:(nullable PSPDFDocument *)document;

/// The source document.
@property (nonatomic, readonly, nullable) PSPDFDocument *document;

/// Returns the page count of the currently configured generated document.
@property (nonatomic, readonly) NSInteger pageCount;

/// Moves pages from the specified indexes to the destination index.
/// @note This method requires the Document Editor component to be enabled for your license.
- (void)movePages:(NSIndexSet *)indexes toDestinationIndex:(NSUInteger)destinationPageIndex;

/// Removes pages from the document. This will also update `pageCount`.
- (void)removePages:(NSIndexSet *)indexes;

/// If this is set to @YES, all blank pages will be removed from the generated document.
/// This does NOT update `pageCount` as it only goes into effect while processing the document.
- (void)setShouldStripBlankPagesOnGenerate:(BOOL)shouldStrip;

/// Removes all pages that are not listed in `indexes`.
- (void)includeOnlyIndexes:(NSIndexSet *)indexes;

/// Rotates a page. `degrees` must be a value of 0, 90, 180 or 270.
/// @note This method requires the Document Editor component to be enabled for your license.
- (void)rotatePage:(NSUInteger)pageIndex by:(NSUInteger)degrees;

/// Scales the given page index to the given size. The size must be specified in PDF points.
/// @note This method requires the Document Editor component to be enabled for your license.
- (void)scalePage:(NSUInteger)pageIndex toSize:(CGSize)size;

/// Scales the given page index to the given size. The size must be specified in millimeters.
/// @note This method requires the Document Editor component to be enabled for your license.
- (void)scalePage:(NSUInteger)pageIndex toSizeInMillimeter:(CGSize)mmSize;

/// Changes the `CropBox` for the given page to the given rect. The rect must be specified in points.
/// This does NOT scale the page. See `scalePage:toSizeInMillimeter:` and `scalePage:toSize:`.
/// Definition of a `CropBox` from the PDF spec:
///   The crop box defines the region to which the contents of the page shall be clipped (cropped) when
///   displayed or printed. Unlike the other boxes, the crop box has no defined meaning in terms of physical
///   page geometry or intended use; it merely imposes clipping on the page contents. However, in the absence
///   of additional information (such as imposition instructions specified in a JDF or PJTF job ticket), the crop
///   box determines how the page’s contents shall be positioned on the output medium. The default value is the
///   page’s media box.
/// TL;DR: The visible part of the page.
/// @note This method requires the Document Editor component to be enabled for your license.
- (void)changeCropBoxForPage:(NSUInteger)pageIndex toRect:(CGRect)rect;

/// Changes the `MediaBox` for the given page to the given rect. The rect must be specified in points.
/// This does NOT scale the page. See `scalePage:toSizeInMillimeter:` and `scalePage:toSize:`.
/// Definition of a `MediaBox` from the PDF spec:
///   The media box defines the boundaries of the physical medium on which the page is to be printed. It may
///   include any extended area surrounding the finished page for bleed, printing marks, or other such purposes.
///   It may also include areas close to the edges of the medium that cannot be marked because of physical
///   limitations of the output device. Content falling outside this boundary may safely be discarded without
///   affecting the meaning of the PDF file.
/// TL;DR: The size of the page.
/// @note This method requires the Document Editor component to be enabled for your license.
- (void)changeMediaBoxForPage:(NSUInteger)pageIndex toRect:(CGRect)rect;

/// Adds a new page at `destinationPageIndex`.
/// If `newPageConfiguation` is nil, the size of the new page will match the page size of the first page.
/// @note This method requires the Document Editor component to be enabled for your license.
- (void)addNewPageAtIndex:(NSUInteger)destinationPageIndex configuration:(nullable PSPDFNewPageConfiguration *)newPageConfiguation;

/// This method allows you to change how a certain type of annotation is included in the resulting document.
/// If all annotations should be changed, use `PSPDFAnnotationTypeAll` as the `annotationTypes`.
/// If finer control is needed, look at `modifyAnnotations:change:error:`.
- (void)modifyAnnotationsOfTypes:(PSPDFAnnotationType)annotationTypes change:(PSPDFAnnotationChange)annotationChange;

/// This method allows you to change the way certain annotations are included in the resulting document.
/// The annotations selected here take priority over the changes specified using `modifyAnnotationsOfType:change:`.
/// @note This method might take a long time if you specify a lot of `annotations`. Use carefully.
- (BOOL)modifyAnnotations:(NSArray<PSPDFAnnotation *> *)annotations change:(PSPDFAnnotationChange)annotationChange error:(NSError **)error;

/// Merges the `item` onto the page with index `destinationPageIndex`.
/// A item can be a image or another PDF page, see `PSPDFProcessorItem`.
/// @note This method requires the Document Editor component to be enabled for your license.
- (void)mergeItem:(PSPDFProcessorItem *)item onPage:(NSUInteger)destinationPageIndex;

/// Allows a drawing block of type `PSPDFRenderDrawBlock` being called for each page. This will set up a similar drawing block as you'd get with calling `UIGraphicsBeginImageContext`.
/// The drawing will get flattened on each page currently configured to be exported.
- (void)drawOnAllCurrentPages:(PSPDFRenderDrawBlock)drawBlock;

@end

@interface PSPDFProcessorConfiguration (Metadata)

/// Returns the metadata that will be written into the new document.
/// By default, this is set to the metadata of the original document.
/// @note On writing metadata to the new document, `PSPDFMetadataModDateKey` will be set to the current date and time and
/// `PSPDFMetadataProducerKey` will be set to `PSPDFKit`. You can overwrite these values by setting them with `updateMetadata`.
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *metadata;

/// Updates the metadata that will be saved in the generated PDF.
/// Any value you pass along here will either be replaced or inserted into the current metadata configuration.
/// See `PSPDFMetadataTitleKey` for examples of what keys to use.
/// @note This does not remove any metadata entries. See `clearMetadata`.
- (void)updateMetadata:(NSDictionary<NSString *, NSString *> *)metadata;

/// Clears any previous metadata.
/// @note `PSPDFMetadataModDateKey` and `PSPDFMetadataProducerKey` will still be set in the resulting PDF. See `metadata`.
- (void)clearMetadata;

@end

NS_ASSUME_NONNULL_END
