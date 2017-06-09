//
//  PSPDFPageScrollViewController.h
//  PSPDFKit
//
//  Copyright © 2012-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFBaseViewController.h"
#import "PSPDFEnvironment.h"
#import "PSPDFPresentationContext.h"
#import "PSPDFViewController.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

PSPDF_CLASS_AVAILABLE @interface PSPDFPagingScrollView : UIScrollView
@end

@class PSPDFPageView;

/// Handles the default per-page side-scrolling.
PSPDF_CLASS_AVAILABLE @interface PSPDFPageScrollViewController : PSPDFBaseViewController<UIScrollViewDelegate>

/// Convenience initializer.
- (instancetype)initWithPresentationContext:(id<PSPDFPresentationContext>)presentationContext;

/// Associated `PSPDFPresentationContext` object.
@property (nonatomic, weak) id<PSPDFPresentationContext> presentationContext;

/// Main scroll view.
@property (nonatomic, readonly) UIScrollView *pagingScrollView;

/// Access visible page numbers.
@property (nonatomic, readonly) NSOrderedSet<NSNumber *> *visiblePageIndexes;

/// Access the `PSPDFPageView` object for a page, if loaded.
- (nullable PSPDFPageView *)pageViewForPageAtIndex:(NSUInteger)pageIndex;

/// Explicitly reload the view.
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
