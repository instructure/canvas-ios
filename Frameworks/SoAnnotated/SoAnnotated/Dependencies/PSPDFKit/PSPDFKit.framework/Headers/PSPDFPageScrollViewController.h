//
//  PSPDFPageScrollViewController.h
//  PSPDFKit
//
//  Copyright (c) 2012-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PSPDFBaseViewController.h"
#import "PSPDFViewController.h"
#import "PSPDFPresentationContext.h"

NS_ASSUME_NONNULL_BEGIN

PSPDF_CLASS_AVAILABLE @interface PSPDFPagingScrollView : UIScrollView @end

@class PSPDFPageView;

/// Handles the default per-page side-scrolling.
PSPDF_CLASS_AVAILABLE @interface PSPDFPageScrollViewController : PSPDFBaseViewController <UIScrollViewDelegate>

/// Convenience initializer.
- (instancetype)initWithPresentationContext:(id<PSPDFPresentationContext>)presentationContext;

/// Associated `PSPDFPresentationContext` object.
@property (nonatomic, weak) id<PSPDFPresentationContext> presentationContext;

/// Main scroll view.
@property (nonatomic, readonly) UIScrollView *pagingScrollView;

/// Access visible page numbers.
@property (nonatomic, readonly) NSOrderedSet<NSNumber *> *visiblePages;

/// Access the `PSPDFPageView` object for a page, if loaded.
- (nullable PSPDFPageView *)pageViewForPage:(NSUInteger)page;

/// Explicitly reload the view.
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
