//
//  PSPDFAnnotationGroupItem+PSPDFPresets.h
//  PSPDFKit
//
//  Copyright (c) 2015-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFAnnotationGroupItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSPDFAnnotationGroupItem (PSPDFPresets)

/// Produces the default Ink annotation icon, which includes the currently set ink color and thickness.
/// Only supported for Ink annotation types.
+ (PSPDFAnnotationGroupItemConfigurationBlock)inkConfigurationBlock;

/// Produces the default Line annotation icon with support for arrow.
+ (PSPDFAnnotationGroupItemConfigurationBlock)lineConfigurationBlock;

/// Allows to configure the `PSPDFAnnotationStringFreeTextVariantCallout` option of `PSPDFAnnotationStringFreeText`.
+ (PSPDFAnnotationGroupItemConfigurationBlock)freeTextConfigurationBlock;

@end

NS_ASSUME_NONNULL_END
