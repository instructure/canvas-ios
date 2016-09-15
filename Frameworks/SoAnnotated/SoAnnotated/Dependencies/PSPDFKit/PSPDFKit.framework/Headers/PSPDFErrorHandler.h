//
//  PSPDFErrorHandler.h
//  PSPDFKit
//
//  Copyright (c) 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

PSPDF_AVAILABLE_DECL @protocol PSPDFErrorHandler <NSObject>

/// All parameters are optional, however you should call it with at least error or title.
/// @note The implementing view controller can decide how to best present this.
- (void)handleError:(nullable NSError *)error title:(nullable NSString *)title message:(nullable NSString *)message;

@end
