//
//  PSPDFNewPageConfiguration.h
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
#import "PSPDFEnvironment.h"
#import "PSPDFRectAlignment.h"
#import "PSPDFNewPageConfigurationBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocument;

/// The type of new page that will be added
typedef NS_ENUM(NSInteger, PSPDFNewPageType) {
    /// A empty page
    PSPDFNewPageTypeEmptyPage,

    /// A page with a pattern
    PSPDFNewPageTypeTiledPatternPage,

    /// A page from another document
    PSPDFNewPageTypeFromDocument
} PSPDF_ENUM_AVAILABLE;

/// Specifies a pattern for a new page with a dot grid that is 5mm apart.
PSPDF_EXPORT NSString *const PSPDFNewPagePatternDot5mm;

/// Specifies a pattern for a new page with a grid that is 5mm apart.
PSPDF_EXPORT NSString *const PSPDFNewPagePatternGrid5mm;

/// Specifies a pattern for a new page with lines that are 5mm apart.
PSPDF_EXPORT NSString *const PSPDFNewPagePatternLines5mm;

/// Specifies a pattern for a new page with lines that are 7mm apart.
PSPDF_EXPORT NSString *const PSPDFNewPagePatternLines7mm;

/// This class configures a new page for the `PSPDFProcessor` or `PSPDFDocumentEditor`.
/// You can configure what type of page it should be and also add images or logos from a PDF.
PSPDF_CLASS_AVAILABLE @interface PSPDFNewPageConfiguration : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Configures a `PSPDFNewPageConfiguration` with an empty page and allows you to set additional properties with the `PSPDFNewPageConfigurationBuilder`.
+ (instancetype)newPageConfigurationWithEmptyPageBuilder:(nullable void (^)(PSPDFNewPageConfigurationBuilder *builder))builderBlock;

/// Configures a `PSPDFNewPageConfiguration` with a tiled pattern page and allows you to set additional properties with the `PSPDFNewPageConfigurationBuilder`.
/// See `PSPDFNewPagePatternDot5mm`, `PSPDFNewPagePatternGrid5mm`, `PSPDFNewPagePatternLines5mm` and `PSPDFNewPagePatternLines7mm` for tiled patterns.
+ (instancetype)newPageConfigurationWithTiledPattern:(NSString *)tiledPattern builderBlock:(nullable void (^)(PSPDFNewPageConfigurationBuilder *builder))builderBlock;

/// Configures a `PSPDFNewPageConfiguration` with a page from a different document and allows you to set additional properties with the `PSPDFNewPageConfigurationBuilder`.
+ (instancetype)newPageConfigurationWithDocument:(PSPDFDocument *)sourceDocument sourcePageIndex:(NSUInteger)sourcePageIndex builderBlock:(nullable void (^)(PSPDFNewPageConfigurationBuilder *builder))builderBlock;

/// The type of page that will be created.
@property (nonatomic, readonly) PSPDFNewPageType newPageType;

/// The configured page size. If this is `CGSizeZero`, the size of the first page in the resulting document will be used.
@property (nonatomic, readonly) CGSize pageSize;

/// The configured page rotation. Can only be 0, 90, 180 or 270.
@property (nonatomic, readonly) NSUInteger pageRotation;

/// The configured background color. If nil, no background color will be set in the resulting page.
@property (nonatomic, readonly, nullable) UIColor *backgroundColor;

/// The page margins. This is mainly useful for aligning items.
@property (nonatomic, readonly) UIEdgeInsets pageMargins;

/// The tiled pattern that is configured.
@property (nonatomic, readonly, copy, nullable) NSString *tiledPattern;

/// The source document if a page is being copied.
@property (nonatomic, readonly, nullable) PSPDFDocument *sourceDocument;

/// The index of the page that should be copied from `sourceDocument`.
@property (nonatomic, readonly) NSUInteger sourcePageIndex;

/// The `item` that will be added to the new page.
@property (nonatomic, readonly, nullable) PSPDFProcessorItem *item;

@end

NS_ASSUME_NONNULL_END
