//
//  PSPDFAnnotationViewProtocol.h
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

@class PSPDFAnnotation, PSPDFPageView, PSPDFConfiguration;

NS_ASSUME_NONNULL_BEGIN

/// Conforming to this protocol indicates instances can present an annotation and react events such as page show/hide (to pause video, for example)
PSPDF_AVAILABLE_DECL @protocol PSPDFAnnotationViewProtocol <NSObject>

@optional

/// Represented annotation this object is presenting.
@property (nonatomic) PSPDFAnnotation *annotation;

/// Allows ordering of annotation views.
@property (nonatomic) NSUInteger zIndex;

/// Allows adapting to the outer zoomScale. Re-set after zooming.
@property (nonatomic) CGFloat zoomScale;

/// Allows adapting to the initial pdfScale
@property (nonatomic) CGFloat PDFScale;

/// Called when `pageView` is displayed.
- (void)didShowPageView:(PSPDFPageView *)pageView;

/// Called when `pageView` is hidden.
- (void)didHidePageView:(PSPDFPageView *)pageView;

/// Called initially and when the parent page size is changed. (e.g. rotation)
- (void)didChangePageBounds:(CGRect)bounds;

/// Called when the user taps on an annotation and the tap wasn't processed otherwise.
- (void)didTapAtPoint:(CGPoint)point;

/// Queries the view if removing should be in sync or happen instantly.
/// If not implemented, return YES is assumed.
@property (nonatomic, readonly) BOOL shouldSyncRemovalFromSuperview;

/// View is queued for being removed, but still waits for a page sync.
/// This is called regardless of what is returned in `shouldSyncRemovalFromSuperview`.
- (void)willRemoveFromSuperview;

/// A weak reference to the page view responsible for this view.
@property (nonatomic, weak) PSPDFPageView *pageView;

/// A reference to the used configuration.
@property (nonatomic) PSPDFConfiguration *configuration;

/// Indicates if the view is selected.
@property (nonatomic, getter=isSelected) BOOL selected;

@end

NS_ASSUME_NONNULL_END
