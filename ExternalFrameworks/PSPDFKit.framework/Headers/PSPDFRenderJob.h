//
//  PSPDFRenderJob.h
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
#import "PSPDFRenderQueue.h"
#import "PSPDFEnvironment.h"
#import "PSPDFMacros.h"

@class PSPDFDocument;

NS_ASSUME_NONNULL_BEGIN

/// A render job is designed to be created and then treated as immutable.
/// The internal hash is cached and you'll get weird results if renderJob is changed after being added to the queue.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFRenderJob : NSObject

@property (nonatomic, readonly) PSPDFDocument *document;
@property (nonatomic, readonly) NSUInteger page;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) CGRect clipRect;
@property (nonatomic, readonly) float zoomScale;
@property (nonatomic, copy, readonly, nullable) NSArray<__kindof PSPDFAnnotation *> *annotations;
@property (nonatomic, readonly) PSPDFRenderQueuePriority priority;
@property (nonatomic, copy, readonly, nullable) NSDictionary<NSString *, id> *options;
@property (nonatomic, weak, readonly) id<PSPDFRenderDelegate> delegate;
@property (nonatomic, readonly, nullable) UIImage *renderedImage;
@property (nonatomic, readonly, nullable) PSPDFRenderReceipt *renderReceipt;
@property (nonatomic, readonly) uint64_t renderTime;

@property (nonatomic, copy, readonly, nullable) void (^completionBlock)(PSPDFRenderJob *renderJob, PSPDFRenderQueue *renderQueue);

@end

NS_ASSUME_NONNULL_END
