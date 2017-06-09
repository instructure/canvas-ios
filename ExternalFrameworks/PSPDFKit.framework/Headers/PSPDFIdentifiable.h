//
//  PSPDFIdentifiable.h
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

/// Protocol to uniquely identify an object.
PSPDF_AVAILABLE_DECL @protocol PSPDFIdentifiable<NSObject>

/// Unique string to identify an object.
@property (nonatomic, nullable, copy) NSString *uniqueIdentifier;

@end

NS_ASSUME_NONNULL_END
