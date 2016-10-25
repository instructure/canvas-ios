//
//  PSPDFAnnotationStyle.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFModel.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFAnnotation;

/// Defines an annotation style.
PSPDF_CLASS_AVAILABLE @interface PSPDFAnnotationStyle : PSPDFModel

PSPDF_EMPTY_INIT_UNAVAILABLE

/// Designated Initializer with the name of the style.
- (instancetype)initWithName:(NSString *)styleName NS_DESIGNATED_INITIALIZER;

/// The name of the annotation style.
@property (atomic, copy) NSString *styleName;

/// Key/Value pairs of style settings that should be applied to the object.
@property (atomic, copy, nullable) NSDictionary<NSString *, id> *styleDictionary;

/// Populates the `styleDictionary`. use nil for `style` to remove a value
- (void)setStyle:(nullable id)style forKey:(NSString *)key;

/// Applies all applicable style attribute to the annotation. Matching is done via property name comparison.
- (void)applyStyleToAnnotation:(PSPDFAnnotation *)annotation;

@end

NS_ASSUME_NONNULL_END
