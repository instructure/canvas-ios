//
//  PSPDFGoToAction.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAction.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFDocumentProvider;

/// Defines the action of going to a specific location within the PDF document.
PSPDF_CLASS_AVAILABLE @interface PSPDFGoToAction : PSPDFAction

/// Initializer with the page index.
- (instancetype)initWithPageIndex:(NSUInteger)pageIndex;

/// Set to `NSNotFound` if not valid.
@property (nonatomic, readonly) NSUInteger pageIndex;

@end

NS_ASSUME_NONNULL_END
