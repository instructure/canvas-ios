//
//  PSPDFLabelParser.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>
#import "PSPDFMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocumentProvider;

/// Parses Page Labels (see PDF Reference §8.3.1)
/// Add custom labels with Adobe Acrobat.
/// http://www.w3.org/WAI/GL/WCAG20-TECHS/PDF17.html
PSPDF_CLASS_AVAILABLE @interface PSPDFLabelParser : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Attached document provider.
@property (nonatomic, weak, readonly) PSPDFDocumentProvider *documentProvider;

/// Returns a page label for a certain page. Returns nil if no `pageLabel` is available.
- (nullable NSString *)pageLabelForPage:(NSUInteger)page;

/// Search all page labels for a matching page. Returns `NSNotFound` if page not found.
/// If partialMatching is enabled, the most likely page match is returned.
- (NSUInteger)pageForPageLabel:(NSString *)pageLabel partialMatching:(BOOL)partialMatching;

/// Returns all page labels.
/// @return Labels as ordered dictionary of page number to page label.
@property (nonatomic, copy, readonly) NSDictionary<NSNumber *, NSString *> *labels;

@end

NS_ASSUME_NONNULL_END
