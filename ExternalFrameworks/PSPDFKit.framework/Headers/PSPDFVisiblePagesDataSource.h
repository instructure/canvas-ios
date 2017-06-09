//
//  PSPDFVisiblePagesDataSource.h
//  PSPDFKit
//
//  Copyright © 2014-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

/// Defines what page(s) are currently visible.
PSPDF_AVAILABLE_DECL @protocol PSPDFVisiblePagesDataSource<NSObject>

/// The page that fills the majority of the screen.
@property (nonatomic, readonly) NSUInteger pageIndex;

/// All visible page indexes (wrapped as NSNumbers)
@property (nonatomic, readonly) NSOrderedSet<NSNumber *> *visiblePageIndexes;

/// Visible page numbers, calculated. This only includes the second page in double page mode.
/// The main difference to `visiblePageIndexes` is that e.g. in continuous scroll mode, it only returns one page.
@property (nonatomic, readonly) NSOrderedSet<NSNumber *> *visiblePageIndexesCalculated;

@end

NS_ASSUME_NONNULL_END
