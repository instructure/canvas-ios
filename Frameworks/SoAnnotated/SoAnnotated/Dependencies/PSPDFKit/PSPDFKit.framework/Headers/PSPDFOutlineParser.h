//
//  PSPDFOutlineParser.h
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

@class PSPDFOutlineElement, PSPDFDocumentProvider;

/// Parses the Outline/Table of Contents of a PDF.
PSPDF_CLASS_AVAILABLE @interface PSPDFOutlineParser : NSObject

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Returns a single outline element for the specified page.
///
/// If `exactPageOnly` is set, the outline will only be returned if it's from the specific page.
/// Else the last active set outline will be returned.
- (nullable PSPDFOutlineElement *)outlineElementForPage:(NSUInteger)page exactPageOnly:(BOOL)exactPageOnly;

/// Returns cached outline. starts parsing if outline is not yet created.
/// Will always return at least a root element.
@property (nonatomic) PSPDFOutlineElement *outline;

/// Returns YES if outline is already parsed.
@property (nonatomic, readonly, getter=isOutlineParsed) BOOL outlineParsed;

/// Returns YES if there is an outline in the document and we parsed it (`outline.children > 0`)
/// Will parse the outline if needed.
@property (nonatomic, readonly, getter=isOutlineAvailable) BOOL outlineAvailable;

/// Attached document provider.
@property (nonatomic, weak, readonly) PSPDFDocumentProvider *documentProvider;

@end

NS_ASSUME_NONNULL_END
