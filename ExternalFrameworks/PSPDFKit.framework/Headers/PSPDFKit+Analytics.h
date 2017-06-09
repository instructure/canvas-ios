//
//  PSPDFKit+Analytics.h
//  PSPDFKit
//
//  Copyright © 2016-2017 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFKit.h"

@class PSPDFAnalytics;

NS_ASSUME_NONNULL_BEGIN

@interface PSPDFKit (Analytics)

/// PSPDFKit analytics instance. All PSPDFKit events are logged with this instance.
@property (nonatomic, readonly) PSPDFAnalytics *analytics;

@end

NS_ASSUME_NONNULL_END
