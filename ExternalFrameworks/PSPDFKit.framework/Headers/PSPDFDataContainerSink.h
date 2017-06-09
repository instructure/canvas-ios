//
//  PSPDFDataContainerSink.h
//  PSPDFFoundation
//
//  Copyright © 2015-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFDataSink.h"
#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

/// A `PSPDFDataSink` that works with `PSPDFDataContainerProvider`.
PSPDF_CLASS_AVAILABLE_SUBCLASSING_RESTRICTED @interface PSPDFDataContainerSink : NSObject<PSPDFDataSink>

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Initializes the `PSPDFDataContainerSink` with the initial data.
- (instancetype)initWithData:(NSData *_Nullable)data NS_DESIGNATED_INITIALIZER;

/// Access to the data.
@property (nonatomic, readonly) NSData *data;

@end

NS_ASSUME_NONNULL_END
